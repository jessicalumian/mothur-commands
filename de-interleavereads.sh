#!/bin/bash

for i in *.fastq.gz
do
    ref_name="$(basename $i .fastq.gz)"
    echo "reference name is $ref_name"
    split-paired-reads.py $i -1 ${ref_name}_R1_.fastq.gz -2 ${ref_name}_R2_.fastq.gz --gzip
    rm $i
done
