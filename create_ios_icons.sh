#!/bin/bash
#
# Create 3 copies of the given image with 32px, 64px, 96px size
#

TAB_SIZE=32
BAR_SIZE=22
output_dir='./'

while getopts ":o:" opt; do
	case "$opt" in
	o)
		output_dir=$OPTARG
		;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
		;;
	esac
done

shift $(($OPTIND - 1))

if [[ $# < 2 || $size_base && $# < 1 ]]; then
	echo "USAGE: " + `basename $0` + " [-o OUTPUT_DIR] size image"
	exit 1
fi

size=$1
image=$2
re='^[0-9]+$'
if [[ $size =~ $re ]]; then
	size_base=$size;
else
	case "$size" in
		tab) size_base=$TAB_SIZE
			 ;;
		bar) size_base=$BAR_SIZE
			 ;;
		*) echo "Unrecognized size $size. Available constant options are: tab, bar"
		   exit 1
		   ;;
	esac
fi
size_big=$(($size_base * 2))
size_huge=$(($size_base * 3))

echo "Converting $image to size $size (output directory: $output_dir)"

# Check if output_dir is a directory
if [ ! -d "$output_dir" ]; then
	echo "Given output URI isn't a directory: $output_dir"
	exit 1
fi

# Check image size
for side in `sips -g pixelWidth -g pixelHeight $image | sed -n 's/.*pixel.*: \([0-9]*\)/\1/p'`; do
	if [[ $side -lt $size_huge ]]; then
		echo "Given image smallest side should be at least $size_huge px (currently $side px)"
		exit 1
	fi
done

# Convert
format=`sips -g format $image | sed -n 's/.*format: \([a-z]*\)/\1/p'`
file_name=`basename $image | sed -n "s/\(.*\)\.$format/\1/p"`
sips -Z $size_base -s format png $image --out $output_dir/$file_name".png"
sips -Z $size_big -s format png $image --out $output_dir/$file_name"@2x.png"
sips -Z $size_huge -s format png $image --out $output_dir/$file_name"@3x.png"

echo 'DONE'
