#!/bin/bash
# DOkter's Cli FEEd ReadER v0.1
# Made by Dr. Waldijk
# A CLI RSS Reader.
# Read the README.md for more info, but you will find more info here below.
# By running this script you agree to the license terms.
# Config ----------------------------------------------------------------------------
DFNAM="docfeeder"
DFVER="0.1"
DFDIR="$HOME/.dokter/docfeeder"
if [[ ! -e $DFDIR/list.df ]]; then
    wget  -q -N --show-progress https://raw.githubusercontent.com/DokterW/$DFNAM/master/list.df -P $DFDIR/
fi
DFLST=$(cat $DFDIR/list.df)
DFLLN=$(echo "$DFLST" | wc -l)
DFART="3"
DFLCT=$(echo "$DFLLN * $DFART" | bc)
DFCNT=0
DFLCT=0
# Dependencies ----------------------------------------------------------------------
if [ ! -e /usr/bin/lynx ] && [ ! -e /usr/bin/xmllint ]; then
    FNUOSD=$(cat /etc/system-release | grep -oE '^[A-Z][a-z]+\s' | sed '1s/\s//')
    if [ "$FNUOSD" = "Fedora" ]; then
        sudo dnf -y install lynx libxml
    else
        echo "You need to install lynx and libxml."
        exit
    fi
elif [ ! -e /usr/bin/lynx ]; then
    FNUOSD=$(cat /etc/system-release | grep -oE '^[A-Z][a-z]+\s' | sed '1s/\s//')
    if [ "$FNUOSD" = "Fedora" ]; then
        sudo dnf -y install lynx
    else
        echo "You need to install curl."
        exit
    fi
elif [ ! -e /usr/bin/xmllint ]; then
    FNUOSD=$(cat /etc/system-release | grep -oE '^[A-Z][a-z]+\s' | sed '1s/\s//')
    if [ "$FNUOSD" = "Fedora" ]; then
        sudo dnf -y install libxml
    else
        echo "You need to install libxml."
        exit
    fi
fi
# Function --------------------------------------------------------------------------
df_fetchloop () {
    until [[ "$DFCNT" -eq "$DFLLN" ]]; do
        DFCNT=$(expr $DFCNT + 1)
        DFFTC=$(echo "$DFLST" | sed -n "$DFCNT p" | cut -d , -f 2 | lynx -source - | xmllint --format -)
        DFRCT=0
        until [[ "$DFRCT" -eq "$DFART" ]]; do
            DFRCT=$(expr $DFRCT + 1)
            DFLCT=$(expr $DFLCT + 1)
            DFTTL[$DFLCT]=$(echo "$DFFTC" | grep '<title>' | tail -n +2 | head -5 | sed -n "$DFRCT p" | sed -r 's/.*<title>(.*)<\/title>/\1/')
            DFURL[$DFLCT]=$(echo "$DFFTC" | grep '<link>' | tail -n +2 | head -5 | sed -n "$DFRCT p" | sed -r 's/.*<link>(.*)<\/link>/\1/')
            DFHSH[$DFLCT]=$(echo "$DFLST" | sed -n "$DFCNT p" | cut -d , -f 1)
            DFRST[$DFLCT]=$(echo -e "[${DFHSH[$DFLCT]}] ${DFTTL[$DFLCT]}")
        done
    done
}
df_printloop () {
    DFRCT=0
    until [[ "$DFRCT" -eq "$DFLCT" ]]; do
        DFRCT=$(expr $DFRCT + 1)
        echo "${DFRST[$DFRCT]}"
    done
}
# -----------------------------------------------------------------------------------
while :; do
    while :; do
        clear
        echo "$DFNAM v$DFVER"
        echo ""
        read -p "(R)ead / (L)ist / (Q)uit " -s -n1 DFKEY
        case $DFKEY in
            [rR])
                break
            ;;
            [lL])
                while :; do
                    DFLRD=$(echo "$DFLST" | cut -d , -f 1 | nl -w1 -s'. ')
                    clear
                    echo "$DFNAM v$DFVER"
                    echo ""
                    echo "$DFLRD"
                    echo ""
                    echo "[#: view/delete]"
                    read -p "(A)dd / (B)ack " -s -n1 DFKEY
                    case $DFKEY in
                        [1-9])
                            DFLNM=$(echo "$DFLST" | sed -rn "$DFKEY p" | cut -d , -f 1)
                            DFLUR=$(echo "$DFLST" | sed -rn "$DFKEY p" | cut -d , -f 2)
                            DFDEL=$DFKEY
                            clear
                            echo "$DFNAM v$DFVER"
                            echo ""
                            echo "Title: $DFLNM"
                            echo "  URL: $DFLUR"
                            echo ""
                            read -p "(D)elete / (B)ack " -s -n1 DFKEY
                            case $DFKEY in
                                [dD])
                                    sed -i "$DFDEL d" $DFDIR/list.df
                                    DFLST=$(cat $DFDIR/list.df)
                                ;;
                                [bB])
                                    continue
                                ;;
                            esac
                        ;;
                        [aA])
                            clear
                            echo "$DFNAM v$DFVER"
                            echo ""
                            read -p "Name: " DFLNM
                            read -p " URL: " DFLUR
                            echo "$DFLNM,$DFLUR,first" >> $DFDIR/list.df
                            DFLST=$(cat $DFDIR/list.df)
                        ;;
                        [bB])
                            break
                        ;;
                    esac
                done
            ;;
            [qQ])
                clear
                exit
            ;;
        esac
    done
    DFSWC="1"
    while :; do
        if [[ "$DFSWC" -eq "1" ]]; then
            clear
            df_fetchloop
            DFPST=$(df_printloop)
            DFCNT=1
        fi
        clear
        echo "$DFNAM v$DFVER"
        echo ""
        echo "$DFPST" | sed -r "$DFCNT s/(.*)/  \1/"
        echo ""
        echo "[W: up / S: down / D: open article in your browser]"
        read -p "(R)efresh / (B)ack / (Q)uit " -s -n1 DFKEY
        case $DFKEY in
            [wW])
                DFCNT=$(expr $DFCNT - 1)
                if [[ "$DFCNT" -le "0" ]]; then
                    DFCNT=1
                fi
                DFSWC="0"
            ;;
            [sS])
                DFCNT=$(expr $DFCNT + 1)
                if [[ "$DFCNT" -ge "$DFLCT" ]]; then
                    DFCNT=$DFLCT
                fi
                DFSWC="0"
            ;;
            [dD])
                xdg-open "${DFURL[$DFCNT]}"
                DFSWC="0"
            ;;
            [rR])
                DFSWC="1"
            ;;
            [bB])
                clear
                break
            ;;
            [qQ])
                clear
                exit
            ;;
        esac
    done
done
