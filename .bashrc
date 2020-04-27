# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# This variable is both used to set the current script version
# and parsed to determine the upstream version
OLEO_BASHRC_VERSION=8

# check for updates to this very script
# requires cURL and AWK
# the OLEO_BASHRC_VERSION variable should have been set before this
if [ -z ${OLEO_BASHRC_CHECKED_FOR_UPDATES+x} ]; then
  if type curl > /dev/null 2>&1; then
    if type awk > /dev/null 2>&1; then
      scriptURL="https://tools.richeli.eu/bashrc"
      code=$(curl -sIL $scriptURL 2>/dev/null | awk '/HTTP/' | tail -n 1 | awk '{print $2}')
      if [[ code -ge 200 && code -lt 300 ]];then
        distantVersion=$(curl -sL $scriptURL 2>/dev/null | awk '/OLEO_BASHRC_VERSION/' | awk -F '=' '!/#.*OLEO_BASHRC_VERSION/{print $2; exit;}')
        if [[ $distantVersion -gt $OLEO_BASHRC_VERSION ]]; then
          echo "A newer .bashrc version is available (local: $OLEO_BASHRC_VERSION, distant: $distantVersion)"
          echo "Update at $scriptURL"
        fi
      fi
    fi
  fi
  OLEO_BASHRC_CHECKED_FOR_UPDATES=yes
fi



 ###### #    # #    #  ####  ##### #  ####  #    #  ####  
 #      #    # ##   # #    #   #   # #    # ##   # #      
 #####  #    # # #  # #        #   # #    # # #  #  ####  
 #      #    # #  # # #        #   # #    # #  # #      # 
 #      #    # #   ## #    #   #   # #    # #   ## #    # 
 #       ####  #    #  ####    #   #  ####  #    #  ####  

OLEO_CACHE_DIR="~/.cache/oleo/bashrc"
mkdir -p "$OLEO_CACHE_DIR/bin"
PATH="$PATH:$OLEO_CACHE_DIR/bin"
oleo_bins_in_place=0





# color path depending on Git status
# white  : no git repo
# green  : clean local git repo
# cyan   : clean repo, up to date with a remote
# magenta: clean repo, behind the remote
# red    : clean repo, diverged from the remote
# yellow : git repo, in other cases
# remote info not necessarily up to date


function oleo_get_git_color {

  status=$(git status 2> /dev/null)
  if [ $? -ne 0 ]; then
    echo -n ""
    exit
  fi

  # WARNING this fetches info from remote
  # Everything will work fine if this is commented out
  # It just won't tell you when you're out of date
  #(git fetch -q > /dev/null 2>&1) &

  # fetching continuously can have some surprising side effects
  # for instance --force-with-lease won't work anymore

  # note how this is in the background
  # else it'd take way too much time
  # so the prompt won't get updated right away,
  # but it's still useful if you are staying a bit in the folder
  # (this is also why it is after git status)

  if [[ $status == *"nothing to commit"* ]]; then
    if [[ $status == *"Your branch is up to date with"* ]]; then
      echo -n "$(tput setaf 6)"
    elif [[ $status == *"Your branch is behind"* ]]; then
      echo -n "$(tput setaf 5)"
    elif [[ $status == *"have diverged"* ]]; then
      echo -n "$(tput setaf 1)"
    else
      echo -n "$(tput setaf 2)"
    fi

  else
    echo -n "$(tput setaf 3)"
  fi
}

oleo_terminator="\[$(tput sgr0)\]"



# color depending on exit status
# green  : 0
# red    : 1
# yellow : otherwise
function oleo_get_exit_status_color {
  #(>&2 echo $1)
  if [[ $# != 1 ]]; then
    echo -n ""
  elif [[ $1 == 0 ]]; then
    echo -n "$(tput setab 2)"
    echo -n "$(tput setaf 0)"
  elif [[ $1 == 1 ]]; then
    echo -n "$(tput setab 1)"
  else 
    echo -n "$(tput setab 3)"
    echo -n "$(tput setaf 0)"
  fi
}




if type oleo_get_short_cwd > /dev/null 2>&1; then
  :
else
oleo_bins_in_place=1

function oleo_bash_short_cwd {
  currentwd=$1
  breakchars="./-_ "
  caps="QWERTYUIOPASDFGHJKLZXCVBNM"
  result=""
  currentfolder=""
  shortfolder=""
  for (( i=0; i<=${#currentwd}; i++)); do

    # if [[ "/" == *"${currentwd:$i:1}"* ]];then
    # matches both "" and "/"
    if [[ "/" == "${currentwd:$i:1}" ]];then
      result+=$shortfolder
      currentfolder=""
      shortfolder=""
    fi
    
    if [[ $i -eq ${#currentwd} ]]; then
      result+=$currentfolder
      currentfolder=""
    fi


    currentfolder+="${currentwd:$i:1}"

    if [[ $breakchars == *"${currentwd:$i:1}"* ]]; then # substring check
      if [[ " " != *"${currentwd:$i:1}"* ]]; then
        shortfolder+="${currentwd:$i:1}"
      fi
      iPlusOne=$(($i+1))
      if [[ $i -lt ${#currentwd} && ${currentwd:$iPlusOne:1} != "/" ]];then
        # fixing the "/.git/" -> "/./" problem would either require
        # separating / from the rest of the breakchars
        # or adding a loop here
        # I'm doing it on the python version but I'm burned out on bash here
        ((i++))
        shortfolder+="${currentwd:$i:1}"
        currentfolder+="${currentwd:$i:1}"
      fi
    elif [[ $caps == *"${currentwd:$i:1}"* ]]; then
      shortfolder+="${currentwd:$i:1}"
    fi

  done

  if [[ $currentfolder != "" ]]; then
    result+=$currentfolder
  fi


  echo $result
}

function oleo_get_short_cwd {
  if type python3 &>/dev/null; then
    echo $(python -c """cwd='$1'
breakchars='.-_'
whitespace=' \t\n'
caps='QWERTYUIOPASDFGHJKLZXCVBNM'
result=[]
words = cwd.split('/')
for w in words[:-1]:
	wResult=''
	i=0
	while i<len(w):
		while i<len(w) and w[i] in breakchars:
			if len(wResult) == 0 or w[i] != wResult[-1]:
				wResult+=w[i]
			i+=1
		
		if i>=len(w):
			break
		
		if w[i] in caps and (i==0 or w[i-1] not in caps):
			wResult+=w[i]
		elif (i==0 or w[i-1] in breakchars) and w[i] not in whitespace :
			wResult+=w[i]
		i+=1
	result.append(wResult)
print('/'.join(result)+'/'+words[-1])""")
  else
    echo $(oleo_bash_short_cwd "$1")
  fi
}
fi


if [[ $oleo_bins_in_place -ne 0 ]] ; then
  echo "Some binaries aren't installed, run oleo_install_bins"
  
  function oleo_install_bins
  {
    echo "You may use compiled binaries instead of Bash functions for performance."
    echo "Installing requires Git & DMD or LDC. They'll be placed in $OLEO_CACHE_DIR."
    
    read -p "Download & compile them now? [y/N] " -r OLEO_REPLY
    if [[ $OLEO_REPLY =~ ^[Yy]$ ]]
    then
      echo "To be implemented"
    fi
  }
  
fi




  ####  ###### ##### ##### # #    #  ####   ####  
 #      #        #     #   # ##   # #    # #      
  ####  #####    #     #   # # #  # #       ####  
      # #        #     #   # #  # # #  ###      # 
 #    # #        #     #   # #   ## #    # #    # 
  ####  ######   #     #   # #    #  ####   ####  

# this is because else the functions before get_exit_status_color might overwrite the status code
PROMPT_COMMAND="oleo_exitstatuscode=\$?"
PS1="\[\$(oleo_get_git_color)\]\$(oleo_get_short_cwd $(pwd))$oleo_terminator\[\$(oleo_get_exit_status_color \"\$oleo_exitstatuscode\")\]\$$oleo_terminator " # just the path
#PS1="\u@\h:\[\$(get_git_color)\]\$(get_short_cwd)$terminator\[\$(get_exit_status_color \"\$exitstatuscode\")\]\$$terminator " # uname@hostname:path format
#PS1="\$(get_short_cwd)\$ " # uncolored version










# color stuff

# also adds -h ('human' sizes)
if ls --version >/dev/null 2>&1
then # GNU ls
  alias ls='ls --color=auto -h'
else # BSD ls (where the color flag is -G)
  alias ls='ls -Gh'
fi
alias grep='grep --color=auto'

if diff --version >/dev/null 2>&1
then # GNU diff
  alias diff='diff --color=auto'
fi

# use neovim if it is present
if type nvim > /dev/null 2>&1; then
  alias vi='nvim'
fi

# use thefuck if present (as fu)
if type thefuck > /dev/null 2>&1; then
  eval $(thefuck --alias fu)
fi
  
# vi-like keybindings
set -o vi

# what follow is from https://github.com/mrzool/bash-sensible/blob/master/sensible.bash

# Perform file completion in a case insensitive fashion
bind "set completion-ignore-case on"

# Treat hyphens and underscores as equivalent
bind "set completion-map-case on"

# Display matches for ambiguous patterns at first tab press
bind "set show-all-if-ambiguous on"

# Immediately add a trailing slash when autocompleting symlinks to directories
bind "set mark-symlinked-directories on"

# autocorrect folder names
shopt -s cdspell

# Append to the history file, don't overwrite it
shopt -s histappend

# Save multi-line commands as one command
shopt -s cmdhist

# Record each line as it gets issued
PROMPT_COMMAND=$PROMPT_COMMAND';history -a'


# Huge history. Doesn't appear to slow things down, so why not?
HISTSIZE=500000
HISTFILESIZE=100000

# Avoid duplicate entries
HISTCONTROL="erasedups:ignoreboth"

# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear:true:false"

# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d
# %T equivalent to %H:%M:%S (24-hours format)
HISTTIMEFORMAT='%F %T '

# Enable incremental history search with up/down arrows (also Readline goodness)
# Learn more about this here: http://codeinthehole.com/writing/the-most-important-command-line-tip-incremental-history-searching-with-inputrc/
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\e[C": forward-char'
bind '"\e[D": backward-char'


# enable bash-completion on Mac OS
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# local RC
OLEO_LOCALRC=~/.additional_shellrc
if [[ -f $OLEO_LOCALRC ]]
then
  source $OLEO_LOCALRC
fi