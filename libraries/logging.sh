#!/bin/sh

. ./libraries/utils.sh

LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARN=2
LOG_LEVEL_ERROR=3

DEFAULT_LOG_LEVEL=$LOG_LEVEL_INFO
DEFAULT_LOG_DIRECTORY="./output"
DEFAULT_LOG_FILE_NAME="$(get_timestamp file)_$(basename "$0").log"
DEFAULT_LOG_FILE_PATH="$DEFAULT_LOG_DIRECTORY"/"$DEFAULT_LOG_FILE_NAME"

# create default log directory if it is missing
if [ ! -d "$DEFAULT_LOG_DIRECTORY" ]; then
	mkdir -p $DEFAULT_LOG_DIRECTORY
fi

# function for logging message to console and/or file
log() {
	if [ "$#" -lt 2 ]; then
		echo "usage: log <level> <message> [log_file] [log_level]"
		return 1
	fi

	level="$1"
	message="$2"
	log_file="${3:-$DEFAULT_LOG_FILE_PATH}"
	log_level="${4:-$DEFAULT_LOG_LEVEL}"

	if [ "$level" -lt "$log_level" ]; then
		return 1
	fi

	timestamp="$(get_timestamp log)"
	level_string="NONE"

	case "$level" in
	"$LOG_LEVEL_DEBUG") level_string="DEBUG" ;;
	"$LOG_LEVEL_INFO") level_string="INFO" ;;
	"$LOG_LEVEL_WARN") level_string="WARN" ;;
	"$LOG_LEVEL_ERROR") level_string="ERROR" ;;
	esac

	log_line="[$timestamp] [$level_string] $message"

	echo "$log_line"

	if [ -n "$log_file" ]; then
		echo "$log_line" >>"$log_file"
	fi

	return 0
}

# helper function for logging debug messages
log_debug() {
	if [ "$#" -lt 1 ]; then
		echo "usage: log_debug <message> [log_file] [log_level]"
		return 1
	fi

	log $LOG_LEVEL_DEBUG "$1" "$2" "$3"
	return 0
}

# helper function for logging info messages
log_info() {
	if [ "$#" -lt 1 ]; then
		echo "usage: log_info <message> [log_file] [log_level]"
		return 1
	fi

	log $LOG_LEVEL_INFO "$1" "$2" "$3"
	return 0
}

# helper function for logging warn messages
log_warn() {
	if [ "$#" -lt 1 ]; then
		echo "usage: log_warn <message> [log_file] [log_level]"
		return 1
	fi

	log $LOG_LEVEL_WARN "$1" "$2" "$3"
	return 0
}

# helper function for logging error messages
log_error() {
	if [ "$#" -lt 1 ]; then
		echo "usage: log_error <message> [log_file] [log_level]"
		return 1
	fi

	log $LOG_LEVEL_ERROR "$1" "$2" "$3"
	return 0
}
