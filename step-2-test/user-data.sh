#!/bin/bash
echo "### Installing HTTP daemon"
yum install -y httpd
echo "### Creating index.html file"
echo "Project ${name} " >> /var/www/html/index.html 
echo "Instance " >> /var/www/html/index.html 
curl http://169.254.169.254/latest/meta-data/instance-id >> /var/www/html/index.html
echo " created by Terraform" >> /var/www/html/index.html 
echo "### Configuring & Starting HTTP daemon"
systemctl start httpd
systemctl enable httpd
echo "### End of user-data actions"