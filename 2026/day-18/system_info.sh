#!/bin/bash

set -euo pipefail

system_info(){

echo "===== Hostname ====="

hostname

echo

echo "===== OS ====="

cat /etc/os-release

}

uptime_info(){

echo

echo "===== Uptime ====="

uptime

}

disk_info(){

echo

echo "===== Disk Usage ====="

du -sh * 2>/dev/null | sort -hr | head -5

}

memory_info(){

echo

echo "===== Memory ====="

free -h

}

cpu_info(){

echo

echo "===== Top CPU Processes ====="

ps -eo pid,comm,%cpu --sort=-%cpu | head -6

}

main(){

system_info

uptime_info

disk_info

memory_info

cpu_info

}

main
