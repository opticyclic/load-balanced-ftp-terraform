#default
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

variable "region" {
    default = "us-east-1"
}

variable "az" {
  type = "map"
  default = {
    "0" = "us-east-1b"
    "1" = "us-east-1c"
  }
}

variable "ftp_hostnames" {
  type = "map"
  default = {
    "0" = "ftp-1.some.domain.com"
    "1" = "ftp-2.some.domain.com"
  }
}

variable "subnet_id" {
  type = "map"
  default = {
    "0" = "subnet-YYYY"
    "1" = "subnet-XXXX"
    }
  }

resource "aws_security_group" "ftp-elb" {
    name = "ftp-elb"
    description = "HTTP/HTTPS/FTP from anywhere"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = "80"
        to_port = "80"
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }

    ingress {
        from_port = "443"
        to_port = "443"
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }
    ingress {
        from_port = "21"
        to_port = "21"
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }
    ingress {
        from_port = "22"
        to_port = "22"
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
  tags {
    Name = "ftp-elb-sec"
  }
}

#create an elastic load balancer
resource "aws_elb" "ftp-elb" {
  name = "ftp-elb"
  security_groups = ["${aws_security_group.ftp-elb.id}"]
  subnets = [ "${aws_instance.ftp.*.subnet_id}" ]
  #availability_zones = ["${aws_instance.ftp.*.availability_zone}"]

  #bucket to store access logs
  access_logs {
    bucket = "ftp-logs"
    bucket_prefix = "ftp-access"
    interval = 60
  }

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "arn:aws:acm:us-east-1:0000000000000:certificate/xxxxxx-xxxxx-xxxx-xxx-xxxxx-xxx"
  }
  #listener {
    #instance_port = 21
    #instance_protocol = "tcp"
    #lb_port = 21
    #lb_protocol = "tcp"
  #}
  #listener {
    #instance_port = 22
    #instance_protocol = "tcp"
    #lb_port = 22
    #lb_protocol = "tcp"
  #}
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }

  #register ftp-* instances to ELB resource
  instances = ["${aws_instance.ftp.*.id}"]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "ftp-elb"
  }
}


resource "template_file" "ftp_server_init" {
  count = 2
  template = "${file("web_init.tpl")}"
  vars {
    hostname = "${lookup(var.ftp_hostnames, count.index)}"
    mount_point = "/var/www/"
  }
}

#nginx webserver instance
resource "aws_instance" "ftp" {
    count = 2
    ami = "${var.aws_amis}"
    availability_zone = "${lookup(var.az, count.index)}"
    instance_type = "${var.instance_type}"
    key_name= "${var.key_name}"
    subnet_id= "${lookup(var.subnet_id, count.index)}"
    vpc_security_group_ids = [ "sg-xxxxxxxx", "sg-yyyyyyyy" ]
    user_data = "${element(template_file.ftp_server_init.*.rendered, count.index)}"

  tags {
      Name = "${format("ftp-%03d", count.index + 1)}"
    }    
}

resource "aws_route53_record" "ftp" {
  count = 2
  zone_id = "${var.aws_route53_zone_id}"
  name = "${lookup(var.ftp_hostnames, count.index)}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.ftp.*.private_ip, count.index)}"]
}