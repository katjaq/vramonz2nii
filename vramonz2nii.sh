#!/bin/bash

# vramonz2nii
# Roberto Toro, April 2017
# v1, April 2017

if [ $# -eq 0 ]; then
    echo \
"
vramonz2nii, April 2017
This scripts converts a .vramonz file into a pair of .nii.gz files, or viceversa.

To convert from vramonz to nii.gz use:

    vramon2nii -v volfile.nii.gz -s segfile.nii.gz -o /output/file_root

The result will be a file named file_root.vramonz located at path /output/. The
file segfile will be converted to int16.

To convert from a pair of nii.gz to vramonz use:

    vramon2nii -i infile.vramonz -o /output/path/

The result will be a pair of nii.gz files called infile.nii.gz and infile.sel.nii.gz
located at /output/path/. The output filenames will be those internally encoded in
the vramonz file, and may not be as expected if the original vramonz file is corrupt.
"
    exit
fi

while [[ $# -gt 1 ]]
do
    key="$1"

    case $key in
    -i|--input)
        INPUT="$2"
        shift
        ;;
    -v|--volume)
        VOLUME="$2"
        shift
        ;;
    -s|--selection)
        SELECTION="$2"
        shift
        ;;
    -o|--output)
        OUTPUT="$2"
        shift
        ;;
    -v|--verbose)
        VERBOSE=YES
        ;;
    *)
        # unknown option
        ;;
    esac
    shift
done

# vramonz to nii
if [ ! -z $INPUT ]; then
    if [ -z $OUTPUT ]; then
        echo "ERROR: No output path"
        exit
    fi
    if [ ! -d $OUTPUT ]; then
        echo "ERROR: Output is not a path"
        exit
    fi

    echo "Extract volume from vramonz file"
    vol=$(unzip -c $INPUT *.vramon|awk -F= '{gsub(/[";]/,"")}/volume/{v=$2}END{print v}'|sed 's/.hdr//')
    echo $vol
    unzip -d $OUTPUT $INPUT $vol.hdr $vol.img
    fslchfiletype NIFTI_GZ $OUTPUT/$vol.img

    echo "Extract selection from vramonz file"
    sel=$(unzip -c $INPUT *.vramon|awk -F= '{gsub(/[";]/,"")}/selection/{v=$2}END{print v}'|sed 's/.hdr//')
    echo $sel
    unzip -d $OUTPUT $INPUT $sel.hdr $sel.img
    fslchfiletype NIFTI_GZ $OUTPUT/$sel.img
fi

# nii to vramonz
if [ ! -z $VOLUME ] &&  [ ! -z $SELECTION ]; then
    echo "This is about combining two nii files into a vramonz"
    if [ -z $OUTPUT ]; then
        echo "ERROR: No output path"
        exit
    fi
    if [ ! -f $VOLUME ]; then
        echo "ERROR: No 'volume' file"
        exit
    fi
    if [ ! -f $SELECTION ]; then
        echo "ERROR: No 'selection' file"
        exit
    fi

    name=${OUTPUT%.vramonz}
    name=$(basename $name)

    if [ -z $name ]; then
        echo "ERROR: Incorrect output file name"
        exit
    fi

    cat > $OUTPUT.vramon << EOF
{
volume="$name.hdr";
selection="$name.sel.hdr";
}
EOF
    fslchfiletype ANALYZE $VOLUME $OUTPUT
    fslchfiletype ANALYZE $SELECTION $OUTPUT.sel
    zip -jm $OUTPUT.vramonz $OUTPUT.vramon $OUTPUT.hdr $OUTPUT.img $OUTPUT.sel.hdr $OUTPUT.sel.img
fi
