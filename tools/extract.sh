#!/bin/bash
rm -rf extracted
mkdir extracted
python3 extract.py
./hactool --intype=kip1 --uncompressed=extracted/Loader-dec.kip extracted/Loader.kip
python3 patch.py
rm -rf extracted
sleep 1
exit
