#!/usr/bin/env bash
# Derivative variables and templates function, shared by the scripts
source /vagrant/config/vars.env
PRIMARY_IP="$NET.$PRIMARY_LAST"
SECONDARY_IP="$NET.$SECONDARY_LAST"
REV_ZONE=$(echo "$NET" | awk -F. '{print $3"."$2"."$1}')   # 192.168.56 -> 56.168.192
SERIAL="$(date +%y%m%d%H%M)"   # AAMMDDhhmm: changes in every provision
LISTEN_IP="${LISTEN_IP:-$PRIMARY_IP}"

render() {   # template destino render
  sed -e "s|@DOMAIN@|$DOMAIN|g" -e "s|@NET@|$NET|g" \
      -e "s|@PRIMARY_IP@|$PRIMARY_IP|g" -e "s|@SECONDARY_IP@|$SECONDARY_IP|g" \
      -e "s|@PRIMARY_LAST@|$PRIMARY_LAST|g" -e "s|@SECONDARY_LAST@|$SECONDARY_LAST|g" \
      -e "s|@REV_ZONE@|$REV_ZONE|g" -e "s|@SERIAL@|$SERIAL|g" \
      -e "s|@TXT@|$TXT_VALUE|g" -e "s|@LISTEN_IP@|$LISTEN_IP|g" "$1" > "$2"
}
