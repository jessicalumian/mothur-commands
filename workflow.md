# Mothur workflow using JGI iTagger Data

## Preparing files

1. Acquire `sequnit_primer_sample.tsv` file from JGI which is in the following format:

  ```shell
  8400.1.9999.AACTGTGCGTA.fastq.gz 16S-V4 CS-Y-24hr-1
               ...                  ...      ...
  ```

2. Run through [Reformatting JGI to mothur](https://github.com/jessicamizzi/mothur-commands/blob/master/reformatting-jgi-to-mothur.txt) commands. This will give a file in the mothur stability.files format:

  ```shell
  16S.V4.CS.Y.24hr  8400.1.9999.AACTGTGCGTA_R1_.fastq.gz 8400.1.9999.AACTGTGCGTA_R2_.fastq.gz
       ...                           ...                                  ...
  ```

  Note: sample duplicates (sample 1 or 2) are not currently in file names in the first column. This may need to be added.

3. Demultiplex reads using `split-paired-reads.py` script in khmer. In this workflow, khmer v2.0 was installed on a virtual machine and the [de-interleavereads.sh](https://github.com/jessicamizzi/mothur-commands/blob/master/de-interleavereads.sh) script was used. (This can be done before the previous two steps)

4. Navigate to mothur directory (version 1.37.2 used here). Open mothur, set input/output directory. Make sure your input directory contains demultiplexed reads and stability.files file created in steps 1 and 2. Create contigs using as many processors as you can spare. :)
  
  ```shell
  ./mothur
  set.dir(input=../path/to/input)
  set.dir(output=../path/to/output)
  make.contigs(file=stability.files, processors=3)
  ```
  Note - `make.file(inputdir=../path/to/reads, type=gz)` isn't used because stability.files has already been created in steps 1 and 2. This handy command can't be used because reads are initially interleaved and not named in a unique way.
  
  `make.contigs` creates 6 files:
    * **stability.trim.contigs.fasta** - a FASTA file with assembled paired end sequences
    * **stability.trim.contigs.qual** - quality score for stab.trim fasta file
    * **stability.contigs.report** - a report for each contig, number of Ns, etc
    * **stability.contigs.groups** - contains linker between sequence and sample
    * **stability.scrap.contigs.fasta** - what didn't assemble
    * **stability.scrap.contigs.qual** - quality score for what didn't assemble

5. Next, get summary report on contigs.
  ```bash
  summary.seqs(fasta=stability.trim.contigs.fasta)
  ```
  This will create 
    * **stability.trim.contigs.summary** - contains information about each sequence.
    
6. Cleaning data - get rid of sequences with ambiguous base calls, set max length to 305. **This number is currently arbitrary. Make sure to check and rerun**
  ```bash
  screen.seqs(fasta=stability.trim.contigs.fasta, group=stability.contigs.groups, maxambig=305)
  ```
  This uses `stability.contigs.groups` file from previous step. This creates the following files:
    * **stability.contigs.good.groups** - quality filtered `stability.contigs.groups` (sanity check - make sure it's shorter than previous file)
    * **stability.trim.contigs.bad.accnos** - list of reads filtered out along with reason (ambig, length, etc)
    * **stability.trim.contigs.good.fasta** - fasta containing quality filtered reads (same sanity check as good.groups)

7. Cleaning data - get rid of redundant sequences using `unique.seqs` command
  
  ```bash
  unique.seqs(fasta=stability.trim.contigs.good.fasta)
  ```
  This creates:
    * **stability.trim.contigs.good.names** - contains information about merged reads if they are identical
    * **stability.trim.contigs.good.unique.fasta** - fasta file containing only unique reads

8. Create count table of current unique sequences

  ```bash
  count.seqs(name=stability.trim.contigs.good.names, group=stability.contigs.good.groups)
  ```
  
  This creates:
    * **stability.trim.contigs.good.count_table** - table of all reads and which sample they appear in
    
9. (Optional) - can not get summaries using new count table

  ```bash
  summary.seqs(count=stability.trim.contigs.good.names, group=stability.contigs.good.groups)
  ```
  This time, `summary.seqs` is taking in the newly generated count table instead of the fasta file. Similar, but not identical, results could be obtained using the current fasta file and running `summary.seqs` with the `fasta` parameter.
  This creates:
    * **stability.trim.contigs.good.unique.summary** - summary of count report

10. Primer sequences are listed [on protocol](http://1ofdmq2n8tc36m6i46scovo2e.wpengine.netdna-cdn.com/wp-content/uploads/2016/04/iTag-Sample-Amplification-QC-v1.3.pdf). Download E coli 16S from [NCBI genome page](https://www.ncbi.nlm.nih.gov/nuccore/174375?report=fasta). Primer sequences will be aligned to 16S sequence to determine start and end point of V4 region.
