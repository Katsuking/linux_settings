# this is for windows, not for linux
# .bash_aliases or .zsh_aliases is for linux

##############################################################
# path
##############################################################

dev='/D/dev'

##############################################################
# utils
##############################################################

alias myalias='vim ${HOME}/.bashrc && source ${HOME}/.bashrc'
alias ll='ls -al'

##############################################################
# git
##############################################################

alias g='git'
alias gitconfig='vim ${HOME}/.gitconfig && source ${HOME}/.bashrc'

#############################################
# C#
#############################################
alias dotnet_console='dotnet new console --framework net8.0 --use-program-main'
