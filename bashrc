# func
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------

# Find file by template
fft() { find . -type f -iname '*'$*'*' -ls ; }

# find file by template and execute command
ffte() { find . -type f -iname '*'$1'*' -exec "${2:-file}" {} \;  ; }

# find string in files
ffts() {
    OPTIND=1
    local case=""
    local usage="fstr: search string in files. Usage: ffts [-i] \"str template\" [\"filename template\"] "
    while getopts :it opt
    do
        case "$opt" in
        i) case="-i " ;;
        *) echo "$usage"; return;;
        esac
    done
    shift $(( $OPTIND - 1 ))
    if [ "$#" -lt 1 ]; then
        echo "$usage"
        return;
    fi
    local SMSO=$(tput smso)
    local RMSO=$(tput rmso)
    find . -type f -name "${2:-*}" -print0 | xargs -0 grep -sn ${case} "$1" 2>&- | sed "s/$1/${SMSO}\0${RMSO}/gI" | more
}

cap () { tee /tmp/capture.out; }
ret () { cat /tmp/capture.out; }

colors () {
    for i in {30..37}; do
        echo -e "\033[0;${i}m 0;${i} | \033[1;${i}m 1;${i}"
        echo -e ""
    done | column -c 80 -s ' ';
   # for i in {0..255}; do echo -e "\e[38;05;${i}m\\\e[38;05;${i}m"; done | column -c 80 -s '  '; echo -e "\e[m"
}


function mkcd () { mkdir -p "$@" && eval cd "\"\$$#\""; }


append_path () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
    esac
}

256_colors() {
    for fgbg in 38 48 ; do # Foreground / Background
        for color in {0..255} ; do # Colors
            # Display the color
            printf "\e[${fgbg};5;%sm  %3s  \e[0m" $color $color
            # Display 6 colors per lines
            if [ $((($color + 1) % 6)) == 4 ] ; then
                echo # New line
            fi
        done
        echo # New line
    done
}

#man() {
#	env \
#		LESS_TERMCAP_mb=$(printf "\e[0;31m") \
#		LESS_TERMCAP_md=$(printf "\e[0;32m") \
#		LESS_TERMCAP_me=$(printf "\e[0m") \
#		LESS_TERMCAP_se=$(printf "\e[0m") \
#		LESS_TERMCAP_so=$(printf "\e[1;47;30m") \
#		LESS_TERMCAP_ue=$(printf "\e[0;31m") \
#		LESS_TERMCAP_us=$(printf "\e[0;36m") \
#	man "$@"
#}


dirsize() {
	du -shx * .[a-zA-Z0-9_]* 2> /dev/null | \
	grep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
	grep '^ *[0-9.]*M' /tmp/list
	grep '^ *[0-9.]*G' /tmp/list
	rm /tmp/list
}

cl() {
    local dir="$1"
    local dir="${dir:=$HOME}"
    if [[ -d "$dir"  ]]; then
        cd "$dir" >/dev/null; exa -lao --group-directories-first -m --git -b -g --time-style long-iso --no-quotes
    else
        echo "bash: cl: $dir: Directory not found"
    fi
}


updatePrompt() {
 	if [[ "$(pyenv virtualenvs)" == *"* $(pyenv version-name) "* ]]; then
		export PS1='($(pyenv version-name)) '$PROMPT_COMMAND
	else
		export PS1=$PROMPT_COMMAND
	fi
}


bash_prompt_command() {

    local pwdmaxlen=25
    local trunc_symbol=".."
    local dir=${PWD##*/}
    pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))
    NEW_PWD=${PWD/#$HOME/\~}
    local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))
    if [ ${pwdoffset} -gt "0" ]
    then
        NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
        NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
    fi
}

bash_prompt() {

    #localectl set-locale LANG=en_US.UTF-8

    case $TERM in
    xterm*|rxvt*|urxvt*|rxvt-unicode*)
        local TITLEBAR='\[\033]0;${NEW_PWD}\007#\]'
        ;;
    *)
        local TITLEBAR=""
        ;;
    esac
    local NONE="\[\033[0m\]"
    
    local K="\[\033[0;30m\]"
    local R="\[\033[0;31m\]"
    local G="\[\033[0;32m\]"
    local Y="\[\033[0;33m\]"
    local B="\[\033[0;34m\]"
    local M="\[\033[0;35m\]"
    local C="\[\033[0;36m\]"
    local W="\[\033[0;37m\]"
    
    local EMK="\[\033[1;30m\]"
    local EMR="\[\033[1;31m\]"
    local EMG="\[\033[1;32m\]"
    local EMY="\[\033[1;33m\]"
    local EMB="\[\033[1;34m\]"
    local EMM="\[\033[1;35m\]"
    local EMC="\[\033[1;36m\]"
    local EMW="\[\033[1;37m\]"
    
    local BGK="\[\033[40m\]"
    local BGR="\[\033[41m\]"
    local BGG="\[\033[42m\]"
    local BGY="\[\033[43m\]"
    local BGB="\[\033[44m\]"
    local BGM="\[\033[45m\]"
    local BGC="\[\033[46m\]"
    local BGW="\[\033[47m\]"

    local UC=$EMB
    [ $UID -eq "0" ] && UC=$R

    if [[ $PIPENV_CUSTOM_VENV_NAME ]]; then
        PS1_CUSTOM_PIPENV_SLUG="${EMK}(${PIPENV_CUSTOM_VENV_NAME}) :: "
    fi
   
	if [ $UID -ne 0 ]; then	
        PS1="\n${W}\342\226\210\342\226\210 ${PS1_CUSTOM_PIPENV_SLUG}${EMR}\h ${EMW}: ${EMW}\u ${W}[ ${EMW}\w ${W}]${Y}\$(__git_ps1 ' (%s)')${W}\n${W}\342\226\210\342\226\210 ${EMW}\\$ ${NONE}"
	else
		PS1="\n${R}\342\226\210\342\226\210 ${EMR}\h ${W}: ${EMR}\u ${W}[ ${EMW}\w ${W}]\n${R}\342\226\210\342\226\210 ${EMW}\\$ ${NONE}"
	fi

    export PROMPT_COMMAND='history -n; history -w; history -c; history -r; echo -ne "\033]0;$PWD\007"'
}

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
# func



# env
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------

[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

if [ -f /usr/share/git/completion/git-prompt.sh  ]; then
    . /usr/share/git/completion/git-prompt.sh
fi

#export GRC_ALIASES=true
#if [[ -s "/etc/profile.d/grc.sh" ]]; then
#    . /etc/profile.d/grc.sh
#fi

export QUOTING_STYLE=literal

export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM=auto

export TERM=rxvt-unicode

export LANG="en_US.UTF-8"
export EDITOR="vim"
export GREP_COLORS="mt=1;31"
export GIT_SSL_NO_VERIFY=true

export IGNOREEOF=20

export MANPAGER="less -R --use-color -Dd+r -Du+b"
export MANROFFOPT="-P -c"

export HISTSIZE=999999
export HISTFILESIZE=${HISTSIZE}
export HISTIGNORE="exit:alsi:clear:date:whoami"
export HISTCONTROL=ignorespace:ignoredups
shopt -s histappend

complete -cf sudo
complete -c man which

shopt -s checkwinsize
shopt -s autocd
shopt -s cdspell
shopt -s extglob

export QT_QPA_PLATFORMTHEME=qt6ct
export QT_LOGGING_RULES='*=false'

export MPD_HOST=~/.mpd/socket

export WB_NO_GNOME_KEYRING=1

export WORKON_HOME=~/.venvs

export GOPATH=~/codebase/go
export GOBIN=$GOPATH/bin
append_path $GOBIN

append_path '~/.bin'
export PATH

bash_prompt
unset bash_prompt

#clear && hash cowsay 2>/dev/null && hash fortune 2>/dev/null && fortune -s | cowsay -f /usr/share/cows/girl.cow 2>/dev/null
clear

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
# env

#source /usr/share/blesh/ble.sh

# cmd
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------

alias src='source ~/.bashrc'
alias vbrc='vim ~/.bashrc'

alias mpc='ncmpcpp'

alias bat='bat --paging=never'

alias ..='cd ..'
alias ...='cd ../..'
alias cd..='cd ..'
alias cd...='cd ../..'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias path='echo -e ${PATH//:/\\n}'
alias rm='rm -i'
alias diff='vimdiff'
alias grep='grep --color=auto'
alias more='less'
alias dfc='dfc -wo'
alias du='du -ch'
alias cdu='cdu -isdhca'
alias make='colormake'
alias yrt='yay'
alias dat='date "+%A, %B %d, %Y [%T]"'
alias du1='du --max-depth=1'
alias hist='history | grep $1'      # requires an argument
alias openports='netstat -tulpan'
alias pg='ps -Af | grep $1'         # requires an argument
alias track='watch -d "$1"'
alias ip='ip -color=auto'

alias py='python'

alias ls='exa -o --group-directories-first --no-quotes'
alias lr='exa -Rlao --group-directories-first -m --git -b -g --time-style long-iso --no-quotes'
alias ll='exa -lo --group-directories-first -m --git -b -g --time-style long-iso --no-quotes'
alias la='exa -lao --group-directories-first -m --git -b -g --time-style long-iso --no-quotes'

alias sgt='smartgit'
alias gs='git status '
alias ga='git add '
alias gb='git branch '
alias gcm='git commit'
alias gd='git diff'
alias gco='git checkout '
alias gk='gitk --all&'
alias gx='gitx --all'
alias gl='git log -30 --pretty=format:"%h - %an, %ar : %s" --graph'

alias projecteur='comp && projecteur &'

alias randr0='xrandr  --output eDP1 --mode 1920x1080 --scale 1x1 --pos 0x0'
alias randr1='xrandr  --output eDP1 --off --scale 1x1 --pos 1920x0 --output DP1 --mode 1920x1080 --scale 1x1 --pos 0x0 --same-as eDP1'
alias randr2='xrandr  --output eDP1 --mode 1920x1080 --scale 1x1 --pos 1920x0 --output DP1 --mode 1920x1080 --scale 1x1 --pos 0x0 --same-as eDP1'
alias randr23='xrandr  --output eDP1 --mode 1920x1080 --scale 1x1 --pos 1920x0 --output DP1-3 --mode 1920x1080 --scale 1x1 --pos 0x0 --same-as eDP1'
alias randr3='xrandr  --output eDP1 --off --output HDMI2 --mode 1920x1080 --scale 1x1 --pos 0x0 --same-as eDP1 --output HDMI1 --mode 1920x1080 --scale 1x1 --pos 1920x0 --rotate left --right-of HDMI2'

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
# cmd


# priv
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------

if [ $UID -ne 0 ]; then
	sudo_handler='sudo'
fi

alias scat='$sudo_handler cat'
alias svim='$sudo_handler vim'
alias reboot='$sudo_handler reboot'
alias update='$sudo_handler pacman -Syu'
alias netcfg='$sudo_handler netcfg2'
alias halt='$sudo_handler halt'
alias mount='$sudo_handler mount | column -t'
alias umount='$sudo_handler umount'
alias reflect='$sudo_handler reflector --sort rate -f 5 --save /etc/pacman.d/mirrorlist'
alias inxi='$sudo_handler inxi -F -xxx -c 12 -d -f -i -J -l -m -o -p -r -t -u -x --max-wrap 200'

alias std='$sudo_handler systemctl'
alias logs='$sudo_handler journalctl'

alias dc='docker-compose'

alias d='$sudo_handler docker '
alias dx='d exec -it '
alias da='d ps -a '
alias di='d images '
alias drm='d rm '
alias dri='d rmi '
alias docker-getip="d inspect --format '{{ .NetworkSettings.IPAddress }}' $1 "
alias docker-login='d exec -it $1 bash '

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
# priv
