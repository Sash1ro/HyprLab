#!/usr/bin/env bash

$TERMINAL --title "fastfetch" --class "float" sh -c "tput civis; fastfetch; read -n 1 -s -r -p ''; tput cnorm"