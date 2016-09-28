#!/bin/bash

for i in *.fastq.gz
do
    split-paired-reads.py $i
done
