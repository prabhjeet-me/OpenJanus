#!/bin/bash
set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Logging function
log() {
  local type=$1
  local module=$2
  shift 2
  local message="$*"

  local color_code

  # Auto-select color based on type
  case "${type,,}" in
    error|err|fatal) color_code=$RED ;;
    warning|warn)    color_code=$YELLOW ;;
    info|debug)      color_code=$BLUE ;;
    success|ok)      color_code=$GREEN ;;
    notice)          color_code=$CYAN ;;
    *)               color_code=$MAGENTA ;; # default color
  esac

  # Timestamp
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S UTC')

  output="[${timestamp}] [${type^^}] <${module}> ${message}"

  # Print formatted log line
  echo -e "${color_code}$output${RESET}"

  # Create log file path
  mkdir -p "$LOG_FILE_PATH"

  case "${type,,}" in
  error|err|fatal) echo -e "${output}" >> "$LOG_FILE_PATH/error-$(date '+%Y-%m-%d').log" ;;
  warning|warn) echo -e "${output}" >> "$LOG_FILE_PATH/warning-$(date '+%Y-%m-%d').log" ;;
  info|debug) echo -e "${output}" >> "$LOG_FILE_PATH/info-$(date '+%Y-%m-%d').log" ;;
  success|ok) echo -e "${output}" >> "$LOG_FILE_PATH/success-$(date '+%Y-%m-%d').log" ;;
  notice) echo -e "${output}" >> echo -e "${output}" >> "$LOG_FILE_PATH/notice-$(date '+%Y-%m-%d').log" ;;
  esac

  echo -e "${output}" >> "$LOG_FILE_PATH/all-$(date '+%Y-%m-%d').log"
}
