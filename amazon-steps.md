1. Create stability.files using jgi-to-mothur.txt commands.

2. Mount full data set on Amazon S3.

3. Select Amazon EC2 machine. For full data, m4.4xlarge.

5. Search for and select mothur AMI
More info here: [http://mothur.org/wiki/Mothur_AMI](http://mothur.org/wiki/Mothur_AMI)

4. Before launching, add 400 GB storage.

5. Remove example data in /data (or `mkdir data` if it doesn't exist)

6. Mount data in /data by downloading from bucket.

  ```shell
  aws s3 cp s3://cow-rumen-jgi-itagger-16s-18s-its2-temporal-hess/* data/*
  ```


7. Copy over mothur stability.batch.amazon.1 and run it with 


## Use s3fs to access bucket. Information [here](https://github.com/s3fs-fuse/s3fs-fuse).

1. Install (for Ubuntu 14.04) on s3fs

  ```shell
  sudo apt-get update
  sudo apt-get install automake autotools-dev g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config screen
  ```
2. Install khmer

  ```shell
  cd ~/
  python2.7 -m virtualenv work
  source work/bin/activate
  pip install -U setuptools
  git clone https://github.com/dib-lab/khmer.git
  cd khmer
  make install
  ```
3. Clone repo and install

  ```shell
  git clone https://github.com/s3fs-fuse/s3fs-fuse.git
  cd s3fs-fuse
  ./autogen.sh
  ./configure
  make
  sudo make install
  ```
  
4. Enter S3 identity and credential (stored in rootkey.csv)

  ```shell
  echo MYIDENTITY:MYCREDENTIAL > ~/.credentials.aws.cow
  ```
5. Change permissions, create contact point

  ```shell
  chmod 600 ~/.credentials.aws.cow
  sudo mkdir /s3
  ```

6. Run s3fs with exisiting bucket (cow) and mount point (/s3 dir)

  ```shell
   sudo s3fs cow-rumen-jgi-itagger-16s-18s-its2-temporal-hess /s3 -o passwd_file=~/.credentials.aws.cow
  ```
  
7. Now, you can see your files in `/s3` and cp so you can work with it. This is cheaper than working with files directly from the s3 bucket. Also start screen at this point.

  ```shell
  sudo ls /s3
  screen
  for f in $(sudo ls /s3); do sudo cp /s3/$f mothur/data ; done
  ```
8. Move `stability.files` and batch file to aws (in repo)

9. Interleave reads using interleave-reads.sh script

10. In `mothur/data`, have `stability.files` and batch file. Then start mothur.

  ```shell
  mothur stability.batch.file.name.goes.here
  ```
