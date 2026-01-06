#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/hyprlab/scripts/data/conf.env"

set_couleur_fish() {
  hyprlab message info "Setting up fish theme"

  if ! command -v fish >/dev/null; then
    hyprlab message fail "Fish is not installed"
    exit 1
  fi

  printf "y\n" | fish -c "fish_config theme save current" >/dev/null 2>&1 
  hyprlab message ok "Successfully applied fish theme"
}

set_couleur_fish

