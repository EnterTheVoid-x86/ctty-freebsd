# Cool TTY

CTTY is a simple script that allows the user to change the default colors in any given TTY.
It does this by overriding the default color values.

Now, we can only define 16 distinc colors, minus 2 that are sacrificed for fore- and background.
Currently there are only 4 schemes to choose from and the ability to parse the Xresource file, though I will add more as time goes on.

Contributions are also welcomed c:

The script should work on any BSD system, Linux is untested ~~but I'm 80% sure that it should work just fine.~~ nope

Note: I should again mention that it will only work in TTY, there is no way it will work in any graphical terminal emulator.


Here are some examples:

Unchanged
![Before](https://github.com/Stargirl-chan/ctty/blob/master/default.png)

Default scheme
![Color scheme 1](https://github.com/Stargirl-chan/ctty/blob/master/scheme_1.png)

Hyper scheme ~~My favorite so far~~
![Color scheme 2](https://github.com/Stargirl-chan/ctty/blob/master/scheme_2.png)

Dracula scheme
![Dracula Scheme](./dracula.png)

## How to use

Clone the repo, make the script executable and run it from any TTY
```
git clone https://github.com/EnterTheVoid-x86/ctty-freebsd.git
cd ctty-freebsd
chmod +x ctty.sh
```

You can install by running ``sudo make install``.

## Other plans
I should mention that font changes are not permanent, however you can make a simple service that runs the script on every tty every boot.
