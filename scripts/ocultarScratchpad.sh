#!/usr/bin/bash

# Ocultar Scratchpads de MangoWM.

# Su utilidad es para cuando se lanzan aplicaciones al inicio
# que de a huevo quieren mostrar una ventana visible. Este script
# vuelve a ocultar estas ventanas, minimizando su scratchpad.

# Espera un tiempo en ms
sleep_ms() {
	sleep "$(awk -v ms="$1" 'BEGIN { printf "%.3f", ms / 1000 }')"
}

# Detecta cuando una ventana es visible
client_visible() {
	mmsg get all-clients | jq -e --arg app "$1" \
		'any(.clients[]; .appid == $app and .is_visible)' >/dev/null
}

uso() {
	cat <<EOF
Uso: ${0##*/} -a appid [-d retraso] [-t timeout] [-p sondeo]

Espera a que la ventana de 'appid' sea visible y la oculta con el scratchpad.
Todos los tiempos son en MILISEGUNDOS.

  -a  appid de la aplicación (obligatorio)
  -d  tiempo que permanece visible antes de ocultarse (defecto: $HIDE_DELAY)
  -t  tiempo máximo esperando a que sea visible       (defecto: $WAIT_TIMEOUT)
  -p  cada cuánto revisa si ya es visible             (defecto: $POLL_INTERVAL)
  -h  muestra esta ayuda
EOF
}

# Función que realiza el proceso de ocultado
hide_when_visible() {
	local waited appid=$1 delay=$2 timeout=$3 interval=$4

	# Espera a que el cliente sea visible
	until client_visible "$appid"; do
		((waited >= timeout)) && return 1
		sleep_ms "$interval"
		((waited += interval))
	done

	sleep_ms "$delay"

	# Comprueba de nuevo: si ya lo ocultaste a mano, un toggle lo volvería a mostrar
	client_visible "$appid" &&
		mmsg dispatch toggle_named_scratchpad,"$appid"
}

APPID=""
HIDE_DELAY=500     # tiempo visibles antes de ocultarse
WAIT_TIMEOUT=30000 # tiempo máximo esperando a ser visibles
POLL_INTERVAL=200  # cada cuánto revisa si ya son visibles

while getopts "a:d:t:p:h" o; do
	case $o in
	a) APPID=$OPTARG ;;
	d) HIDE_DELAY=$OPTARG ;;
	t) WAIT_TIMEOUT=$OPTARG ;;
	p) POLL_INTERVAL=$OPTARG ;;
	h)
		uso
		exit 0
		;;
	*)
		uso >&2
		exit 1
		;;
	esac
done

[[ -n $APPID ]] || {
	echo "Error: falta -a APPID" >&2
	uso >&2
	exit 1
}

for v in "$HIDE_DELAY" "$WAIT_TIMEOUT" "$POLL_INTERVAL"; do
	[[ $v =~ ^[0-9]+$ ]] || {
		echo "Los tiempos deben ser enteros (ms)" >&2
		exit 1
	}
done
((10#$POLL_INTERVAL > 0)) || {
	echo "-p debe ser mayor que 0" >&2
	exit 1
}

hide_when_visible "$APPID" "$HIDE_DELAY" "$WAIT_TIMEOUT" "$POLL_INTERVAL"
