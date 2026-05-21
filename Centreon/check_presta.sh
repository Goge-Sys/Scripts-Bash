#!/bin/sh
PROGNAME=$(basename $0)
PROGPATH="/usr/lib64/nagios/plugins"
REVISION="1.0.0"
PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
export PATH
. $PROGPATH/utils.sh

print_usage() {
    echo "Usage: $PROGNAME [--ignore-fault]"
}

print_help() {
    print_revision $PROGNAME $REVISION
    echo ""
    print_usage
    echo ""
    echo "Cette sonde contrôle les connexions des prestataires."
    echo ""
    support
    exit $STATE_OK
}

# Fonction de résolution DNS avec fallback sur l'IP si pas de résolution
resolve_dns() {
    ip="$1"

    # 1. getent (DNS/hosts système)
    hostname=$(getent hosts "$ip" 2>/dev/null | awk '{print $2}')
    if [ -n "$hostname" ]; then
        echo "$hostname ($ip)"
        return
    fi

    # 2. nslookup fallback
    hostname=$(nslookup "$ip" 2>/dev/null | awk '/name =/ {gsub(/\.$/, "", $NF); print $NF}')
    if [ -n "$hostname" ]; then
        echo "$hostname ($ip)"
        return
    fi

    # 3. Aucune résolution, IP brute
    echo "$ip"
}

# Fonction de résolution du protocole depuis le SID
resolve_protocol() {
    sid="$1"
    case "$sid" in
        60[0-9][0-9]) echo "RDP" ;;
        50[0-9][0-9]) echo "SSH" ;;
        20[0-9][0-9]) echo "BDD" ;;
        *)            echo "UNKNOWN" ;;
    esac
}

case "$1" in
    --help)
        print_help
        exit $STATE_OK
        ;;
    -h)
        print_help
        exit $STATE_OK
        ;;
    --version)
        print_revision $PROGNAME $REVISION
        exit $STATE_OK
        ;;
    -V)
        print_revision $PROGNAME $REVISION
        exit $STATE_OK
        ;;
    *)
        log=$(cat /var/log/suricata/fast.log /var/log/suricata/fast.log-$(date +"%Y%m%d") 2>/dev/null | grep -E '\[1:(2[0-9]{3}|5[0-9]{3}|6[0-9]{3}):0\]')

        # Heure actuelle en timestamp
        temps_actuel=$(date +%s)
        trois_heure=$(($temps_actuel - 3 * 3600))

        # Lister des connexions actives
        ip_list=""

        if [ -n "$log" ]; then
            while read -r line; do
                # Extraire la date du log
                log_date=$(echo "$line" | awk '{print $1 " " $2}')
                formatted_date=$(echo "$log_date" | sed 's/-/ /' | awk -F'.' '{print $1}')
                log_timestamp=$(date -d "$formatted_date" +%s 2>/dev/null)

                if [ "$log_timestamp" -gt "$trois_heure" ]; then
                    # Extraire IP source, destination et SID
                    src_ip=$(echo "$line" | awk -F'[ :]+' '{print $20}')
                    dst_ip=$(echo "$line" | awk -F'[ :]+' '{print $23}')
                    sid=$(echo "$line" | grep -oP '(?<=\[1:)\d+(?=:)')

                    # Résolution DNS uniquement sur la destination
                    dst_resolved=$(resolve_dns "$dst_ip")
                    protocol=$(resolve_protocol "$sid")

                    ip_list="$ip_list$src_ip vers $dst_resolved ($protocol), "
                fi
            done <<< "$log"

            if [ -n "$ip_list" ]; then
                echo "CRITICAL - Connexions prestataires dans les 3 dernières heures : $ip_list"
                exit=$STATE_CRITICAL
            else
                echo "OK - Aucune connexion trouvée dans les 3 dernières heures."
                exit=$STATE_OK
            fi
        else
            echo "OK - Fichiers de log vides"
            exit=$STATE_OK
        fi

        exit $exit
        ;;
esac
