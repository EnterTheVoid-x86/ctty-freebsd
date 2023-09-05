#!/bin/sh

version="0.3-fbsd"

#set the inital config directory 
config_dir="$HOME/.config/ctty"
if ! [ -d "$config_dir" ]; then
	echo "Creating config directory.."
	mkdir -p $config_dir
	echo "Copying config files.."
	cp -v $(dirname "$0")/ctty/* $config_dir/
fi


#Defining available color schemes.
#There are 16 colors we can define.
#Colors 0-7 are the dark colors,
#Colors 8-f are the light colors.

#Normally in a graphical terminal we can define foreground and background
#colors separately. This is sadly not possible in TTY.

#Therefore I sacrificed the colors of black and white for fore- and background.

#Color indices are as following:
: '
	dark_black:	0
	dark_red:	1
	dark_green:	2
	dark_yellow:	3
	dark_blue:	4
	dark_magenta:	5
	dark_cyan:	6
	dark_white:	7

	light_black:	8
	light_red:	9
	light_green:	a
	light_yellow:	b
	light_blue:	c
	light_magenta:	d
	light_cyan:	e
	light_white:	f

'

#Built-in schemes
color_scheme_default() {
	fg=c5c8c6
	bg=1d1f21

	dark_black=$bg
	dark_red=ab0000
	dark_green=afc200
	dark_yellow=ff6800
	dark_blue=006dc8
	dark_magenta=7800a1
	dark_cyan=00a38e
	dark_white=$fg

	light_black=373b41
	light_red=ff0000
	light_green=e7ff00
	light_yellow=ffa900
	light_blue=008aff
	light_magenta=c400ff
	light_cyan=00ffdd
	light_white=c8c8c8
}

color_scheme_hyper() {
	fg=ffffff
	bg=1d1f21

	dark_black=$bg
	dark_red=fe0100
	dark_green=33ff00
	dark_yellow=feff00
	dark_blue=0066ff
	dark_magenta=cc00ff
	dark_cyan=00ffff
	dark_white=$fg

	light_black=808080
	light_red=fe0100
	light_green=33ff00
	light_yellow=feff00
	light_blue=0066ff
	light_magenta=cc00ff
	light_cyan=00ffff
	light_white=ffffff
}


#Naming schemes for colors are 'color_scheme_N' where N is some name
#Only the value of N is relevant for the end-user, the rest is internal
list_schemes() {
	grep "^color_scheme_" $0 $config_dir/colorSchemes.sh | cut -d_ -f3,4 | sed 's/[(].*$//'

	#Failed POSIX attempt to get a list of all function..
	#If anyone knows a POSIX way to get a list of all defined
	#functions please let me know..

	#if [ "$(command -v $0)x" != "x" ]; then
    	#	echo " * INFO: Found function $0"
	#fi
}

#
# This is where the console font directory is stored however this will need to be investigated for other 
# distros 
# lists all the valid fonts we can work with and strip the path off them to just the parts the user has 
# to type in
print_fonts() {
	ls /usr/share/kbd/consolefonts/* | grep ".psfu.gz" | sed "s/\/usr\/share\/kbd\/consolefonts\///"
}

#Checks if the given scheme is available, if not it returns 0
check_scheme() {
	ret=0
	list=$(list_schemes)
	for scheme in $list; do
		if [ "$1" = "$scheme" ] || [ "$1" = "Xresources" ]; then
			ret=1
			break
		else
			ret=0
		fi
	done
	echo $ret
}

check_font() {
	ret=0
	list=$(print_fonts)
	for scheme in $list; do
		if [ "$1" = "$scheme" ]; then
			ret=1
			break
		else
			ret=0
		fi
	done
	echo $ret
}

parse_xresources() {
	if [ -e $HOME/.Xresources ]; then
		fg=$(grep "foreground" ~/.Xresources | cut -d# -f2)
		bg=$(grep "background" ~/.Xresources | cut -d# -f2)
		dark_black=$bg
		dark_red=$(grep "color1:" ~/.Xresources | cut -d# -f2)
		dark_green=$(grep "color2:" ~/.Xresources | cut -d# -f2)
		dark_yellow=$(grep "color3:" ~/.Xresources | cut -d# -f2)
		dark_blue=$(grep "color4:" ~/.Xresources | cut -d# -f2)
		dark_magenta=$(grep "color5:" ~/.Xresources | cut -d# -f2)
		dark_cyan=$(grep "color6:" ~/.Xresources | cut -d# -f2)
		dark_white=$fg

		light_black=$(grep "color8:" ~/.Xresources | cut -d# -f2)
		light_red=$(grep "color9:" ~/.Xresources | cut -d# -f2)
		light_green=$(grep "color10:" ~/.Xresources | cut -d# -f2)
		light_yellow=$(grep "color11:" ~/.Xresources | cut -d# -f2)
		light_blue=$(grep "color12:" ~/.Xresources | cut -d# -f2)
		light_magenta=$(grep "color13:" ~/.Xresources | cut -d# -f2)
		light_cyan=$(grep "color14:" ~/.Xresources | cut -d# -f2)
		light_white=$(grep "color15:" ~/.Xresources | cut -d# -f2)
	else
		echo "Xresources does not exist, exiting."
		exit 1
	fi
}

invert_color() {
	in_color=$(echo $1 | sed 's/.\{2\}/& /g')
	for value in $in_color; do
		dec_color=$(printf "%d" 0x$value)
		inv_color=$((255-$dec_color))
		hex_color=$(printf "%x" $inv_color)
		hex="${hex:+${hex}}${hex_color}"
	done
	echo $hex
}

inverted_colors() {
	fg=$(invert_color $fg)
	bg=$(invert_color $bg)

	dark_black=$bg
	dark_red=$(invert_color $dark_red)
	dark_green=$(invert_color $dark_green)
	dark_yellow=$(invert_color $dark_yellow)
	dark_blue=$(invert_color $dark_blue)
	dark_magenta=$(invert_color $dark_magenta)
	dark_cyan=$(invert_color $dark_cyan)
	dark_white=$fg

	light_black=$(invert_color $light_black)
	light_red=$(invert_color $light_red)
	light_green=$(invert_color $light_green)
	light_yellow=$(invert_color $light_yellow)
	light_blue=$(invert_color $light_blue)
	light_magenta=$(invert_color $light_magenta)
	light_cyan=$(invert_color $light_cyan)
	light_white=$(invert_color $light_white)
}

help_function() {
	printf %b '\n' \
		"Usage: $0 [-ifpdschvxl] <Argument>\n"	\
		'\t-f\tset console font\n'			\
		'\t-p\tprint list of fonts and exit\n'\
		'\t-c\tset the color scheme\n'		\
		'\t-d\tset the font and scheme of this device\n'\
		'\t-s\toveride the base config directory\n'\
		'\t-h\tprint this help screen\n'	\
		'\t-l\tlist available schemes\n'	\
		'\t-v\tprint version\n'			\
		'\t-i\tinvert color scheme, use with -c or -x\n'\
		'\t-x\tparse and use Xresource color scheme\n'
	exit 0
}

set_font() {
	if [ -n $device ]; then
		setfont -C $device
	fi
	vidcontrol -f $arg_f
}

while getopts "c:f:d:s:hlixpv" opt
do
	case "$opt" in
		c ) arg_c="$OPTARG" ;;
		f ) arg_f="$OPTARG" ;;
		h ) help_function ;;
		l ) list_schemes; exit 0 ;;
		p ) print_fonts; exit 0 ;;
		d ) device="$OPTARG" ;;
		v ) echo "Version: $version"; exit 0 ;;
		i ) arg_i="Inverted" ;;
		s ) config_dir="$OPTARG" ;;
		x ) arg_c="Xresources" ;;
		? ) help_function ;;
	esac
done



#Loading the scheme file..
. $config_dir/colorSchemes.sh


if [ $OPTIND -eq 1 ]; then
	echo "No parameters given.."
	help_function
fi

set_font() {
	vidcontrol -f $arg_f
}


set_colour() {
	echo "Please add this to your /boot/loader.conf:"
 	echo -e "# black\nkern.vt.color.0.rgb='##${dark_black}'\n# dark red\nkern.vt.color.1.rgb='##${dark_red}'\n# dark green\nkern.vt.color.2.rgb='#${dark_green}'\n# dark yellow\nkern.vt.color.3.rgb='#${dark_yellow}'\n# dark blue\nkern.vt.color.4.rgb='#${dark_blue}'\n# dark magenta\nkern.vt.color.5.rgb='#${dark_magenta}'\n# dark cyan\nkern.vt.color.6.rgb='#${dark_cyan}'\n# light gray\nkern.vt.color.7.rgb='#${light_white}'\n# dark gray\nkern.vt.color.8.rgb='#${dark_white}'\n# light red\nkern.vt.color.9.rgb='#${light_red}'\n# light green\nkern.vt.color.10.rgb='#${light_green}'\n# light yellow\nkern.vt.color.11.rgb='#${light_yellow}'\n# light blue\nkern.vt.color.12.rgb='#${light_blue}'\n# light magenta\nkern.vt.color.13.rgb='#${light_magenta}'\n# light cyan\nkern.vt.color.14.rgb='#${light_cyan}'\n# white\nkern.vt.color.15.rgb='#FFFFFF'"
}

if [ -n $arg_f ] && [ $(check_font $arg_f) -eq 1 ]; then 
	echo "setting console font to $arg_f"
	set_font
else
	echo "invalid font given, please see the list of fonts with -p"
	echo "please ignore this error if you didn't pass a font"
fi 

if [ -n $arg_c ] && [ -z $arg_i ] && [ $(check_scheme $arg_c) -eq 1 ]; then
	echo "Using color scheme: $arg_c"
	if [ "$arg_c" = "Xresources" ]; then
		parse_xresources
	else
		color_scheme_$arg_c
	fi
	set_colour
elif [ -n $arg_i ] && [ $(check_scheme $arg_c) -eq 1 ]; then
	echo "Using color scheme: $arg_i $arg_c"
	if [ "$arg_c" = "Xresources" ]; then
		parse_xresources
		inverted_colors
	else
		color_scheme_$arg_c
		inverted_colors

	fi
	set_colour
else
	echo "Invalid color scheme given, please see the list of available color schemes."
	echo "please ignore this error if you didn't pass a color"
	exit 1
fi
