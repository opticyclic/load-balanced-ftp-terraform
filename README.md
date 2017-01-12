# Load Balanced FTP server (TerraForm and Nginx)

Terraform is used to create the AWS resources (ec2, elb, security groups etc)

Ansible is used to provision the services (vsftpd, nginx, ftp user accounts etc)

The stack also creates a public name space for each user, where their FTP'd files will be served by Nginx, and viewed publically.