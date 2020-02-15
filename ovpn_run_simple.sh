#!/bin/bash

#
# Run the OpenVPN server normally
#

if [ "$DEBUG" == "1" ]; then
  set -x
fi

set -e

cd $OPENVPN

# Build runtime arguments array based on environment
USER_ARGS=("${@}")
ARGS=()

# Checks if ARGS already contains the given value
function hasArg {
    local element
    for element in "${@:2}"; do
        [ "${element}" == "${1}" ] && return 0
    done
    return 1
}

# Adds the given argument if it's not already specified.
function addArg {
    local arg="${1}"
    [ $# -ge 1 ] && local val="${2}"
    if ! hasArg "${arg}" "${USER_ARGS[@]}"; then
        ARGS+=("${arg}")
        [ $# -ge 1 ] && ARGS+=("${val}")
    fi
}

# set up iptables rules and routing
# this allows rules/routing to be altered by supplying this function
# in an included file, such as ovpn_env.sh
function setupIptablesAndRouting {
    iptables -t nat -C POSTROUTING -s $OVPN_SERVER -o $OVPN_NATDEVICE -j MASQUERADE || {
      iptables -t nat -A POSTROUTING -s $OVPN_SERVER -o $OVPN_NATDEVICE -j MASQUERADE
    }
    for i in "${OVPN_ROUTES[@]}"; do
        iptables -t nat -C POSTROUTING -s "$i" -o $OVPN_NATDEVICE -j MASQUERADE || {
          iptables -t nat -A POSTROUTING -s "$i" -o $OVPN_NATDEVICE -j MASQUERADE
        }
    done
}


addArg "--config" "$OPENVPN/server.conf"
addArg "--cd" "$OPENVPN"

if [ -f "$OPENVPN/ovpn_env.sh" ]; then
    echo "ENV file found!"
    source "$OPENVPN/ovpn_env.sh"
fi

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

echo "Running 'openvpn ${ARGS[@]} ${USER_ARGS[@]}'"
exec openvpn ${ARGS[@]} ${USER_ARGS[@]}
