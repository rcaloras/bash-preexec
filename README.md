Bash-Preexec
============

Zsh style preexec and precmd functions for Bash.

Usage as described for Zsh http://zsh.sourceforge.net/Doc/Release/Functions.html#Hook-Functions

##Install
```bash
# Pull down our file from github and write it to our home directory as a hidden file.
curl -o ~/.bash-preexec.sh https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh
# Source our file at the end of our bash profile (e.g. ~/.bashrc, ~/.profile, or ~/.bash_profile)
echo '[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh' >> ~/.bashrc
```

##Usage
You can now define functions and have them invoked by these hooks by appending them to two different arrays. Either **preexec_functions** or **precmd_functions** for their respective commands.
####preexec
```bash
# Define some function to use preexec
preexec_hello_world() { echo "You just entered $1"; }
# Add it to the array of functions to be invoked each time.
preexec_functions+=(preexec_hello_world)
```
####precmd
````bash
precmd_hello_world() { echo "This is invoked before the prompt is displayed"; }
precmd_functions+=(precmd_hello_world)
```
You can also define multiple functions to be invoked like so.
```bash
precmd_hello_one() { echo "This is invoked on precmd first"; }
precmd_hello_two() { echo "This is invoked on precmd second"; }
precmd_functions+=(precmd_hello_one)
precmd_functions+=(precmd_hello_two)
```






