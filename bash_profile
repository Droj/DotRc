#!bash
# Things to do only at login...

# automatically export everything in this file for subshells
set -a

QUIET=1
QUIET=0

[[ $DEBUG == 1 ]] &&
   QUIET=0

eko() {
    [[ $- == *i* && 0 -eq $QUIET ]] && echo "$*"
}

. ~/.rc/bash_functions

# Site-specific settings can be activated based on the environment.  The
# setting of these variables requires invoking an external program, so only do
# it if needed.
[[ -z $SITE ]] &&
   SITE=$(<~/.site)

[[ -z $_uname ]] &&
   _uname=$(uname)

XAPPLRESDIR=~/en_US  # Default on Debian, not on Fedora.  Hm.
LESS="-j3 -M"
SVN_EDITOR=vim
PYTHONSTARTUP=~/.pystartup

#
# Completion
#
FIGNORE=".swp:.swo:~"

# for 'sh' shells
ENV=~/.bashrc


#
# Set up 'ls'
#
[[ -z $LS_COLORS ]] &&
   [[ -e ~/.dircolors ]] && eval $(dircolors -b ~/.dircolors)
LSOPT="-F"
ls --color=auto > /dev/null 2>&1 && LSOPT="$LSOPT --color=auto"
ls()
{
    command ls $LSOPT "$@"
}

# Make sure these are all in the path
for p in /usr/X11R6/bin /bin /usr/bin /usr/local/bin ; do
    pathprepend $p
done
pathappend ~/script


###########################################################################
# PS1 - prompt
#
unset PS1_title PS1_intro

PS1_title=''
#if [[ "$TERM" == xterm || -n "$XTERM_VERSION" ||
#        "$TERM" == cygwin || "$TERM" == "rxvt-cygwin-native" ]] ; then
#    PS1_title=$'\e]0;''\h (\u) - \w ($?)'$'\a'
#fi

PROMPT_COMMAND='prompt_cmd'
prompt_cmd() {
    _err=$?
    #_e=$( ((_err!=0)) && printf "($_err)" )
    #_e=$( ((_err)) && echo -n "($_err)" )
    ((_err)) && _e="($_err)"

    # Set the screen title if the current directory has changed since the last
    # time we set it.
    if [[ -n $_screen ]] ; then
        if [[ $_cwd != ${PWD} ]] ; then
            _cwd=${PWD}
            screen_title_trim_left ${PWD}
            title_xterm "$HOSTNAME ($USER) - $(trim_left 50 ${PWD})"
        fi
    fi
}


PS1_intro=$'\\[\e[34m\\]\\w\\[\e[0m\\] (\\h : \\u)\n'

# If we are using screen...
_screen=''
if [[ -n $STY || $TERM == screen ]] ; then
    _screen=true
    #R=""
    #L=20
    #if [[ -n $SSH_CLIENT ]] ; then
    #    R="$(hostname):"
    #    L=30
    #fi

    PS1_title='\eP'"$PS1_title"'\e\\'  # Pass esc. seq to device...
#    PS1_title="$PS1_title"'\ek$(perl -e '\''$l = '$L'; print "'$R'", length($ENV{PWD}) > $l ? "..." . substr($ENV{PWD}, -($l-3)) : $ENV{PWD}'\'')\e\\\]'
#    
#    # ' (<= syntax coloring fix)

    # Take advantage of the 'shelltitle' option.  The empty escape sequence
    # needs to be on the same line as the prompt itself...
    #PS1_intro="${PS1_intro}"'\[\ek\e\\\]' 

fi

#####################################################################



# Source shell-specific startup files
eko "Setting up 'env' files..."
envFiles=( _platf_$_uname \
      _site_$SITE \
      _host_$HOSTNAME \
   )


# Load shell-specific files
loadEnvFiles()
{
    eko "Loading shell-specific files..."
    for f in "${envFiles[@]}" ; do
        if [[ -f ~/.bash${1}${f} ]] ; then
            eko Loading ~/.bash${1}${f}...
            . ~/.bash${1}${f}

        else eko No ~/.bash${1}${f}...
        fi

    done
}
loadEnvFiles _profile

set +a # stop automatically exporting

#vim:set ft=sh:
