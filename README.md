# mothur-commands


Start by de-interleaving reads from JGI. I am using the split-paired-reads.py script from [khmer](https://github.com/dib-lab/khmer), using khmer version 2.0 and screen version 0.9. From data directory, after creating virtual environemnt and installing khmer:

```shell
split-paired-reads.py -1 reads.1 -2 reads.2
```


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
make.file(inputdir=../path/to/reads) # if gzipped, do (inputdir=../path, type=gz)
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
screen.seqs(fasta=stability.trim.contigs.fasta, group=stability.contigs.groups, summary=stability.trim.contigs.summary, maxambig=0, maxlength=275)
```

## Processing improved sequences

Get rid of duplicate sequences to simplify downstream computational analysis. Output is table where first column is the number of sequences characterized and second column is number of remaining sequences. The new file `stability.trim.contigs.good.unique.fasta` is generated.
```shell
unique.seqs(fasta=stability.trim.contigs.good.fasta)
```

Generate table with rows that are names of unique sequences and columns names of groups, table is populated with number of times each unique sequence shows up in each group.
```shell
count.seqs(name=stability.trim.contigs.good.names, group=stability.contigs.good.groups)
```

Now look at table with summary.seqs:

```shell
summary.seqs(count=stability.trim.contigs.good.count_table)
```

Align sequences to reference alignmentment. `fasta` is the SILVA database file (download the most recent version [here](http://www.mothur.org/wiki/Silva_reference_files) and put in file with data). `start` and `stop` are where sequences in alignment start and stop (must be determined ahead of time) and trims to these positions, `keepdots` refers to keeping leading and trailing periods, "." characters and it is set to false here, with the default being true.


```shell
pcr.seqs(fasta=silva.nr_v123.align, start=11894, end=25319, keepdots=F, processors=3)
```

Optional: can rename pcr.out files for convenience:

```shell
system(mv ../2016-09-23-teal-tutorial/MiSeq_SOP/silva.nr_v123.pcr.align ../2016-09-23-teal-tutorial/MiSeq_SOP/silva.v4.fasta)
```
