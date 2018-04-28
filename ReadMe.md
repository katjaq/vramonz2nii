## vramonz2nii

This scripts converts a `.vramonz` file into a pair of `.nii.gz` files, or viceversa.

To convert from `vramonz` to `nii.gz` use:

```
vramonz2nii.sh -i infile.vramonz -o /output/path/
```
The result will be a pair of `nii.gz` files called `infile.nii.gz` and `infile.sel.nii.gz`
located at `/output/path/`. The output filenames will be those internally encoded in
the `vramonz` file, and may not be as expected if the original `vramonz` file is corrupt.


To convert from a pair of `nii.gz` to `vramonz` use:

```
vramonz2nii.sh -v volfile.nii.gz -s segfile.nii.gz -o /output/file_root
```

The result will be a file named `file_root.vramonz` located at path `/output/`. The
file segfile will be converted to `int16`.

IMPORTANT: `vramonz2nii` relies internally on `fslchfiletype_exe` from FSL, which has to
be available.
