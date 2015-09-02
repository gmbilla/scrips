#!/bin/bash
#
# Create 3 copies of the given image with 32px, 64px, 96px size
#

TAB_SIZE_BASE=32
TAB_SIZE_BIG=64
TAB_SIZE_HUGE=96
BAR_SIZE_BASE=32
BAR_SIZE_BIG=64
BAR_SIZE_HUGE=96
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

shift $(($OPTIND - 2))

if [[ $# < 1 ]]; then
	echo "USAGE: $0 [-o OUTPUT_DIR] asset image"
	exit 1
fi

asset=$1
image=$2
echo "Converting $image to asset $asset (output directory: $output_dir)"

# Check if output_dir is a directory
if [ ! -d "$output_dir" ]; then
	echo "Given output URI isn't a directory: $output_dir"
	exit 1
fi

case "$asset" in
	tab) $size_base = $TAB_SIZE_BASE
		 $size_big = $TAB_SIZE_BIG
		 $size_huge = $TAB_SIZE_HUGE
		 ;;
	bar) $size_base = $BAR_SIZE_BASE
		 $size_big = $BAR_SIZE_BIG
		 $size_huge = $BAR_SIZE_HUGE
		 ;;
	*) echo "Unrecognized asset $asset. Available options: tab, bar"
	   exit 1
	   ;;
esac

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
