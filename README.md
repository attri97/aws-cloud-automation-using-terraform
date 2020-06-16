CLOUD COMPUTING with AWS :-  
                           Amazon Web Services (AWS) is the world's most comprehensive and broadly adopted cloud platform, offering over 175 fully featured services from data centers globally. Millions of customers - including the fastest-growing startups, largest enterprises, and leading government agencies - are using AWS to lower costs, become more agile, and innovate faster.
                           
What is TERRAFORM ?
                   Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can help with multi-cloud by having one workflow for all clouds. The infrastructure Terraform manages can be hosted on public clouds like AWS, MS Azure, and Google Cloud Platform, or on-prem in private clouds such as VMWare vSphere, OpenStack, or CloudStack. Terraform treats infrastructure as code (IaC) so you never have to worry about you infrastructure drifting away from its desired configuration.
                   
TASK DESCRIPTION:-

I will show you how to create complete infrastructure of hosting a web page on AWS Cloud using Terraform.
Following steps will be followed :

STEP1 : First creating a key-pair and storing it in our local machine. This key will be used to login into our EC2 machine.  

STEP2 : Creating a security group which allows Port No 80 (for HTTP) and Port No 22 (for SSH).

STEP3 : Then, launching an EC2 instance with the key-pair and security group created in above steps.

STEP4 : We will now configure our O.S. so that it can be used to host a web page — Install Apache Web Server, PHP and start the required services.

STEP 5: Now, we will create an EBS volume and attach it to our instance.

STEP 6: Mount the volume into default directory of web server. The whole process of formatting and mounting the volume will be done using Terraform.

STEP 7: Now, we will clone the Github repo containing the webpage, to our volume’s directory.

STEP 8: We will then create a S3 bucket which will store the images for our web page.

STEP 9: Finally, we will create a CloudFront distribution for faster delivery of the image. At last, the CloudFront URL will be appended into our web page.

So now let’s begin!

NOTE : For performing this practical, you should have Terraform installed in your local machine.
