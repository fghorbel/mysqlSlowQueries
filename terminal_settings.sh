#!/bin/bash

export TERM=xterm-color
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

export COLOR_NC='\e[0m' # No Color
export COLOR_WHITE='\e[1;37m'
export COLOR_BLACK='\e[0;30m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_GRAY='\e[0;30m'
export COLOR_LIGHT_GRAY='\e[0;37m'


#===  FUNCTION  ================================================================
#         NAME:  changeBgColor
#  DESCRIPTION:  #function_description
#===============================================================================
function  changeBgColor(){

    case $TERM in
     xterm*|rxvt*)
         local TITLEBAR='\[\033]0;\u ${NEW_PWD}\007\]'
          ;;
     *)
         local TITLEBAR=""
          ;;
    esac

    local UC=$COLOR_WHITE               # user's color
    [ $UID -eq "0" ] && UC=$COLOR_RED   # root's color

    
} #----------  end of function changeBgColor ----------


changeBgColor

PS1="\[${COLOR_LIGHT_RED}\]\$(hostname):$TITLEBAR\[${COLOR_GREEN}\]\u  \[${COLOR_LIGHT_BLUE}\]\${PWD} \n\[${COLOR_LIGHT_GREEN}\]→\[${COLOR_NC}\]"
