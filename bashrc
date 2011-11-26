#!bash
# vim:ft=sh:
# var:b\:is_bash=1:misc_var=1:
#for s in split(getline(2), ':')[2:] | exec "let b:".s | endfor


type -t eko>/dev/null || . ~/.rc/bash_profile
eko .rc/bashrc

shopt -s extglob     # Enable extended globbing (pattern matching)
shopt -s cdable_vars # when cd'ing, if dir no there, use $dir

set -o vi


# This is supposed to be set at this point, according to the man page, but it
# is not so. So, fall back to using the BASH var and look for 'sh' instead of
# 'bash'.
if [[ $SHELLOPTS == *posix* || ${BASH##*/} == 'sh' ]]; then
    export PS1='$ '
    unset PROMPT_COMMAND
else
    export PS1='\n'${PS1_title}${PS1_intro}'${_e}${PS1_label}$ '
fi


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

#loadEnvFiles

