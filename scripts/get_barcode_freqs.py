#!/usr/bin/env python
# this is from this GIST
# https://gist.github.com/7a1e8608b82c5ce580c9.git
from __future__ import division

from sys import argv

from qiime.util import parse_command_line_parameters, make_option, gzip_open

if argv[1].endswith('.gz'):
    f = gzip_open(argv[1])
else:
    f = open(argv[1],'U')

outf = open(argv[2], "w")

barcode_len = int(argv[3])

barcodes = {}

counter = 0

total_bcs = 0

for line in f:
    if counter == 1:
        curr_barcode = line.strip()[0:barcode_len]

        try:
            barcodes[curr_barcode] += 1
        except KeyError:
            barcodes[curr_barcode] = 1
    total_bcs += 1
    counter += 1
    if counter == 4:
        counter = 0

bcs_list = []

for d in barcodes:
    bcs_list.append((barcodes[d], d))

bcs_list.sort(reverse=True)

outf.write("Top 1000 most frequent barcodes\n")
outf.write(argv[1] + '\n' )
outf.write("Barcode sequence, frequency\n")

for bc_count, bc_seq in bcs_list[0:1000]:
    curr_line = "%s,%2.3f\n" % (bc_seq, (bc_count/total_bcs))

    outf.write(curr_line)



