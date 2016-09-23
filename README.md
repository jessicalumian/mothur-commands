# mothur-commands

Helpful tip - within mothur, you can do shell operations with system command. For example:
```shell
mothur > system(ls) # this is for when mothur is already running
```
Note: `mothur >` should always be present at beginning of command line as this signifies being inside mothur. I won't be typing it out in each command.

Also, at any time during session, run
```shell
get.current()
``` 

## Start mothur and set up directories

First, start mothur. Navigate to mothur directory and type:
```shell
./mothur
```

Set input and output directories
```shell
set.dir(input=../path/goes/here)
set.dir(output=../path/goes/here)
```

## Get rid of errors from sequencing or PCR

Make input file that has read information. This makes stability.files file, which makes a table with three columns: sample_ID R1 R2
```shell
make.file(input=../path/to/reads) # if gzipped, do (input=../path, type=gz)
```

Now, make contigs from reads using make.contigs command. This prints out a list of sequence IDs and counts, and also produces stability.trim.contigs.fasta (the actual sequence data) and stability.contigs.groups (group identity for each sequence).
```shell
make.contigs(file=stability.files, processors=3)
```

Use stability.contigs.reports file generated in previous step to make summary statistics report:
```shell
summary.seqs(fasta=stability.trim.contigs.fasta)
```

Now, remove reads longer than 275 bp (or change length) and get rid of ambiguous bases:
```shell
mothur > screen.seqs(fasta=stability.trim.contigs.fasta, group=stability.contigs.groups, summary=stability.trim.contigs.summary, maxambig=0, maxlength=275)
```
