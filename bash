#!bash
# vim:ft=sh:
# var:b\:is_bash=1:misc_var=1:
#for s in split(getline(2), ':')[2:] | exec "let b:".s | endfor

eko .rc/bash
#set -x

shopt -s extglob     # Enable extended globbing (pattern matching)
shopt -s cdable_vars # when cd'ing, if dir no there, use $dir



###########################################################################
#
# Functions/Aliases
#

#
# Trims a string and appends "..."
#
# $1    - the trim length, including the "..."
# $2..n - the text to trim
#
trim()
{
   typeset len=$1 ; shift
   typeset text="$*"
   typeset trimmed=""

   if (( len < ${#text} )) ; then
      trimmed="${text:0:$((len-3))}..."
   else
      trimmed="${text}"
   fi
   echo "$trimmed"
}

#
# Trims a string and prepends "..."
#
# $1    - the trim length, including the "..."
# $2..n - the text to trim
#
trim_left() {
   typeset len=$1 ; shift
   typeset text="$*"
   typeset trimmed=""

   if (( len < ${#text} )) ; then
      beg=$((${#text} - (len - 3)))
      trimmed="...${text:$beg:${#text}}"
   else
      trimmed="${text}"
   fi
   echo "$trimmed"
}


_screen_title_len=20


screen_title() {
    echo -n $'\ek'"$@"$'\e\\'
}

# Sets the title of a screen window, with a limit of 20 characters.  Longer
# titles are trimmed, with an elipses ("...") appended.
screen_title_trimmed() {
    screen_title "$(trim $_screen_title_len $*)"
}

# Sets the title of a screen window, with a limit of 20 characters.  Longer
# titles are trimmed, with an elipses ("...") PRE-pended.
screen_title_trim_left() {
    screen_title "$(trim_left $_screen_title_len $*)"
}

# Alias rsh when we're in screen, so the screen title will reflect what host
# the window is in.
if [[ -n $STY || $TERM == 'screen' ]] ; then
    rsh() {
        screen_title_trimmed "rsh $*"
        /bin/rsh "$@"
    }
    ssh() {
        screen_title_trimmed "ssh $*"
        /bin/ssh "$@"
    }
fi



###########################################################################
# PS1 - prompt
#
unset PS1_title PS1_intro

PS1_title=''
if [[ "$TERM" == xterm || -n "$XTERM_VERSION" ||
        "$TERM" == cygwin || "$TERM" == "rxvt-cygwin-native" ]] ; then
    PS1_title='\e]0;\h (\u) - \w ($?)\a'
fi

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

    #PS1_title='\eP'"$PS1_title"'\e\\'  # Pass esc. seq to device...
#    PS1_title="$PS1_title"'\ek$(perl -e '\''$l = '$L'; print "'$R'", length($ENV{PWD}) > $l ? "..." . substr($ENV{PWD}, -($l-3)) : $ENV{PWD}'\'')\e\\\]'
#    
#    # ' (<= syntax coloring fix)

    # Take advantage of the 'shelltitle' option.  The empty escape sequence
    # needs to be on the same line as the prompt itself...
    #PS1_intro="${PS1_intro}"'\[\ek\e\\\]' 

fi

PS1='\n'${PS1_title}${PS1_intro}'${_e}$ '

export PS1
#
###########################################################################

#
# Completion
#
FIGNORE=".swp:.swo:~"

###########################################################################
#
# Key bindings
#
#

# Normal C-w binding kills entire filenames, while this just to the prev '/'.
# Bash takes overwrites any bindings if they are special terminal keys
# (http://lists.gnu.org/archive/html/bug-bash/2005-01/msg00167.html), so in
# order to bind C-w, we need to undefine the terminal setting for that key.
#
if [[ $TERM != dumb ]] ; then
    stty werase ''
    bind -m vi-insert '\C-w:backward-kill-word'
fi


