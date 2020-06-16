provider "aws" {
        region = "ap-south-1"
	profile = "attriprofile"
}

variable ami_id {
        default = "ami-0447a12f28fddb066"
}

variable instance_name {
        default = "rahul-server"
}

variable server-sg_name {	
	default = "server-sgfromtf"
}

variable bucket_name {	
	default = "rahul-attri1997-bucket"
}

variable key_name {
	default = "tf1"
}

variable object_name {	
	default = "guru.jpg"
}

resource "tls_private_key" "key-pair" {
	algorithm = "RSA"
	rsa_bits = 4096
}

resource "local_file" "private-key" {    
        content = tls_private_key.key-pair.private_key_pem
        filename = 	"${var.key_name}.pem"
        file_permission = "0400"
}

resource "aws_key_pair" "key-pair-tf1" {  
        key_name   = var.key_name
        public_key = tls_private_key.key-pair.public_key_openssh
}

resource "aws_security_group" "server-sg" {
	name = var.server-sg_name
	description = "Allow HTTP and SSH inbound traffic"
	
	ingress	{	
		from_port = 80
      		to_port = 80
      		protocol = "tcp"
      		cidr_blocks = ["0.0.0.0/0"]
      		ipv6_cidr_blocks = ["::/0"]
      	}
      	
      	ingress {	
      		from_port = 22
      		to_port = 22
      		protocol = "tcp"
      		cidr_blocks = ["0.0.0.0/0"]
      		ipv6_cidr_blocks = ["::/0"]
      	}
      	
      	ingress {	
      		from_port = -1
      		to_port = -1
      		protocol = "icmp"
      		cidr_blocks = ["0.0.0.0/0"]
      		ipv6_cidr_blocks = ["::/0"]
      	}
      	
      	egress {
      		from_port = 0
      		to_port = 0
      		protocol = "-1"
      		cidr_blocks = ["0.0.0.0/0"]
      	}
}

resource "aws_instance" "server" {	
        ami = var.ami_id
	instance_type = "t2.micro"
	key_name = var.key_name
	security_groups = [ aws_security_group.server-sg.name ]
	
	tags = {
		Name = var.instance_name
	}
	
	connection {
    		type     = "ssh"
    		user     = "ec2-user"
    		private_key = file("${var.key_name}.pem")
    		host = aws_instance.server.public_ip
  	}
	
	provisioner "local-exec" {
		command = "echo ${aws_instance.server.public_ip} > public-ip.txt"
	}
	
	provisioner "remote-exec" {
		
		inline = [
	                   "sudo yum install httpd  git -y",
                           "sudo systemctl start httpd",
                           "sudo systemctl enable httpd",
                           "sudo systemctl restart httpd"
		        ]
	}
}

resource "aws_ebs_volume" "pendrive" {
        availability_zone = aws_instance.server.availability_zone
        size              = 1

        tags = {
        Name = "p-drive"
  }
}

resource "aws_volume_attachment" "pd_attach" {
        device_name = "/dev/sdh"
        volume_id   = aws_ebs_volume.pendrive.id
        instance_id = aws_instance.server.id
        force_detach = true
}

resource "null_resource" "attach-pd" {
	depends_on = [
		aws_volume_attachment.pd_attach,
	]
	
	connection {
    		type     = "ssh"
    		user     = "ec2-user"
    		private_key = file("${var.key_name}.pem")
    		host = aws_instance.server.public_ip
  	}
	
	provisioner "remote-exec" {
		
		inline = [
			"sudo mkfs.ext4  /dev/xvdh",
                        "sudo mount  /dev/xvdh  /var/www/html",
                        "sudo rm -rf /var/www/html/*",
                        "sudo git clone https://github.com/attri97/web-app-data.git /var/www/html/"
		
		]
	}
}

resource "aws_s3_bucket" "picture1997-bucket" {
        depends_on = [
		null_resource.attach-pd,
	]
	
	bucket = var.bucket_name
	acl = "public-read"
	
	provisioner "local-exec" {
	
	       command = "git clone https://github.com/attri97/server-picture.git server-picture10001"
	}
	
	provisioner "local-exec" {
	
		when = destroy
		command = "rmdir -rf server-picture10001"
	}	
}

resource "aws_s3_bucket_object" "picture-upload" {
        key = var.object_name
        bucket = aws_s3_bucket.picture1997-bucket.bucket
        acl    = "public-read"
        source = "server-picture10001/chanakya.jpg"
}

locals {
	s3_origin_id = "S3-${aws_s3_bucket.picture1997-bucket.bucket}"
}

resource "aws_cloudfront_distribution" "cloudfront" {
	enabled = true
	is_ipv6_enabled = true
	
	origin {
		domain_name = aws_s3_bucket.picture1997-bucket.bucket_domain_name
		origin_id = local.s3_origin_id
	}
	
	default_cache_behavior {
    		allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    		cached_methods   = ["GET", "HEAD"]
    		target_origin_id = local.s3_origin_id

    		forwarded_values {
      			query_string = false

      			cookies {
        			forward = "none"
      			}
    		}
    		
    		viewer_protocol_policy = "allow-all"
    	}
    	
    	restrictions {
    		geo_restriction {
    			restriction_type = "none"
    		}
    	}
    	
    	viewer_certificate {
    
    		cloudfront_default_certificate = true
  	}
  	
  	connection {
    		type     = "ssh"
    		user     = "ec2-user"
    		private_key = file("${var.key_name}.pem")
    		host = aws_instance.server.public_ip
  	}
  	
  	provisioner "remote-exec" {
  		
  		inline = [
  			
                        "sudo systemctl restart httpd",
  			"sudo su << EOF",
                        "echo \"<img src='http://${self.domain_name}/${aws_s3_bucket_object.picture-upload.key}' width='300' height='600'>\" >> /var/www/html/guru.html",
                        "sudo systemctl restart httpd",
            		"EOF",	
  		]
  	}
}

output "Instance-Public-IP" {
	value = aws_instance.server.public_ip
}
