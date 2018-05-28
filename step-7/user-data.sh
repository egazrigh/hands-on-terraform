#<<EOF
#cloud-config
runcmd:
- yum install -y httpd
- echo "Project ${name} " >> /var/www/html/index.html 
- echo "Instance " >> /var/www/html/index.html 
- curl http://169.254.169.254/latest/meta-data/instance-id >> /var/www/html/index.html
- echo " created by Terraform" >> /var/www/html/index.html 
- systemctl start httpd
- systemctl enable httpd
#EOF