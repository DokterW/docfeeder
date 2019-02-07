#!/bin/bash
# DOkter's Cli FEEd ReadER v0.10
# Made by Dr. Waldijk
# A CLI RSS Reader.
# Read the README.md for more info, but you will find more info here below.
# By running this script you agree to the license terms.
# Config ----------------------------------------------------------------------------
DFNAM="docfeeder"
DFVER="0.10"
DFDIR="$HOME/.dokter/docfeeder"
DFOPT=$1
if [[ ! -e $DFDIR/list.df ]]; then
    wget  -q -N --show-progress https://raw.githubusercontent.com/DokterW/$DFNAM/master/list.df -P $DFDIR/
fi
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
df_width () {
    DFWTH=$(tput cols)
    DFWTH=$(echo "$DFWTH-4" | bc)
}
df_feedlist () {
    DFLST=$(cat $DFDIR/list.df)
    DFLLN=$(echo "$DFLST" | wc -l)
    DFART="5"
    DFLCT=$(echo "$DFLLN * $DFART" | bc)
    DFCNT=0
    DFLCT=0
}
df_fetchloop () {
    DFCNT=0
    df_width
    DFLCT=0
    until [[ "$DFCNT" -eq "$DFLLN" ]]; do
        DFCNT=$(expr $DFCNT + 1)
        clear
        echo "Loading..."
        echo "$DFCNT/$DFLLN"
        DFFTC=$(echo "$DFLST" | sed -n "$DFCNT p" | cut -d , -f 2 | lynx -source - | xmllint --format -)
        DFRCT=0
        DFFCK=$(echo "$DFLST" | sed -n "$DFCNT p" | cut -d , -f 2 | grep -o 'feedburner')
        if [[ -z "$DFFCK" ]]; then
            DFFCK=$(echo "$DFLST" | sed -n "$DFCNT p" | cut -d , -f 2 | grep -o 'spiegel.de')
        fi
        if [[ "$DFFCK" = "feedburner" ]]; then
            DFTAIL="3"
        else
            DFTAIL="2"
        fi
        until [[ "$DFRCT" -eq "$DFART" ]]; do
            DFRCT=$(expr $DFRCT + 1)
            DFLCT=$(expr $DFLCT + 1)
            DFTTL[$DFLCT]=$(echo "$DFFTC" | grep '<title>' | tail -n +$DFTAIL | head -5 | sed -n "$DFRCT p" | sed -r 's/.*<title>(.*)<\/title>/\1/' | cut -c 1-$DFWTH)
            DFURL[$DFLCT]=$(echo "$DFFTC" | grep '<link>' | tail -n +$DFTAIL | head -5 | sed -n "$DFRCT p" | sed -r 's/.*<link>(.*)<\/link>/\1/')
            DFHSH[$DFLCT]=$(echo "$DFLST" | sed -n "$DFCNT p" | cut -d , -f 1)
            DFRST[$DFLCT]=$(echo -e "[${DFTTL[$DFLCT]}]")
        done
#        DFFCK=""
    done
}
df_printloop () {
    DFRCT=0
    until [[ "$DFRCT" -eq "$DFLCT" ]]; do
        DFRCT=$(expr $DFRCT + 1)
        echo "${DFRST[$DFRCT]}"
    done
}
df_load () {
#    clear
#    echo "Loading..."
    df_fetchloop
    DFPST=$(df_printloop)
    DFCNT=1
#    $DFCST
}
df_post () {
    DFPFT=$(echo "$DFART*($DFCFD-1)+1" | bc)
    DFPLT=$(echo "$DFPFT+$DFART-1" | bc)
    DFCST=$DFPFT
}
df_list () {
    while :; do
        clear
#        echo "$DFNAM v$DFVER"
#        echo ""
        echo "$DFLST" | cut -d , -f 1 | sed -r 's/(.*)/\[\1\]/g' | sed -r "$DFCNT s/(.*)/  \1/"
        echo ""
        echo "[W: up / A: back / S: down / D: delete]"
        read -p "Add (f)eed " -s -n1 DFKEY
        if [[ "$DFKEY" -eq "d" ]] || [[ "$DFKEY" -eq "D" ]]; then
            DFDEL=$DFCNT
        fi
        case $DFKEY in
            [wW])
                DFCNT=$(expr $DFCNT - 1)
                if [[ "$DFCNT" -le "0" ]]; then
                    DFCNT=1
                fi
            ;;
            [sS])
                DFCNT=$(expr $DFCNT + 1)
                if [[ "$DFCNT" -ge "$DFLLN" ]]; then
                    DFCNT=$DFLLN
                fi
            ;;
            [aA])
                break
            ;;
            [dD])
                clear
                echo "Sure you want to delete the feed?"
                read -p "(Y)es or (N)o? " -s -n1 DFKEY
                case $DFKEY in
                    [yY])
                        sed -i "$DFDEL d" $DFDIR/list.df
                        df_feedlist
                        DFCNT=1
                    ;;
                    [nN])
                        clear
                        echo "Maybe think about it a bit more..."
                        sleep 2s
                    ;;
                    *)
                        clear
                        echo "Wrong key. Make yourself some coffe and think about it."
                        sleep 2s
                    ;;
                esac
#                break
                # df_load
            ;;
#            [1-9])
#                DFDEL=$DFKEY
#                while :; do
#                    DFLNM=$(echo "$DFLST" | sed -rn "$DFKEY p" | cut -d , -f 1)
#                    DFLUR=$(echo "$DFLST" | sed -rn "$DFKEY p" | cut -d , -f 2)
#                    clear
#                    echo "$DFNAM v$DFVER"
#                    echo ""
#                    echo "Title: $DFLNM"
#                    echo "  URL: $DFLUR"
#                    echo ""
#                    read -p "(D)elete / (B)ack " -s -n1 DFKEY
#                    case $DFKEY in
#                        [dD])
#                            sed -i "$DFDEL d" $DFDIR/list.df
#                            df_feedlist
#                            break
#                            # df_load
#                        ;;
#                        [bB])
#                            break
#                        ;;
#                        *)
#                            continue
#                        ;;
#                    esac
#                done
#            ;;
            [fF])
                clear
#                echo "$DFNAM v$DFVER"
#                echo ""
                read -p "Name: " DFLNM
                read -p " URL: " DFLUR
                echo "$DFLNM,$DFLUR,first" >> $DFDIR/list.df
                cp $DFDIR/list.df $DFDIR/list.bk
                df_feedlist
                DFCNT=1
            ;;
            [bB])
                break
            ;;
            *)
                continue
            ;;
        esac
    done
}
# -----------------------------------------------------------------------------------
if [[ "$DFOPT" != "help" ]]; then
    # DFSWC="0"
    df_feedlist
    df_load
    DFCNT=1
    while :; do
    #    if [[ "$DFSWC" -eq "1" ]]; then
    #        clear
    #        echo "Loading.df_width.."
    #        df_fetchloop
    #        DFPST=$(df_printloop)
    #        DFCNT=1
    #    fi
        df_width
        clear
    #    echo "$DFNAM v$DFVER"
    #    echo ""
        echo "$DFLST" | cut -d , -f 1 | cut -c 1-$DFWTH | sed -r 's/(.*)/\[\1\]/g' | sed -r "$DFCNT s/(.*)/  \1/"
        echo ""
        echo "[W: up / S: down / D: select]"
        read -p "(R)efresh / (L)ist / (Q)uit " -s -n1 DFKEY
        case $DFKEY in
            [wW])
                DFCNT=$(expr $DFCNT - 1)
                if [[ "$DFCNT" -le "0" ]]; then
                    DFCNT=1
                fi
    #            DFSWC="0"
            ;;
            [sS])
                DFCNT=$(expr $DFCNT + 1)
                if [[ "$DFCNT" -ge "$DFLLN" ]]; then
                    DFCNT=$DFLLN
                fi
    #            DFSWC="0"
            ;;
            [aA])
                continue
            ;;
            [dD])
                DFCFD=$DFCNT
                DFCNT=1
                df_post
                while :; do
                    clear
    #                echo "$DFNAM v$DFVER"
    #                echo ""
                    echo "$DFLST" | sed -nr "$DFCFD p" | cut -d , -f 1 | sed -r 's/(.*)/[\1]/'
                    echo "$DFPST" | sed -nr "$DFPFT,$DFPLT p" | sed -r "$DFCNT s/(.*)/  \1/"
                    echo ""
                    echo "[W: up / A: back / S: down / D: open]"
                    read -p "(R)efresh / (L)ist / (Q)uit " -s -n1 DFKEY
                    case $DFKEY in
                        [wW])
                            DFCNT=$(expr $DFCNT - 1)
                            if [[ "$DFCNT" -le "0" ]]; then
                                DFCNT=1
                            fi
                            DFCST=$(expr $DFCST - 1)
                            if [[ "$DFCST" -le "$DFPFT" ]]; then
                                DFCST=$DFPFT
                            fi
    #                        DFSWC="0"
                        ;;
                        [sS])
                            DFCNT=$(expr $DFCNT + 1)
                            if [[ "$DFCNT" -ge "$DFART" ]]; then
                                DFCNT=$DFART
                            fi
                            DFCST=$(expr $DFCST + 1)
                            if [[ "$DFCST" -ge "$DFPLT" ]]; then
                                DFCST=$DFPLT
                            fi
    #                        DFSWC="0"
                        ;;
                        [aA])
                            break
                        ;;
                        [dD])
                            if [[ -z "$DFOPT" ]] || [[ "$DFOPT" = "gnome" ]]; then
                                xdg-open "${DFURL[$DFCST]}"
                            elif [[ "$DFOPT" = "lynx" ]]; then
                                lynx "${DFURL[$DFCST]}"
                            fi
    #                        DFSWC="0"
                        ;;
                        [rR])
                            DFCFD=$DFCNT
                            df_load
                            DFCNT=$DFCFD
                            break
                        ;;
                        [lL])
                            df_list
                            df_load
                            break
                        ;;
                        [cC])
                            continue
                        ;;
                        [qQ])
                            clear
                            exit
                        ;;
                        *)
                            continue
                        ;;
                    esac
                done
                DFCNT=$DFCFD
            ;;
            [rR])
                DFCFD=$DFCNT
                df_load
                DFCNT=$DFCFD
            ;;
            [lL])
                df_list
                df_load
            ;;
            [cC])
    #            while :; do
    #                clear
    #                echo "Articles per feed: $DFART"
    #                echo ""
    #                read -p "(C)hange / (B)ack " -s -n1 DFKEY
    #                case $DFKEY in
    #                    [cC])
    #                        clear
    #                        read -p "How many articles per feed: " DFKEY
    #                        sed -i "48 s/"$DFART"/"$DFKEY"/" start.sh
    #                        df_feedlist
    #                    ;;
    #                    [bB])
    #                        break
    #                    ;;
    #                    *)
    #                        continue
    #                    ;;
    #                esac
    #            done
                continue
            ;;
            [vV])
                clear
                echo "$DFNAM v$DFVER"
                sleep 2s
            ;;
            [qQ])
                clear
                exit
            ;;
            *)
                continue
            ;;
        esac
    done
elif [[ "$DFOPT" = "help" ]]; then
    echo "$DFNAM v$DFVER"
    echo ""
    echo "docfeeder <option>"
    echo "  options:"
    echo "          gnome (default)"
    echo "          lynx"
fi
