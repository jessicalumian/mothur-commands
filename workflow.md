# Mothur workflow using JGI iTagger Data

## Stuff to download before beginning

1. [SILVA-based bacterial reference alignment](http://www.mothur.org/w/images/9/98/Silva.bacteria.zip)
   * more information on this on the [mothur MiSeq SOP](http://www.mothur.org/wiki/MiSeq_SOP)
2. [Full length sequences and taxonomy references - Silva v1.2.3](http://www.mothur.org/w/images/b/be/Silva.nr_v123.tgz)
   * more information on this on the [Silva Reference Files informational page](http://www.mothur.org/wiki/Silva_reference_files)

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

10. Primer sequences are listed [on protocol](http://1ofdmq2n8tc36m6i46scovo2e.wpengine.netdna-cdn.com/wp-content/uploads/2016/04/iTag-Sample-Amplification-QC-v1.3.pdf). Download E coli 16S from [NCBI genome page](https://www.ncbi.nlm.nih.gov/nuccore/174375?report=fasta). Primer sequences will be aligned to 16S sequence to determine start and end point of V4 region using pcr.seqs in mothur.
  
  First, an oligos file must be generated. Because this protocol uses paired sequences, the format `primer ATTAGAWACCCBDGTAGTCC  CCCGTCAATTCMTTTRAGT  V5` is used. [Informational page on Oligos File formats here](http://www.mothur.org/wiki/Oligos_File).

  Then, align primers to E. coli 16S.

  ```bash
  pcr.seqs(fasta=ecoli.16s.fasta, oligos=primer.oligos)
  ```
  This creates:
   * **ecoli.16s.pcr.fasta** - fasta file of 16S sequence between primers in oligos file only.

11. Now, align sequence of 16S between primers to silva reference file.
 
  ```bash
  align.seqs(fasta=ecoli.16s.pcr.fasta, reference=silva.bacteria.fasta)
  ```
  This creates:
    * **ecoli.16s.pcr.align** - alignment of ecoli 16S primer sequence to silva reference file.
    * **ecoli.16s.pcr.align.report** - quality report of previous file
    
12. To get start and end locations, run summary.seqs on your aligned E. coli file.

  ```bash
  summary.seqs(fasta=ecoli.16s.pcr.align)
  ```
  Start and end locations will be present in report printed to screen. These sequences will be used as parameters in the next command. In the case of the specific primers used in the study I'm using to write this guide, the start sequence position is 13862 and the end position is 23444 (16S V4 sequencing with JGI iTagger primers).

13. Align sequences to reference alignment using start and end positions from previous step. `keepdots` is set to false to clean up output trailing dots from fragments in alignment.

  ```bash
  pcr.seqs(fasta=silva.bacteria.fasta, start=13862, end=23444, keepdots=F, processors=3)
  ```
  This creates:
    * **silva.bacteria.pcr.fasta** - alignment of reads to database

14. (Optional, but done in written instructions) Rename output file to simpler name.
  
  ```bash
  system(mv silva.bacteria.pcr.fasta silva.v4.fasta)
  ```
15. Look at summary of new silva.v4.fasta file.

  ```bash
  summary.seqs(fasta=silva.v4.fasta)
  ```
16. Create alignment of customized reference alignment between current contigs file and reference alignment, then run `summary.seqs` on output.

  ```bash
  align.seqs(fasta=stability.trim.contigs.good.unique.fasta, reference=silva.v4.fasta)
  summary.seqs(fasta=stability.trim.contigs.good.unique.align, count=stability.trim.contigs.good.count_table)
  ```
  This creates:
    * **stability.trim.contigs.good.unique.align** - aligned sequences from current fasta file
    * **stability.trim.contigs.good.unique.align.report** - quality report of previous sequences
    * **stability.trim.contigs.good.unique.flip.accnos** - filtered sequences

17. Again, screen sequences based on output of file (predominant start and stop numbers in summary seqs). Look into max homopolymer length parameter for specific dataset. Then, run another summary sequences command.

  ```bash
  screen.seqs(fasta=stability.trim.contigs.good.unique.align, count=stability.trim.contigs.good.count_table, summary=stability.trim.contigs.good.unique.summary, start=XX, end=XX) # include maxhomp=8 if applicable
  summary.seqs(fasta=current, count=current)
  ```
  `screen.seqs` creates:
    * **stability.trim.contigs.good.unique.good.summary**
    * **stability.trim.contigs.good.unique.good.align**
    * **stability.trim.contigs.good.uniuqe.bad.accnos**
    * **stability.trim.contigs.good.good.count_table**
    
18. Remove 5' and 3' sequence overhangs (shouldn't be too much of an issue because paired end sequencing was done). Also pull out alignment characters that only consist of "-". Then, rerun `unique.seqs` in case new redundant sequences were created by trimming.

  ```bash
  filter.seqs(fasta=stability.trim.contigs.good.unique.good.align, vertical=T, trump=.)
  unique.seqs(fasta=stability.trim.contigs.good.unique.good.filter.fasta, count=stability.trim.contigs.good.good.count_table)
  ```
  This produces stats showing how many columns in alignments were present and then removed.
  `filter.seqs` creates:
    * **stability.filter**
    * **stability.trim.contigs.good.unique.good.filter.fasta**
    `unique.seqs` creates:
    * **stability.trim.contigs.good.unique.good.filter.count_table**
    * **stability.trim.contigs.good.unique.good.filter.unique.fasta**
   
  
19. Next, use `pre.cluster` to further de-noise sequences. With `diffs=2`, up to two nucleotides may be different from each other in sequences and still be merged. Merges will occur using the abundances of both reads relative to each other.

  ```bash
  pre.cluster(fasta=stability.trim.contigs.good.unique.good.filter.unique.fasta, count=stability.trim.contigs.good.unique.good.filter.count_table, diffs=2)
  ```
  This creates:
    * **stability.trim.contigs.good.unique.good.filter.unique.preclust.fasta**
    * **stability.trim.contigs.good.unique.good.filter.unique.preclust.count_table**
    * **stability.trim.contigs.good.unique.good.filter.unique.preclust.16S.V4.CS.Y.0hr.map** - there are maps for all conditions
 
20. Now, remove chimeras using UCHIME algorithm. `dereplicate` is set to true because the MiSeq Mothur tutorial recommends this, as setting the parameter to false can remove sequences simply because they are rare. `remove.seqs` will be used to remove chimeric sequences from the count file, but will leave them in the fasta file. Finally, run `summary.seqs` to view what is left over.

  ```bash
  chimera.uchime(fasta=stability.trim.contigs.good.unique.good.filter.unique.precluster.fasta, count=stability.trim.contigs.good.unique.good.filter.unique.precluster.count_table, dereplicate=t)
  remove.seqs(fasta=stability.trim.contigs.good.unique.good.filter.unique.precluster.fasta, accnos=stability.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.accnos)
  summary.seqs(fasta=current, count=current)
  ```
  `chimera.uchime` creates:
    * **stability.trim.contigs.good.unique.good.filter.unique.precluster.denovo.unchime.pick.count_table**
    * **stability.trim.contigs.good.unqiue.good.filter.unique.precluster.denovo.uchime.chimeras**
    * **stability.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.accnos**
    
   `remove.seqs` creates:
    * **stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta**
  
21. Use `classify.seqs` to see if any undesired sequences have persisted in the dataset. Remove chloroplasts or mitochondria sequences with `remove.lineage` command. Make sure to download taxonomy trainset files and have them in correct directory.

  ```bash
  classify.seqs(fasta=stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta, count=stability.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, reference=silva.nr_v123.align, taxonomy=silva.nr_v123.tax, cutoff=80)
  remove.lineage(fasta=stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta, count=stability.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table, taxonomy=stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.nr_v123.wang.taxonomy, taxon=Chloroplast-Mitochondria-unknown-Eukaryota)
  ```
  `classify.seqs` creates:
    * **stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.nr_n123.wang.taxonomy**
    * **stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.nr_v123.wang.tax.summary**
    
  `remove.lineage` creates:
    * **stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.nr_v123.wang.pick.taxonomy**
    * **stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta**
    * **stability.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table**
    
22. It is time for clustering sequences into OTUs! `cluster.split` will be used because it has the Schloss lab seal of approval according to the tutorial and because of the large nature of this data set.
  ```bash
  cluster.split(fasta=stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta, count=stability.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table, taxonomy=stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.nr_v123.wang.pick.taxonomy, splitmethod=classify, taxlevel=4, cutoff=0.15)
  ```
  
  `cluster.split` creates:
    * **stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.an.unique_list.list**
    
23. Now, use `make.shared` command to determine how many sequences are in each OTU at the 0.03 cutoff level.
  ```bash
  make.shared(list=stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.an.unique_list.list, count=stability.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table, label=0.03)
  ```
  This creates:
  * **stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.an.unique_list.shared**

24. Determine taxonomy for all OTUs. (YAY!!)
  ```bash
  classify.otu(list=stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.an.unique_list.list, count=stability.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table, taxonomy=stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.nr_v123.wang.pick.taxonomy, label=0.03)
  ```
  This creates:
    * **stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.an.unique_list.0.03.cons.taxonomy**
    * **stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.an.unique_list.0.03.cons.tax.summary**
  
25. Rename monster files for OTU-based analysis, count how many sequences are in each sample, and sub sample if this is applicable to the situation.
  ```bash
  # note - maybe don't do this to keep things less confusing # system(mv ~/path/stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.pick.an.unique_list.shared ~/path/stability.an.shared)
  # ditto from above # system(mv ~/path/stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.pick.an.unique_list.0.03.cons.taxonomy ~/path/stability.an.cons.taxonomy)
  count.groups(shared=stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.an.unique_list.shared)
  # check if sub sampling is necessary
  sub.sample(shared=stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.an.unique_list.shared, size=327912) # size comes from number of sequences in smallest sample
  ```
  
  `count.groups` creates:
    * **subset-CS-Y-16S-reads/stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.an.unique_list.count.summary**
    
    In subset, group with smallest number of samples is 327912, so that number is in sub.sample command. This was determined by the output of count.groups.


26. Calculate alpha diversity of samples using rarefaction command. To standardize the acluation, use `summary.single` to randomly select XXX sequences from each sample 1000 times and calculate the average.
  ```bash
  rarefaction.single(shared=stability.an.shared, calc=subs, freq=100)
  summary.single(shared=stability.an.shared, calc=seqs-coverage-sobs-invsimpson, subsample=XXX) # subsample=T
  ```
  `rarefaction.single` will generate `*.rarefraction` files that can be graphed in R. As a reminder, alpha diversity is a measure of richness, not diversity.
  
27. Create a heatmap based on beta diversity, the following command looks at the top 50 OTUs. This heatmap is good to get an idea of beta diversity, but a proper heat map should be generated using R.
  ```bash
  heatmap.bin(shared=stability.an.0.03.subsample.shared, scale=log2, numotu=50)
  ```
28. Look at similarity of membership and structure found in various samples by rarefying data. Then, visualize using `heatmap.sim`.
  ```bash
  dist.shared(shared=stability.an.shared, calc=thetayc-jclass, subsample=XXXX)
  heatmap.sim(phylip=stability.an.thetayc,0.03.lt.ave.dist)
  heatmap.sim(phylip=stability.an.jclass.0.03.lt.ave.dist)
  ```
  From here on, additional diagrams can be made, such as venn diagrams, parsimony pairwise comparisons, and PCoA plots.
