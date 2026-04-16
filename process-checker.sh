#!/bin/bash

logfile="process_check.log"
running_count=0
missing_count=0

log() {
    echo "$(date) - $1" | tee -a "$logfile"
}

check_process() {
    local p=$1
    if pgrep "$p" &>/dev/null; then
        log "Processen '$p' körs."
        running_count=$((running_count + 1))
    else
        log "VARNING: Processen '$p' körs inte."
        missing_count=$((missing_count + 1))
    fi
}

run_checks() {
    local file=$1

    if [ ! -f "$file" ]; then
        log "FEL: Filen $file saknas."
        exit 1
    fi

    while read -r process; do
        if [ -n "$process" ]; then
            check_process "$process"
        fi
    done < "$file"
}

> "$logfile"
run_checks "processlist.txt"
log "Sammanfattning: $running_count process(er) körs, $missing_count process(er) saknas."
log "Kontroller slutförda."