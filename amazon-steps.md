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


Use s3fs to access bucket. Information [here](https://github.com/s3fs-fuse/s3fs-fuse).

1. Install (for Ubuntu 14.04) on s3fs

  ```shell
  sudo apt-get install automake autotools-dev g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config
  ```
  
2. Clone repo and install

  ```shell
  git clone https://github.com/s3fs-fuse/s3fs-fuse.git
  cd s3fs-fuse
  ./autogen.sh
  ./configure
  make
  sudo make install
  ```
  
3. Enter S3 identity and credential

  ```shell
  echo MYIDENTITY:MYCREDENTIAL > ~/.credentials.aws.cow
  ```
