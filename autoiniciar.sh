#!/usr/bin/env bash

sleep 2 && easyeffects --service-mode &
sleep 3 && flatpak run com.bitwarden.desktop &
emacs --daemon &
flatpak run com.super_productivity.SuperProductivity &
~/AppImages/melia* &
flatpak run com.rtosta.zapzap &


# Ocultar Super Productivity y Bitwarden

WAIT_TIMEOUT_MS=30000   # tiempo máximo esperando a que sean visibles
POLL_INTERVAL_MS=200    # cada cuánto revisa si ya son visibles
HIDE_DELAY_MS=500       # tiempo que se quedan visibles antes de ocultarse

sleep_ms() {
  sleep "$(awk -v ms="$1" 'BEGIN { printf "%.3f", ms / 1000 }')"
}

client_visible() {
  mmsg get all-clients | jq -e --arg id "$1" \
    'any(.clients[]; .appid == $id and .is_visible)' >/dev/null
}

hide_when_visible() {
  local appid=$1 cmd=$2 waited=0

  # Espera a que el cliente sea visible
  until client_visible "$appid"; do
    ((waited >= WAIT_TIMEOUT_MS)) && return 1
    sleep_ms "$POLL_INTERVAL_MS"
    ((waited += POLL_INTERVAL_MS))
  done

  sleep_ms "$HIDE_DELAY_MS"

  # Comprueba de nuevo: si ya lo ocultaste a mano, un toggle lo volvería a mostrar
  client_visible "$appid" && mmsg dispatch "$cmd"
}

hide_when_visible superproductivity \
  "toggle_named_scratchpad,superproductivity,none,flatpak run com.super_productivity.SuperProductivity" &

hide_when_visible bitwarden \
  "toggle_named_scratchpad,bitwarden,none,flatpak run com.bitwarden.desktop" &

wait
