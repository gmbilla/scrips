#!/bin/bash
#
# Create 3 copies of the given image with 32px, 64px, 96px size
#

MULTIPLIER_MDPI=1
MULTIPLIER_HDPI=1.5
MULTIPLIER_XHDPI=2
MULTIPLIER_XXHDPI=3
MULTIPLIER_XXXHDPI=4
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
	echo "USAGE: " + `basename $0` + " [-o OUTPUT_DIR] size_in_dp image"
	exit 1
fi

size=$1
image=$2
size_mdpi=$(($size * $MULTIPLIER_MDPI))
size_hdpi=`echo "$size * $MULTIPLIER_HDPI" | bc`
size_xhdpi=$(($size * $MULTIPLIER_XHDPI))
size_xxhdpi=$(($size * $MULTIPLIER_XXHDPI))
size_xxxhdpi=$(($size * $MULTIPLIER_XXXHDPI))

echo "Converting $image to "$size"dp drawable (output directory: $output_dir)"

# Check if output_dir is a directory
if [ ! -d "$output_dir" ]; then
	echo "Given output URI isn't a directory: $output_dir"
	exit 1
fi
# CCreated (if necessary) subdirs
dir_mdpi="$output_dir/drawable-mdpi"
mkdir -p $dir_mdpi
dir_hdpi="$output_dir/drawable-hdpi"
mkdir -p $dir_hdpi
dir_xhdpi="$output_dir/drawable-xhdpi"
mkdir -p $dir_xhdpi
dir_xxhdpi="$output_dir/drawable-xxhdpi"
mkdir -p $dir_xxhdpi
dir_xxxhdpi="$output_dir/drawable-xxxhdpi"
mkdir -p $dir_xxxhdpi

# Check image size
for side in `sips -g pixelWidth -g pixelHeight $image | sed -n 's/.*pixel.*: \([0-9]*\)/\1/p'`; do
	if [[ $side -lt $size_xxxhdpi ]]; then
		echo "Given image smallest side should be at least $size_xxxhdpi px (currently $side px)"
		exit 1
	fi
done

# Convert
format=`sips -g format $image | sed -n 's/.*format: \([a-z]*\)/\1/p'`
file_name=`basename $image | sed -n "s/\(.*\)\.$format/\1/p"`
sips -Z $size_mdpi -s format png $image --out $dir_mdpi/$file_name"_$size""dp.png"
sips -Z $size_hdpi -s format png $image --out $dir_hdpi/$file_name"_$size""dp.png"
sips -Z $size_xhdpi -s format png $image --out $dir_xhdpi/$file_name"_$size""dp.png"
sips -Z $size_xxhdpi -s format png $image --out $dir_xxhdpi/$file_name"_$size""dp.png"
sips -Z $size_xxxhdpi -s format png $image --out $dir_xxxhdpi/$file_name"_$size""dp.png"
# sips -Z $size_big -s format png $image --out $output_dir/$file_name"@2x.png"

echo 'DONE'
