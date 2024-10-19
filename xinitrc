#!/bin/sh

append_path ~/.bin

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

export LIBVA_DRIVER_NAME=iHD

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi


if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi


if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"

fi


if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

xset -b
xset s off -dpms
xset r rate 175 50

#setxkbmap -layout us,il,ru -variant ,,phonetic -option grp:alt_shift_toggle -option caps:escape &
#nm-applet --sm-disable &
#keepassxc &
#pasystray &

##eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
##export SSH_AUTH_SOCK

##hsetroot -center /usr/share/awesome/themes/default/background.png
##(sleep 2 && comp) &

DEFAULT_SESSION=awesome
exec awesome
