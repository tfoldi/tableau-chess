#!/bin/sh

echo "index,color,pieces" > chess_table.csv
for idx in `seq 0 63` ; do for clr in  black white ; do for code in `seq 6` ; do echo "$idx,$clr,$code" ; done ; done ; done >> chess_table.csv
for idx in `seq 0 63` ; do echo "$idx,free,0" ; done >> chess_table.csv

