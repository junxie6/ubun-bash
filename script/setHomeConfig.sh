#!/bin/bash

symbolicFileArr=".bashrc .bash_profile .inputrc .vim .vimrc .tmux.conf .gitconfig git-completion.bash git-prompt.sh"

for file in ${symbolicFileArr}; do
  /bin/rm -rf ~/${file}
  /bin/ln -s ~/ubun-bash/${file} ~/${file}
done

/bin/rm -rf ~/.vimbak
/bin/mkdir ~/.vimbak
/bin/chmod 700 ~/.vimbak

source ~/.bash_profile

