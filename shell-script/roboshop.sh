#!/bin/bash
set -e
USER_ID=$(id -u)

case $USER_ID in
  0)
    echo  "Starting Installation"
    ;;
  *)
    echo -e "\e[1;31mYou should be a root user to perform this script\e[0m"
    #use exit status to stop script on errors
    exit 1
  ;;
esac
## Function
Print(){
    echo -e "\e[1;33m**********>>>>>>>>>>>> $1 <<<<<<<<<<***********\e[0m"

}
statusCheck(){
  case $? in
    0)
      echo -e "\e[1;32mSUCCESS\e[0m"
      ;;
    *)
      echo  -e "\e[1;31mFAILURE\3[0m"
      exit 3
      ;;
  esac
}
# Main Program
case $1 in
  frontend)
    Print "Installing Nginx"
    yum install nginx -y
    statusCheck
    statusCheck
    Print "Downloading Frontend App"
    curl -s -L -o /tmp/frontend.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/db389ddc-b576-4fd9-be14-b373d943d6ee/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
    statusCheck
     cd /usr/share/nginx/html
     rm -rf *
     Print "Extracting Frontend Archive"
     unzip /tmp/frontend.zip
     mv static/* .
    rm -rf static README.md
    mv localhost.conf /etc/nginx/nginx.conf
    Print "Starting Nginx"
    systemctl enable nginx
    systemctl start nginx

    ;;
  catalogue)
   echo  Installing Catalogue
   echo Completed Installing Catalogue
   ;;
  cart)
    echo  Installing Cart
    echo  Completed Cart
   ;;
 mongo)
   echo '[mongodb-org-4.2]
   name=MongoDB Repository
   baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
   gpgcheck=1
   enabled=1
   gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' >/etc/yum.repos.d/mongodb.repo
   Print "Installing MongoDB"
   yum install -y mongodb-org
   statusCheck
   Print "Update MongoDB Configuration"
   sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
   statusCheck
   Print "Starting MongoDB Service"
   systemctl enable mongod
   systemctl start mongod
   statusCheck
   Print "Download Schema"
   curl -s -L -o /tmp/mongodb.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/e9218aed-a297-4945-9ddc-94156bd81427/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
   statusCheck
   cd /tmp
   Print "Extracting Archive"
   unzip -o /tmp/mongodb.zip
   statusCheck
   Print "Load Catalogue Schema"
   mongo < catalogue.js
   Print "Load User Schema"
   mongo < users.js
   systemctl restart mongod
   ;;
  *)
    echo "invalid Input, Following are the only accepted "
    echo "Usage $0 frontend | Catalogue | cart "
    exit 2
 ;;
esac
