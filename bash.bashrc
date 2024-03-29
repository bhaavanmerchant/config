#
# /etc/bash.bashrc
#
# This file is the systemwide bashrc file. While most of the
# environment is preserved when running an interactive shell
# the PS[1-4] variables, aliases and functions are reset.
#
# When running a non-login shell, apply the following settings:
# - Prompt defaults (PS[1-4], PROMPT_COMMAND)
# - bash_completion if it exists
# - source /etc/bash.bashrc.local

PS1='[\[\e[0;33m\]\u@arch \[\e[0;31m\]\W\[\e[0m\]]\$ '
PS2='> '
PS3='> '
PS4='+ '

export PS1 PS2 PS3 PS4

if test "$TERM" = "xterm" -o \
        "$TERM" = "xterm-color" -o \
        "$TERM" = "xterm-256color" -o \
        "$TERM" = "rxvt" -o \
        "$TERM" = "rxvt-unicode" -o \
        "$TERM" = "xterm-xfree86"; then
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
    export PROMPT_COMMAND
fi

[ -r /etc/bash_completion   ] && . /etc/bash_completion
[ -r /etc/bash.bashrc.local ] && . /etc/bash.bashrc.local

export http_proxy="127.0.0.1:8123"
export https_proxy="127.0.0.1:8123"
export HTTP_PROXY="127.0.0.1:8123"
export HTTPS_PROXY="127.0.0.1;8123"
