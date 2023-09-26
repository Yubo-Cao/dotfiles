#!/usr/bin/env bash

TASK=$1

print_help() {
    echo "Usage: get-network.sh [help, ssid, signal]"
    echo "  help: show this message"
    echo "  ssid: show the SSID of the current network"
    echo "  signal: show the signal strength of the current network"
}

MEMBER="changed"
INTERFACE="org.freedesktop.portal.NetworkMonitor"

_get_strength() {
    if [[ $(nmcli networking connectivity) == "full" ]]; then
        signal=$(nmcli device wifi list | awk '/\*/ {print $8}')
        echo "$signal"
    else
        echo "No network"
    fi
}

get_strength() {
    _get_strength
    dbus-monitor --profile "interface='$INTERFACE',member='$MEMBER'" |
        while read -r line; do
            _get_strength
        done
}

_get_ssid() {
    if [[ $(nmcli networking connectivity) == "full" ]]; then
        ssid=$(nmcli device wifi list | awk '/\*/ {print $3}')
        echo "$ssid"
    else
        echo "No network"
    fi
}

get_ssid() {
    _get_ssid
    dbus-monitor --profile "interface='$INTERFACE',member='$MEMBER'" |
        while read -r line; do
            _get_ssid
        done
}

case $TASK in
ssid)
    get_ssid
    ;;
signal)
    get_strength
    ;;
help)
    print_help
    exit 0
    ;;
*)
    echo "Invalid argument"
    print_help
    exit 1
    ;;
esac
