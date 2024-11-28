#!/bin/bash

# Colors
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

deleteLogs=false
schedule=false
dir=""
archiveDir=""
s3=""
dateY=$(date '+%Y%m%d')
dateT=$(date '+%H%M%S')
fileDir=""

usage() {
  echo -e "${YELLOW}Usage: log-archive ${CYAN}-l <log-directory> -a <archive-directory> [-s <S3-URI>] [-d] [-t]"
  echo
  echo -e "${RED}Required:${NOCOLOR}"
  echo "  -l <log-directory>    Directory containing logs to archive (e.g. /var/log/logs-dir)"
  echo "  -a <archive-directory> Local directory for storing archived logs (e.g. /var/log/compressed)"
  echo
  echo -e "${CYAN}Optional:${NOCOLOR}"
  echo "  -s <S3-URI>           S3 URI for storing archived logs (e.g. s3://my-bucket-name)"
  echo "  -d                    Delete original logs after archiving."
  echo "  -t                    Schedule this script as a daily cron job."
}

check_command() {
  command -v "$1" &>/dev/null || {
    echo -e "${RED}Error: $1 is not installed. Please install it and try again.${NOCOLOR}"
    exit 1
  }
}

directory_not_exists() {
  [[ ! -d "$1" ]] && {
    echo -e "${RED}Error: Directory '$1' doesn't exist.${NOCOLOR}"
    exit 1
  }
}

invalid_s3_uri() {
  [[ ! "$s3" =~ ^s3://[a-z0-9.-]{3,63}$ ]] && {
    echo -e "${RED}Error: Invalid S3 URI $s3.${NOCOLOR}"
    exit 1
  }
}

compress_logs() {
  echo -e "${CYAN}Compressing logs from '$dir' into '$fileDir'...${NOCOLOR}"
  tar -czf "$fileDir" -C "$dir" . || {
    echo -e "${RED}Error: Failed to compress logs.${NOCOLOR}"
    [[ -f "$fileDir" ]] && rm "$fileDir"
    exit 1
  }
  echo -e "${GREEN}Logs successfully archived into '$fileDir'.${NOCOLOR}"
}

upload_s3() {
  [[ -n "$s3" ]] && {
    echo -e "${CYAN}Uploading '$fileDir' to S3: $s3...${NOCOLOR}"
    aws s3 cp "$fileDir" "$s3" || {
      echo -e "${RED}Error: Failed to upload logs to S3.${NOCOLOR}"
      exit 1
    }
    echo -e "${GREEN}Logs successfully uploaded to S3.${NOCOLOR}"
  }
}

delete_logs() {
  [[ $deleteLogs == true ]] && {
    echo -e "${CYAN}Deleting original log files in '$dir'...${NOCOLOR}"
    rm -rf "$dir"/* || {
      echo -e "${RED}Error: Failed to delete original log files.${NOCOLOR}"
      exit 1
    }
    echo -e "${GREEN}Original log files deleted.${NOCOLOR}"
  }
}

scheduler() {
  [[ $schedule == true ]] && {
    cron="0 0 * * * /usr/local/bin/log-archive -l $dir -a $archiveDir"
    [[ $deleteLogs == true ]] && cron+=" -d"
    [[ -n $s3 ]] && cron+=" -s $s3"

    # Add cron if it doesn't exist
    (crontab -l 2>/dev/null | grep -F "$cron" >/dev/null 2>&1) || {
      (
        crontab -l 2>/dev/null
        echo "$cron"
      ) | crontab - && {
        echo -e "${GREEN}Cron job added for daily execution.${NOCOLOR}"
      }
    }
  }
}

# Ensure required commands exist
check_command tar
[[ -n "$s3" ]] && check_command aws

# Parse arguments
while getopts 'l:a:s:dt' OPTION; do
  case "$OPTION" in
  l)
    dir="$OPTARG"
    directory_not_exists "$dir"
    ;;
  a)
    archiveDir="$OPTARG"
    directory_not_exists "$archiveDir"
    fileDir="$archiveDir/logs_archive_${dateY}_${dateT}.tar.gz"
    ;;
  s)
    s3="$OPTARG"
    invalid_s3_uri
    ;;
  d)
    deleteLogs=true
    ;;
  t)
    schedule=true
    ;;
  *)
    usage
    exit 1
    ;;
  esac
done
shift "$(($OPTIND - 1))"

# Check required arguments
if [[ -z "$dir" || -z "$archiveDir" ]]; then
  echo -e "${RED}Error: Missing required flags.${NOCOLOR}"
  usage
  exit 1
fi

# Execute functions
compress_logs
upload_s3
delete_logs
scheduler
