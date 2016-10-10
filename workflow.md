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
