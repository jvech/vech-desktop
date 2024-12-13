#!/usr/bin/sh
TEMP=$(getopt -o 'haril:' -l 'help,append,replace,insert,lines' -- "$@")

if [ $? -ne 0 ]; then
    echo 'Terminating...' >&2
    exit 1
fi

eval set -- "$TEMP"
unset TEMP

W_MENU_LINES=10
ADD_MODE='replace'
while true; do
    case "$1" in
        '-a'|'--append')
            ADD_MODE='append-play'
            shift
            continue
            ;;
        '-r'|'--replace')
            ADD_MODE='replace'
            shift
            continue
            ;;
        '-i'|'--insert')
            ADD_MODE='insert-at-play'
            shift
            continue
            ;;
        '-l')
            W_MENU_LINES=$2
            shift 2
            continue
            ;;
        '--')
            shift
            break
            ;;
        *)
            echo "Usage: $0 [-l lines] [-v] query" >&2
            exit 1
            ;;
    esac  
done

jq_query='.data[] | "\(if .current == true then ">" else "" end) \(if .title == null then .filename else .title end)"'
alias wmenu="wmenu -S aaffaa -s 222222 -m 222222 -M aaffaa"

lines="$(mpv-ipc-client.sh get_property playlist | jq -r "$jq_query" | tac | wmenu -p 'Queue:' -l $W_MENU_LINES)"

if [ "$lines" != "" ] ; then
    ytlist.sh "$lines"\
        | wmenu -i -l $W_MENU_LINES -p 'Results:'\
        | tr -d "'" | tr -d '"'\
        | xargs -Iz mpv-ipc-client.sh loadfile "z" "$ADD_MODE"
fi
