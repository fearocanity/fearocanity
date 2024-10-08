#!/bin/bash

date="$(( $(date +%s) + 14400 ))"

while [[ "${date}" -gt "$(date +%s)" ]]; do
    curl -sLf -H "Authorization: Bearer ${1}" \
      -H "Accept: application/vnd.github.v3+json" \
      -X POST \
      -d '{"ref":"master","inputs":{}}' "https://api.github.com/repos/fearocanity/fearocanity/actions/workflows/${2}/dispatches" \
      -o /dev/null && { : "$((i+=1))" ; printf '%s\n' "Completed Runs: ${i:=0}" ;}
    sleep 600
done
    
