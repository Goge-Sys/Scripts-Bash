#!/bin/bash

PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION="1.0.0"
PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

export PATH

. $PROGPATH/utils.sh

print_usage() {
    echo "Usage: $PROGNAME" [--ignore-fault]
}

print_help() {
    print_revision $PROGNAME $REVISION
    echo ""
    print_usage
    echo ""
    echo "Cette sonde detecte la validité des certificats ."
    echo ""
    support
    exit $STATE_OK
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
        
# Demander à l'utilisateur de fournir l'URL du site
#read -p "Veuillez saisir l'URL du site: " HOSTNAME

# Définir le port SSL par défaut
PORT_SSL="443"

HOSTNAME=`hostname`

# Exécuter la commande openssl et récupérer les certificats
CERTIFICATS=$(echo ""|openssl s_client -showcerts -connect "${HOSTNAME}:${PORT_SSL}" 2>/dev/null)

# Vérifier si des certificats ont été trouvés
if [[ "$CERTIFICATS" == *"BEGIN CERTIFICATE"* ]]; then
    # Extraire les dates de validité du premier certificat
    DATE_DEBUT_VALIDITE=$(date -d "$(openssl x509 -noout -startdate <<< "$CERTIFICATS" | cut -d= -f2)" "+%s")
    DATE_FIN_VALIDITE=$(date -d "$(openssl x509 -noout -enddate <<< "$CERTIFICATS" | cut -d= -f2)" "+%s")

    # Récupérer la date actuelle
    DATE_ACTUELLE=$(date "+%s")

    # Calculer le nombre de secondes jusqu'à l'expiration
    SECONDES_AVANT_EXPIRATION=$((DATE_FIN_VALIDITE - DATE_ACTUELLE))

    # Calculer le nombre de jours jusqu'à l'expiration
    JOURS_AVANT_EXPIRATION=$((SECONDES_AVANT_EXPIRATION / (60 * 60 * 24)))

    # Calculer le nombre d'heures jusqu'à l'expiration si le nombre de jours est égal à 0
    if [ "$JOURS_AVANT_EXPIRATION" -eq 0 ];
    then
        HEURES_AVANT_EXPIRATION=$((SECONDES_AVANT_EXPIRATION / 3600))
        text="Critique: Le certificat de ${HOSTNAME} expire dans $HEURES_AVANT_EXPIRATION heures ($(date -d "@$DATE_FIN_VALIDITE" "+%d-%m-%Y %H:%M:%S"))."
        exit=$STATE_CRITICAL

        else
       # Afficher le message approprié en fonction du délai jusqu'à l'expiration
        if [ "$JOURS_AVANT_EXPIRATION" -le 15 ];
        then
             text="Critique: Le certificat de ${HOSTNAME} expire dans $JOURS_AVANT_EXPIRATION jours ($(date -d "@$DATE_FIN_VALIDITE" "+%d-%m-%Y %H:%M:%S"))."
             exit=$STATE_CRITICAL

        elif [ "$JOURS_AVANT_EXPIRATION" -le 30 ];
        then
            text="Avertissement: Le certificat de ${HOSTNAME} expire dans $JOURS_AVANT_EXPIRATION jours ($(date -d "@$DATE_FIN_VALIDITE" "+%d-%m-%Y %H:%M:%S"))."
            exit=$STATE_WARNING

        else
            text="OK: Le certificat de ${HOSTNAME} est valide jusqu'au $(date -d "@$DATE_FIN_VALIDITE" "+%d-%m-%Y %H:%M:%S")."
            exit=$STATE_OK
        fi
    fi
else
    text="Aucun certificat trouvé pour le site."
    exit=$STATE_UNKNOWN
fi

echo "$text"
exit $exit

esac
