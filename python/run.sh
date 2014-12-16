#!/bin/bash
set -e
rm -f *.png *.eps
python setup.py build_ext --inplace
python main.py -in ~/Public/DATA/two_bird_together.aif --extract-notes -c songbird.conf
