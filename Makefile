
PATH=/usr/local/bin/ 
CONFIG=${HOME}/.config/ 

.PHONY: install verbose

install:
	cp ./ctty.sh ${PATH}/ctty #
	cp -r ./ctty ${CONFIG} #Install config dir 

verbose: 
	echo "${PATH}"
	echo "${CONFIG}"
