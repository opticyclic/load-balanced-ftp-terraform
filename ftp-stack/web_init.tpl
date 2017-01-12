#cloud-config
repo_update: true
repo_upgrade: all

packages:
 - curl
 - nfs-common
 - nginx
 - vsftpd

runcmd:
- service nginx start
- mkdir -p /var/www/html/data
- chown -R o+r /var/www/html/data/
- echo "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).fs-YYYYYYYY.efs.us-east-1.amazonaws.com:/ /var/www/html/data nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab
- mount -a -t nfs4