#YAY
alias c="clear"
alias update="yay -Syu"
alias install="yay -S"
alias i="yay -S"
alias remove="yay -Rns"
alias r="yay -Rns"
alias search="yay -s"
alias cleanup="sudo pacman -Rns $(pacman -Qtdq)"

alias god="sudo"

#EZA
alias ls='eza -al --color=always --group-directories-first --icons' # preferred listing
alias la='eza -a --color=always --group-directories-first --icons' # all files and dirs
alias ll='eza -l --color=always --group-directories-first --icons' # long format
alias lt='eza -aT --color=always --group-directories-first --icons' # tree listing
alias ldot="eza -a | grep -e '^\.'" # show only dotfiles