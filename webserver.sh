#!/bin/bash

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-e ENGINE]
Start a webserver serving the file in current directory, listening on the given localhost:8000.

 -h, --help     display this help and exit
 -e ENGINE      use the given engine to run the server.
                Possible choiches: php, python (defaults to php)
EOF
}

engine="php"

while getopts "he:" opt; do
	case "$opt" in
	h|help)
		show_help
		exit 0
		;;
	e)
		engine=$OPTARG
		;;
	esac
done

if [[ $engine == "php" ]]; then
	php -S localhost:8000
else
	python -m SimpleHTTPServer
fi