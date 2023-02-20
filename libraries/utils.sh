#!/bin/sh

# helper function to get a timestamp
get_timestamp() {
	case "$1" in
	"log")
		date +"%Y-%m-%d %H:%M:%S"
		;;
	"file")
		date +"%Y-%m-%d_%H-%M-%S"
		;;
	*)
		echo "usage: get_timestamp <log/file>"
		return 1
		;;
	esac

	return 0
}
