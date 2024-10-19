#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export LANG=en_US.utf8

if [[ ! $DISPLAY && $XDG_VTNR -le 3 ]]; then
	exec startx
fi

#if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -le 3 ]]; then
#	exec startx
#fi
