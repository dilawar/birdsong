#!/bin/bash
set -e
rm -f *.png *.eps
python setup.py build_ext --inplace
if [ $1 = "x" ]; then
    echo "Extracting notes"
    python main.py -in ~/Public/DATA/two_bird_together.aif --extract_notes -c chidiya.conf
else
    echo "processing notes"
    python main.py -in ~/Public/DATA/two_bird_together.aif --process_notes \
        -c chidiya.conf --note_file ./notes.dat
fi
