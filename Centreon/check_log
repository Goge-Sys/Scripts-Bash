#!/bin/sh

# Répertoire spécifique à partir duquel vous souhaitez vérifier
repertoire="/var/log/clients"

PROGNAME=`basename $0`
PROGPATH="/usr/lib64/nagios/plugins"
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
    echo ""
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
                Result1=$STATE_OK
                Result2=$STATE_OK
                Text=""

NbPostes=`find "$repertoire" \( -path '*/172.20.250.216/*' -o -path '*/172.20.250.217/*' -o -path '*/192.168.100.45/*' -o -path '*/srv-ipdiva-med-88.chgr.local/*' -o -path '*/srv-ucopia.chgr.local/*' \) -type f -name 'syslog.log' -cmin +30 | wc -l `


        if [ $NbPostes -ne 0 ]
        then
                Text="CRITICAL - Le fichier syslog.log des serveurs suivants date d'il y a plus de 30 min :"
                for rep in `find "$repertoire" \( -path '*/172.20.250.216/*' -o -path '*/172.20.250.217/*' -o -path '*/192.168.100.45/*' -o -path '*/srv-ipdiva-med-88.chgr.local/*' -o -path '*/srv-ucopia.chgr.local/*' \) -type f -name 'syslog.log' -cmin +30 | cut -d '/' -f5 | sort `
                do
                        Text="$Text $rep, "
                done
                        Result1=$STATE_CRITICAL
                        echo $Text
        else
                      Result1=$STATE_OK
                      echo "OK - Tous les fichiers syslog des serveurs sont générés"
        fi


        if find "$repertoire" \( -path "$repertoire/titan1.chgr.local/*" -o -path "$repertoire/titan2.chgr.local/*" -o -path "$repertoire/titan.ch-guillaumeregnier.fr/*" \) -type f -name "syslog.log" -cmin -2 | grep -q .; then
            Result2=$STATE_OK
            echo "OK - Le fichier syslog du firewall est récent."
        else
            Result2=$STATE_CRITICAL
        echo "CRITICAL - Le fichier syslog du firewall n'a pas été généré récemment."
        fi

# En commentaire, affiche les répertoire ou le fichier syslog.log date de +2min
#       if [ $NbPostes -ne 0 ]
#           then
#               Text2="CRITICAL - le fichier syslog du firewall n'a pas été généré récemment dans le répertoire "
#               for rep2 in `find "$repertoire" \( -path "$repertoire/titan1.chgr.local/*" -o -path "$repertoire/titan2.chgr.local/*" -o -path "$repertoire/titan.ch-guillaumeregnier.fr/*" \) -type f -name "syslog.log" -cmin +2 |cut -d'/' -f5 | sort`
#               do
#                       Text2="$Text2 $rep2, "
#                       done
#                       Result2=$STATE_CRITICAL
#                       echo $Text2
#       else
#               Result2=$STATE_OK
#               echo "OK - le fichier syslog du firewall est récent "
#       fi

        if [ $Result1 -eq 0 ] && [ $Result2 -eq 0 ] ; then

                exit=$STATE_OK
        else
                exit=$STATE_CRITICAL
        fi

        #exit=$Result
        #echo "$Text"
        #echo "$Text2"
        #echo "$exit"
        exit $exit
        ;;
esac
