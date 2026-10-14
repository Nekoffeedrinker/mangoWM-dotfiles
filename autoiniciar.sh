#!/usr/bin/bash

sleep 2 && easyeffects --service-mode &
sleep 3 && flatpak run com.bitwarden.desktop &
emacs --daemon &
flatpak run com.super_productivity.SuperProductivity &
~/AppImages/melia* &
flatpak run com.rtosta.zapzap &

~/.config/mango/scripts/ocultarScratchpad.sh -a bitwarden &
~/.config/mango/scripts/ocultarScratchpad.sh -a superproductivity &
