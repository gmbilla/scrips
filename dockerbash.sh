#!/bin/bash

if [[ $# < 1 ]]; then
        echo "USAGE $0 <image_name|image_uuid> [stuff...]"
        exit  1
fi

docker --tlsverify=false run --rm -it -v `pwd`:/docker $1 /bin/bash

