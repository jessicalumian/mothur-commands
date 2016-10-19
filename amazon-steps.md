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

