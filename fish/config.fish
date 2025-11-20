source $HOME/.config/hyprlab/fish/alias.fish

set -gx PATH $PATH $HOME/.cargo/bin 
set -gx PATH $PATH $HOME/.local/bin 
set -gx PATH $PATH $HOME/.npm-global/bin

starship init fish | source 