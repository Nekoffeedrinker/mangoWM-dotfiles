#!/usr/bin/env bash

# flameshot &
sleep 2 && easyeffects --service-mode &
sleep 3 && flatpak run com.bitwarden.desktop &
emacs --daemon &
flatpak run com.super_productivity.SuperProductivity &
~/AppImages/melia* &
flatpak run com.rtosta.zapzap &
