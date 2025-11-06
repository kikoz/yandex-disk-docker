#!/bin/bash
# Check Yandex Disk sync log for last "REDUCE ... download file" entry

LOG_FILE="/PATH_TO_YANDEX_DISK/yandex/.sync/core.log"

THRESHOLD_HOURS=24 # set your threshold in hours
THRESHOLD_SECONDS=$((THRESHOLD_HOURS * 3600))
#THRESHOLD_SECONDS=100 # test

if [ ! -f "$LOG_FILE" ]; then
  message="Yandex Disk Check: Log file not found '$LOG_FILE'"
  #/usr/sbin/omv-rpc -u admin "Notification" "send" \
  #  '{"type":"error","title":"Yandex Disk Sync Alert","message":"Log file not found: '$LOG_FILE'"}'
  echo "$message"
  logger "$message" 
  exit 1
fi

# Find the last "REDUCE ... download file" entry
last_line=$(grep "REDUCE" "$LOG_FILE" | grep "download file" | tail -n 1)

if [ -z "$last_line" ]; then
  message="Yandex Disk Check: No recent download entries found in log"
  #/usr/sbin/omv-rpc -u admin "Notification" "send" \
  #  '{"type":"error","title":"Yandex Disk Sync Alert","message":"No recent download entries found in log"}'
  echo "$message"
  logger "$message" 
  exit 1
fi

# Example line: 51103-225345.621 REDUCE "Books/Kopyha.conf" download file
# Parse timestamp prefix: 51103-225345.621
ts_prefix=$(echo "$last_line" | awk '{print $1}')

# Extract month/day and time from the log timestamp
month_day=${ts_prefix:1:4}  # 1103 (Nov 03)
time=${ts_prefix:6:6}       # 225345 (22:53:45)

# Compose a full date string for this year
year=$(date +%Y)
log_date="${year}-${month_day:0:2}-${month_day:2:2} ${time:0:2}:${time:2:2}:${time:4:2}"

# Convert to epoch seconds
log_epoch=$(date -d "$log_date" +%s 2>/dev/null)
now_epoch=$(date +%s)

# Validate conversion
if [ -z "$log_epoch" ]; then
  message="Yandex Disk Check: unable to parse timestamp from log line '$last_line'"
  echo "$message"
  logger "$message" 
  exit 1
fi

# Compute age in seconds
age_seconds=$((now_epoch - log_epoch))

# Check against threshold
if (( age_seconds > THRESHOLD_SECONDS )); then
  message="⚠️ Yandex Disk has not downloaded new files in ${age_seconds} seconds. Last entry: ${log_date}"
  #/usr/sbin/omv-rpc -u admin "Notification" "send" \
  #  '{"type":"error","title":"Yandex Disk Sync Alert","message":"'$message'"}'
  echo "$message"
  logger "$message"
  exit 1
else
  message="✅ Yandex Disk sync OK (last download ${age_seconds} seconds ago: ${log_date})"
  #echo "$message"
  logger "$message" 
fi