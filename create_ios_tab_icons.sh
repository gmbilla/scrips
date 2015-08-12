#!/bin/bash
#
# Create 3 copies of the given image with 32px, 64px, 96px size
#

size_base=32
size_big=64
size_huge=96
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

if [[ $# < 1 ]]; then
	echo "USAGE: $0 [-o OUTPUT_DIR] image"
	exit 1
fi

image=$1
echo "Converting $image (output directory: $output_dir)"

# Check if output_dir is a directory
if [ ! -d "$output_dir" ]; then
	echo "Given output URI isn't a directory: $output_dir"
	exit 1
fi

# Check image size
for size in `sips -g pixelWidth -g pixelHeight $image | sed -n 's/.*pixel.*: \([0-9]*\)/\1/p'`; do
	if [[ $size -lt $size_huge ]]; then
		echo "Given image smallest side should be at least $size_huge px (currently $size px)"
		exit 1
	fi
done

# Convert
format=`sips -g format $image | sed -n 's/.*format: \([a-z]*\)/\1/p'`
file_name=`echo $image | sed -n "s/\(.*\)\.$format/\1/p"`
sips -Z $size_base -s format png $image --out $output_dir/$file_name".png"
sips -Z $size_big -s format png $image --out $output_dir/$file_name"@2x.png"
sips -Z $size_huge -s format png $image --out $output_dir/$file_name"@3x.png"

echo 'DONE'
