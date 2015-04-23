# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# Equivalent to `whoami`
DEFAULT_USER=`id -un`

# Exports
export EDITOR="vim" # Use vim as editor
export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin #:~/Library/Android/sdk/tools:~/Library/Android/sdk/platform-tools:~/.bin

# Aliases
alias zshconfig="st ~/.zshrc"
alias zprezto="stt ~/.zprezto"
alias zsource="source ~/.zshrc"
alias zup="git -C ~/.zprezto pull && git -C ~/.zprezto submodule update --init --recursive"
alias clr="rm -f ~/.zhistory;tab;exit"
alias py="python3"
alias adbt="adb connect 192.168.43.1"
alias brewup="echo 'Updating brew formulae...';brew update;echo 'Upgrading brew packages...';brew upgrade;echo 'Cleaning up...';rm -rf $(brew --cache)"
alias csl="ssh -t 2015etsung@remote.tjhsst.edu ssh\ wall"
alias printers="lpstat -a"
alias ll="ls -aFhl"
alias -g ...="../.."
alias -g ....="../../.."
alias -g .....="../../../.."

# Directory hashes
hash -d cs=~/Documents/School/Computer\ Sys
hash -d repo=~/Documents/Repo
hash -d school=~/Documents/School
hash -d trash=~/.Trash

# Command functions
cps() {
	local printer=accepting
	if [[ -n $1 ]]; then
		if [[ $1 -eq '-help' ]]; then
			echo "usage: cspr [printer]"
			return
		fi
		printer=$1
	fi
	ssh -t 2015etsung@remote.tjhsst.edu "ssh -t wall 'lpstat -a'" | grep $printer
}

cscp() {
	if [[ -n $1 ]]; then
		if [[ -n $2 ]]; then
			echo "Sending to folder $2"
			scp $1 2015etsung@remote.tjhsst.edu:$2
		else
			echo "Defaulting to ~/Documents folder."
			scp $1 2015etsung@remote.tjhsst.edu:Documents
		fi
	else
		echo "usage: cscp local_file [remote_directory]"
	fi
}

cpr() {
	local printer=Room_200
	if [[ -n $1 ]]; then
		if [[ -n $2 ]]; then
			printer=$2
		else
			echo Printing to Room_200.
		fi
		ssh -t 2015etsung@remote.tjhsst.edu "ssh -t wall \"lpr -P $printer $1\""
	else
		echo "usage: cpr remote_file [printer]"
	fi
}

csprint() {
	local printer=Room_200
	local remote_directory=Documents
	local file_name=Error
	if [[ -n $1 ]]; then
		if [[ -n $2 ]]; then
			if [[ -n $3 ]]; then
				remote_directory=$2
				printer=$3
				echo "Sending to folder $2"
				echo "Printing to $3"
			else
				printer=$2
				echo "Defaulting to ~/Documents"
				echo "Printing to $2"
			fi
		else
			echo "Defaulting to ~/Documents"
			echo "Printing to Room_200"
		fi
		file_name=$1

		echo "===Sending File==="
		scp $file_name 2015etsung@remote.tjhsst.edu:$remote_directory
		echo "=====Printing====="
		file_name=${${file_name//\ /\\ }##*/} # insert another "\" before spaces
		ssh -t 2015etsung@remote.tjhsst.edu "ssh -t wall \"lpr -P $printer $remote_directory/$file_name\""
	else
		echo "usage: csprint local_file [printer|remote_directory printer]"
	fi
}
