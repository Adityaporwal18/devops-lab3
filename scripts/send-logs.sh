#!/usr/bin/env bash
set -euo pipefail
count="${1:-40}"
host="${2:-localhost}"
port="${3:-5003}"
exec 3<>"/dev/tcp/${host}/${port}"
for i in $(seq 1 "$count"); do
  level=INFO
  if (( i % 10 == 0 )); then level=ERROR; elif (( i % 4 == 0 )); then level=WARNING; fi
  printf '{"application":"devops-lab3","level":"%s","sequence":%d,"message":"Lab 3 log event %d"}\n' "$level" "$i" "$i" >&3
done
exec 3>&-
echo "sent $count log events to ${host}:${port}"
