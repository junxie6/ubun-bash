# .bashrc

# User specific aliases and functions
MyOS=$(awk -F '=' '/^ID=/ {print $2}' /etc/os-release | tr -d '"')

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias gs='git status'
alias gb='git branch'
alias gco='git checkout'
#alias gc='git commit -a -m "fix"'
alias gc='git commit -a'
#alias gcm='git commit -a --amend'
alias gd='git diff --no-prefix'
alias gds='git diff --no-prefix --ignore-all-space'
alias gp='git push'
alias gu='git add -u && git commit -m "up"'
alias gt='git tree'
alias gm='git merge --strategy-option=ignore-all-space --no-commit'
alias gf='git fsck'

alias ls='ls --color=auto'
alias ll='ls -la'
alias h='history'
alias d='TZ=America/Vancouver date +"%m/%d/%Y %T"'

alias setdevmod='find . | xargs -I {} chown dev:dev {} ; find . -type d | xargs -I {} chmod 770 {} ; find . -type f | xargs -I {} chmod 660 {} ; find . | xargs -I {} chcon -R -t httpd_sys_rw_content_t {}'

alias g='grep -rIn --exclude="*\.svn*" --exclude-dir=".git" --exclude-dir="vendor" --exclude-dir="node_modules"'
alias gg='grep -rIin --exclude="*\.svn*" --exclude-dir=".git" --exclude-dir="vendor" --exclude-dir="node_modules"'

alias jr='git co next && git pull && git co JH-dev && git rebase --strategy-option=ignore-all-space next'
alias jm='git co next && git merge JH-dev && git push && git co JH-dev'

alias nr='git co master && git pull && git co next && git rebase --strategy-option=ignore-all-space master'
alias nm='git co master && git merge next && git push && git co JH-dev'

alias nro='git co next && git fetch && git rebase --strategy-option=ignore-all-space origin/next && git push && git co JH-dev && git rebase --strategy-option=ignore-all-space next'

alias nvim='VIMRUNTIME=/usr/local/share/nvim/runtime /usr/local/bin/nvim'

alias py='source ~/.venv/mysite/bin/activate && cd ~/pyproj/mysite'

#!/bin/bash
# go-objdump colorizes and reformats output of `go tool objdump`
# - it inserts an empty line after unconditional control-flow modifying instructions (JMP, RET, UD2)
# - it colors calls/returns in green
# - it colors traps (UD2) in red
# - it colors jumps (both conditional and unconditional) in blue
# - it colors padding/nops in violet
# - it colors the function name in yellow
# - it unindent the function body
go-objdump() {
         go tool objdump "$@" |
                gsed -E "
                        s/^  ([^\t]+)(.*)/\1  \2/
                        s,^(TEXT )([^ ]+)(.*),$(tput setaf 3)\\1$(tput bold)\\2$(tput sgr0)$(tput setaf 3)\\3$(tput sgr0),
                        s/((JMP|RET|UD2).*)\$/\1\n/
                        s,.*(CALL |RET).*,$(tput setaf 2)&$(tput sgr0),
                        s,.*UD2.*,$(tput setaf 1)&$(tput sgr0),
                        s,.*J[A-Z]+.*,$(tput setaf 4)&$(tput sgr0),
                        s,.*(INT \\\$0x3|NOP).*,$(tput setaf 5)&$(tput sgr0),
                        "
}

sshtunnel() {
  ssh -p 22 -NnT -L 127.0.0.1:8443:127.0.0.1:8443 username@example.com
}

staticcheckall() {
  staticcheck -checks=all -show-ignored -unused.whole-program ./...
}

gosecless() {
  gosec -fmt=json -out=gosec-results.json ./... ; less gosec-results.json
}

gorun() {
  go mod vendor -v && go run -v -mod vendor "$@"
}

curljson() {
  curl -s "$@" | python -m json.tool
}

gitlog() {
  curl -s https://api.github.com/repos/$1/commits
}

sshkey_gen() {
  if [ -f ~/.ssh/id_rsa ]; then
    echo "~/.ssh/id_rsa already exists"
    return "$?"
  fi

  if [ -z "$1" ]; then
    echo "Please provide an email"
    return "$?"
  fi

  ssh-keygen -t rsa -C "$1"
  return "$?"
}

sshkey_show() {
  if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "~/.ssh/id_rsa.pub does not exist"
    return "$?"
  fi

  cat ~/.ssh/id_rsa.pub
  return "$?"
}

sshkey_push() {
  if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "~/.ssh/id_rsa.pub does not exist"
    return "$?"
  fi

  if [ -z "$1" ]; then
    echo "Please provide a remote login user@host."
    return "$?"
  fi

  cat ~/.ssh/id_rsa.pub | ssh "$1" "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"
  return "$?"
}

sshkey() {
  case "$1" in
    gen)
      sshkey_gen "$2"
      ;;
    show)
      sshkey_show
      ;;
    push)
      sshkey_push "$2"
      ;;
    *)
      echo command not found
      ;;
  esac
}

genMakefile() {
  /bin/cp -i ~/config_centos_v2/MakefileTemplate ./Makefile
}

genSSLCert() {
	# Generate a Self-Signed Certificate:
	openssl req -newkey rsa:2048 -nodes -subj "/C=CA/ST=BC/L=Vancouver/O=Example Company/CN=example.com" -keyout mydomain.key -x509 -days 365 -out mydomain.crt
}

genpass() {
	openssl rand 60 | openssl base64 -A
	echo ""
}

mydb() {
  case "$1" in
    createDB)
      mysql -e "CREATE DATABASE $2 DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci;"
      ;;
    createUser)
      mysql -e "CREATE USER $2 IDENTIFIED BY '$3';"
      ;;
    grantUser)
      mysql -e "GRANT ALL ON $2 TO $3;"
      ;;
    *)
      echo command not found
      ;;
  esac
}

updateGo() {
	sudo -u root sh -s "$@" <<'EOF'
rm -rf /usr/local/go && curl -L "https://dl.google.com/go/go$@.linux-amd64.tar.gz" -o go.tar.gz && tar -zxvf go.tar.gz -C /usr/local && rm -f go.tar.gz
EOF
	#sudo -- sh -c 'rm -rf /usr/local/go && curl -L "https://dl.google.com/go/go$@.linux-amd64.tar.gz" -o go.tar.gz && tar -zxvf go.tar.gz -C /usr/local && rm -f go.tar.gz'
}

time2date() {
  date -d @"$@"
}

hexdec() {
  echo $(( 0x$( echo "$@" | tr -d "[:space:]" | fold -w2 | tac | tr -d "\n" ) ))
  # Note: remove spaces, new line every two characters, concatenate and print files in reverse, remove newlines
}

hexdatetime() {
  date -d @$( hexdec "$@")
}

strhex() {
  echo -n "$@" | od -A n -t x1
}

ndbdisk() {
  mysql -e "SELECT extra, (SUM(initial_size) / 1048576) AS InitMB, (SUM(free_extents * extent_size) / 1048576) as FreeMB, (SUM(free_extents) / SUM(total_extents) * 100) AS 'Free%', (SUM(total_extents * extent_size) / 1048576) as TotalMB FROM information_schema.files WHERE file_type = 'DATAFILE' GROUP BY extra ORDER BY extra;"
}

ndbdisklist() {
  mysql -e "SELECT extra, file_name, status, (initial_size / 1048576) AS InitMB, (free_extents * extent_size / 1048576) as FreeMB, (free_extents / total_extents * 100) AS 'Free%', (total_extents * extent_size / 1048576) as TotalMB, data_length, index_length FROM information_schema.files WHERE file_type = 'DATAFILE' ORDER BY extra, file_name;"
}

video2gif() {
  # -ss option sets the start time offset (seconds)
  # -t option sets the record or transcode "duration" seconds of audio/video
  # fps filter sets the frame rate. A rate of 10 frames per second is used in the example.
  # scale filter will resize the output to 320 pixels wide and automatically determine the height while preserving the aspect ratio. The lanczos scaling algorithm is used in this example.
  # palettegen and paletteuse filters will generate and use a custom palette generated from your input. These filters have many options, so refer to the links for a list of all available options and values. Also see the Advanced options section below.
  # split filter will allow everything to be done in one command and avoids having to create a temporary PNG file of the palette.
  # Control looping with -loop output option but the values are confusing. A value of 0 is infinite looping, -1 is no looping, and 1 will loop once meaning it will play twice. So a value of 10 will cause the GIF to play 11 times.
  # NOTE: https://superuser.com/questions/556029/how-do-i-convert-a-video-to-gif-using-ffmpeg-with-reasonable-quality
  echo 'Example: file=input.mp4 width=900 video2gif' \
  && (test -n "${file}" || (echo ">> width flag is not set. e.g. file=myVideo.mp4"; exit 1)) \
  && (test -n "${width}" || (echo ">> width flag is not set. e.g. width=900"; exit 1)) \
  && ffmpeg -i "${file}" -vf "fps=10,scale=${width}:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 output.gif
}

dlog() {
  docker-compose logs "$@"
}

dswarmmode() {
  if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = "active" ]; then
    echo "active"
  fi
}

drebuild() {
    docker-compose rm -sf "$@" && docker-compose up -d --no-deps --build "$@"
}

drestart() {
  docker-compose restart "$@"
}

dstart() {
  docker-compose start "$@"
}

dstop() {
  docker-compose stop "$@"
}

ddown() {
  docker-compose down "$@"
}

dnet() {
  docker network "$@"
}

dsave() {
  tag=$(sed -r 's/[/:]+/_/g' <<< "$@")
  docker save "$@" | xz -zc - > ${tag}.tar.xz
}

dload() {
  docker load < "$@"
}

dvol() {
  docker volume "$@"
}

dvolrmold() {
  docker volume rm $(docker volume ls -q -f dangling=true)
}

dcp() {
  docker cp "$@"
}

dps() {
  docker ps "$@"
}

drmc() {
  docker-compose rm -sf "$@"
}

drmcexit() {
  docker rm $(docker container ls -q -f "status=exited")
}

dimg() {
  docker images "$@"
}

dimgrm() {
  docker rmi "$@"
}

dimgrmold() {
  docker rmi $(docker images -q -f dangling=true --no-trunc)
}

dexec() {
  docker-compose exec -e TERM=$TERM -e LINES=$LINES -e COLUMNS=$COLUMNS "$@"
}

dexec2() {
  docker exec -it -e TERM=$TERM -e LINES=$LINES -e COLUMNS=$COLUMNS "$@"
}

showFunDef() {
  typeset -f "$@"
}

showFunDefV2() {
  type "$@"
}

psLong() {
	ps auxww
}

generateRandomString() {
	gpg --gen-random --armor 1 512 | tr -d '=' | fold -w1 | shuf | tr -d '\n' | head -c 5
}

psTree() {
	ps -axfo pid,ppid,uname,cmd
}

### Reference: https://unix.stackexchange.com/questions/99334/how-to-fill-90-of-the-free-memory
memoryFillIn() {
  if [[ $# -eq 0 || $1 -eq '-h' || $1 -lt 0 ]]; then
    echo -e "usage: memoryFillIn N\n\nAllocate N mb, wait, then release it."
  else
    N=$(free -m | grep Mem: | awk '{print int($2/10)}')
    if [[ $N -gt $1 ]]; then
      N=$1
    fi
    sh -c "MEMBLOB=\$(dd if=/dev/urandom bs=1MB count=$N) ; sleep 1"
  fi
}

# This prints the file count per directory for the current directory level
# NOTE: https://stackoverflow.com/questions/15216370/how-to-count-number-of-files-in-each-directory
showTopDirectoryFilesCountFirstLevel() {
  du -a | sed '/.*\.\/.*\/.*/!d' | cut -d/ -f2 | sort | uniq -c | sort -nr
}

# NOTE: https://unix.stackexchange.com/questions/122854/find-the-top-50-directories-containing-the-most-files-directories-in-their-first
showTopDirectoryFilesCountAnyLevelV1() {
  find . -xdev -type d -print0 |
    while IFS= read -d '' dir; do
      echo "$(find "$dir" -maxdepth 1 -print0 | grep -zc .) $dir"
    done |
    sort -rn |
    head -20
}

# NOTE: https://unix.stackexchange.com/questions/122854/find-the-top-50-directories-containing-the-most-files-directories-in-their-first
showTopDirectoryFilesCountAnyLevelV2() {
  du --inodes -S | sort -rh | sed -n '1,20{/^.\{71\}/s/^\(.\{30\}\).*\(.\{37\}\)$/\1...\2/;p}'
}

# To find how many open files are opened at any given time:
showOpenFilesCount() {
  echo -e "TotalAllocatedFilesSinceBoot\tTotalFreeAllocated\tMaxOpenFileDescriptors"
  cat /proc/sys/fs/file-nr
}

# MAX file watches allowed on system
showMaxFilesWatchAllowed() {
  cat /proc/sys/fs/inotify/max_user_watches
}

# Current files in project - excluding node_modules:
showNumOfFilesExcludeNodeModules() {
  find . -type f -not -path '**/node_modules/**' | wc -l
}

showTopProcsOpenFiles() {
  echo 'pid count'
  sudo -u root sh -s <<'EOF'
ps aux | sed 1d | awk '{print "fd_count=$(lsof -w -p " $2 " | wc -l) && echo " $2 " $fd_count"}' | xargs -I {} bash -c {} | sort -r -n -k 2 | head -n 30
EOF
}

# Get the procs sorted by the number of inotify watchers
#
# From `man find`:
#    %h     Leading directories of file's name (all but the last element).  If the file name contains no slashes  (since  it
#           is in the current directory) the %h specifier expands to `.'.
#    %f     File's name with any leading directories removed (only the last element).
#
# Update number of watches setting:
#
# echo fs.inotify.max_user_watches=19456 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
#
# NOTE: https://github.com/fatso83/dotfiles/blob/master/utils/scripts/inotify-consumers
# NOTE: https://unix.stackexchange.com/questions/15509/whos-consuming-my-inotify-resources/426001#426001
# NOTE: https://unix.stackexchange.com/questions/117093/find-where-inodes-are-being-used
showTopProcsINotifyWatcher() {
  lines=$(
      find /proc/*/fd \
      -lname anon_inode:inotify \
      -printf '%hinfo/%f\n' 2>/dev/null \
      \
      | xargs grep -c '^inotify'  \
      | sort -n -t: -k2 -r \
      )

  printf "\n%10s\n" "INOTIFY"
  printf "%10s\n" "WATCHER"
  printf "%10s  %5s     %s\n" " COUNT " "PID" "CMD"
  printf -- "----------------------------------------\n"
  for line in $lines; do
      watcher_count=$(echo $line | sed -e 's/.*://')
      pid=$(echo $line | sed -e 's/\/proc\/\([0-9]*\)\/.*/\1/')
      cmdline=$(ps -w -w --columns 120 -o command -h -p $pid)
      printf "%8d  %7d  %s\n" "$watcher_count" "$pid" "$cmdline"
  done
}

showOpenFiles() {
  if [[ $# -eq 0 || "$1" = "-h" ]]; then
    echo -e "usage: showOpenFiles ProcessName"
    return 1
  fi

  sudo lsof -w -p $(pidof $@ | tr ' ' ',')
}

showTopOpenFileDescriptors() {
  echo 'pid count'
  sudo -u root sh -s <<'EOF'
ps aux | sed 1d | awk '{print "fd_count=$(find /proc/" $2 "/fd | wc -l) && echo " $2 " $fd_count"}' | xargs -I {} bash -c {} | sort -r -n -k 2 | head -n 30
EOF
}

showOpenFileDescriptors() {
  if [[ $# -eq 0 || "$1" = "-h" ]]; then
    echo -e "usage: showOpenFileDescriptors ProcessName"
    return 1
  fi

  for pid in $(pidof $@); do find /proc/${pid}/fd -not -type d; done
}

showOpenFileDescriptorsLimit() {
  if [[ $# -eq 0 || "$1" = "-h" ]]; then
    echo -e "usage: showOpenFileDescriptorsLimit ProcessName"
    return 1
  fi

  for pid in $(pidof $@); do cat /proc/${pid}/limits | grep -E '^Limit|^Max open files' ; done
}

showMemoryUsage() {
  if [[ $# -eq 0 || "$1" = "-h" ]]; then
    echo -e "usage: showMemoryUsage ProcessName"
    return 1
  fi

  for pid in $(pidof $@); do echo 'pid: ' ${pid} && cat /proc/${pid}/status | grep -E 'VmSize|VmRSS' ; done
}

showSwapUsage() {
  find /proc -maxdepth 2 -path "/proc/[0-9]*/status" -readable -exec \
  awk '/\<Pid\>|\<Name\>|\<VmSwap\>/{printf "%s %s", $2, $3}END{ print "" }' {} \; | \
  awk '{printf "%10s %-20s %10s%s\n", $2, $1, $3, $4}' | \
  sort -h -k 3 -r | head -n 10
}

pid2name() {
  if [[ $# -eq 0 || $1 -eq '-h' || $1 -lt 0 ]]; then
    echo -e "usage: pid2name pid"
    return 1
  fi

  echo $(pmap $1)

  echo $(cat /proc/$1/cmdline)

  echo $(cat /proc/$1/comm)

  # NOTE: readlink - print resolved symbolic links or canonical file names.
  echo $(sudo readlink /proc/$1/exe)
}

# find and rename .git directory to .gitORIG
gitrename() {
  /bin/find . -type d -name ".git" -exec /bin/rename "git" "gitORIG" '{}' +

  # with xargs version:
  #/bin/find . -type d -name ".git" -print0 | xargs --null -I {} mv {} {}ORIG
}

# Find text in file. Usage:
#
# f go -i mytext
#
# Syntax     Effective result
# $*	     $1 $2 $3 … ${N}
# $@	     $1 $2 $3 … ${N}
# "$*"	     "$1c$2c$3c…c${N}"
# "$@"	     "$1" "$2" "$3" … "${N}"
# NOTE: https://stackoverflow.com/questions/12314451/accessing-bash-command-line-args-vs
# NOTE: https://stackoverflow.com/questions/10569198/bash-take-the-first-command-line-argument-and-pass-the-rest
# NOTE: https://wiki.bash-hackers.org/scripting/posparams
#
# NOTE: The difference between ; and  + is that
# NOTE: with \; a single grep command for each file is executed whereas
# NOTE: with + as many files as possible are given as parameters to grep at once.
#
# NOTE: Use $@ to get all arguments.
# NOTE: Use grep --color=always | less -R to see the color highlight.
# NOTE: escaped here as \; to prevent the shell from interpreting it
# NOTE: https://unix.stackexchange.com/questions/12902/how-to-run-find-exec
# NOTE: https://stackoverflow.com/questions/4210042/how-to-exclude-a-directory-in-find-command
# NOTE: https://stackoverflow.com/questions/6085156/using-semicolon-vs-plus-with-exec-in-find
f() {
  fileExt=$1

  # Take the first command line argument and pass the rest.
  # shift is a shell builtin that operates on the positional parameters. Each time you invoke shift, it "shifts" all the positional parameters down by one. $2 becomes $1, $3 becomes $2, $4 becomes $3, and so on
  shift

  # gnu find can handle mutliple filenames at once too (if ended with + instead of ;).
  # For example: find . -name "*.go" -exec grep --color $1 -- '{}' + 
  # A double dash  --  can  also be used to signal that any remaining arguments are not options.
  /usr/bin/find . -type d -and \( -name .git -or -name .svn -or -name vendor -or -name node_modules \) -prune -or -type f -name "*.${fileExt}" -exec grep --color -InH "$@" -- '{}' +

  # With xargs version:
  #/bin/find . -type d -and \( -name .git -or -name vendor \) -prune -o -type f -name "*.go" -print0 | xargs -0 -I {} grep --color -InH "$1" {}

  # The other similar way:
  #find . -type d "(" -name .git -o -name .svn ")" -prune -o -type f -exec ls -ld1 {} +
  #find . -type d '(' -name .git -o -name .svn ')' -prune -o -type f -exec ls -ld1 {} +
  #find . -type d \( -name .git -o -name .svn \) -prune -o -type f -exec ls -ld1 {} +
  #find . -name .svn -prune -o -name .git -prune -o -type f -exec ls -l {} +
}

ff() {
  fileExt=$1
  shift
  /usr/bin/find . -type d -and \( -name .git -or -name .svn -or -name vendor -or -name node_modules \) -prune -or -type f -name "*.${fileExt}" -exec grep --color -IinH "$@" -- '{}' +
}

svn() {
	### Run svn command on behalf of webdev user.
	### Note: $@ passes the arguments to a subshell.
	/usr/bin/sudo -u webdev /bin/bash -c '/usr/bin/svn --no-auth-cache --username $SUDO_USER "$@"' -- "$@"
}

# A righteous umask
if [[ $EUID -ne 0 ]]; then
  umask 0027
fi

### default editor
case "$MyOS" in
    centos|redhat)
		export EDITOR=/bin/vim;;
    ubuntu|debian)
		export EDITOR=/usr/bin/vim;;
esac

### Set up a clean UTF-8 environment
### Run the "locale" or "locale -v -a" command to verify.
case "$MyOS" in
    centos|redhat|ubuntu|debian)
		export LC_ALL="en_US.UTF-8";;
esac

export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

### display history command with date and time
export HISTTIMEFORMAT="%m/%d/%Y %T "

### Color prompt
if [[ $EUID -ne 0 ]]; then
  PS1='\[\e[0;33m\]\u@\h \w \$\[\e[0m\] '
else
  PS1='\[\e[0;32m\]\u@\h \w \$\[\e[0m\] '
fi

# Source the git bash completion file
if [ -f ~/git-completion.bash ]; then
	source ~/git-completion.bash
	source ~/git-prompt.sh

	if [[ $EUID -ne 0 ]]; then
		PS1='\[\e[0;33m\]\u@\h \w\[\e[0m\]\[\e[0;31m\]$(__git_ps1 " %s")\[\e[0m\] \[\e[0;33m\]\$\[\e[0m\] '
	else
		PS1='\[\e[0;32m\]\u@\h \w\[\e[0m\]\[\e[0;31m\]$(__git_ps1 " %s")\[\e[0m\] \[\e[0;32m\]\$\[\e[0m\] '
	fi
fi

### For GPG2
export GPG_TTY=$(tty)

#######
# Note: on Ubuntu, xterm-256color may be in different place, try this:
# find /lib/terminfo /usr/share/terminfo -name "*256*"
# Note: tmux respects screen-256color
#######

#MyTerm=""
#
#case "$MyOS" in
#    debian|ubuntu)
#        MyTerm="/lib/terminfo/x/xterm-256color";;
#    centos|redhat)
#        MyTerm="/usr/share/terminfo/x/xterm-256color";;
#esac
#
#if [[ -e $MyTerm ]]; then
#  export TERM="xterm-256color"
#else
#  export TERM="xterm-color"
#fi

### Make bash check its window size after a process completes
shopt -s checkwinsize

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

### command auto completion for Angular
NG_COMMANDS="add build config doc e2e generate help lint new run serve test update version xi18n"
complete -W "$NG_COMMANDS" ng

###
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

