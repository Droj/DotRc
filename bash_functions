#!bash

eko "bash_functions..."

pathrm () {
    typeset NEWPATH
    NEWPATH=${PATH%:$1}     # Strip from end
    NEWPATH=${NEWPATH#$1:}  # Strip from beginning
    PATH=${NEWPATH//:$1:/:} # Remove
}
pathprepend () {
    pathrm $1
    PATH=$1:$PATH
}
pathappend() {
    pathrm $1
    PATH=$PATH:$1
}


#
# Trims a string and appends "..."
#
# $1    - the trim length, including the "..."
# $2..n - the text to trim
#
trim()
{
   typeset lnMaxLen=$1 ; shift
   typeset lsText="$*"
   typeset lnLen="${#lsText}"
   typeset lsTrimmed=""

   if (( lnMaxLen < lnLen )) ; then
      lsTrimmed="${lsText:0:$((lnMaxLen-3))}..."
   else
      lsTrimmed="${lsText}"
   fi
   echo "$lsTrimmed"
}

#
# Trims a string and prepends "..."
#
# $1    - the trim length, including the "..."
# $2..n - the text to trim
#
trim_left() {
   typeset -i lnMaxLen=$1 ; shift
   typeset    lsText="$*"
   typeset -i lnLen="${#lsText}"
   typeset    lsTrimmed=""
   typeset -i lnBeg=0

   if (( lnMaxLen < lnLen )) ; then
      lnBeg=$((lnLen - (lnMaxLen - 3)))
      lsTrimmed="...${lsText:$lnBeg:$lnLen}"
   else
      lsTrimmed="${lsText}"
   fi
   echo "$lsTrimmed"
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

title_xterm()
{
    typeset lsTitle=$'\e]0;'"$1"$'\a'
    if $_screen; then
        lsTitle=$'\eP'"${lsTitle}"$'\e\\'
    fi
    echo "$lsTitle"
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


