#!/bin/bash
set -e
USER_ID=$(id -u)
DNS_DOMAIN_NAME="devops360.tk"

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
setupNodeJs(){
  Print "Installing NodeJs"
  yum install -y nodejs make gcc-c++
  statusCheck
  id roboshop
  case $? in
  1)
    Print "Add Application User"
    useradd roboshop
    statusCheck
  ;;
  esac
  Print "Downloadng Application"
  curl -s -: -o /tmp/$1.zip "$2"
  statusCheck
  Print "Extracting Application Archive"
  mkdir -p /home/roboshop/$1
  cd /home/roboshop/$1
  unzip -o /tmp/$1.zip
  statusCheck
  Print "Install NodeJs App Dependencies"
  npm --unsafe-perm install
  statusCheck
  chown roboshop:roboshop /home/roboshop -R
  Print "Setup $1 Service"
  mv /home/roboshop/$1/systemd.service /etc/systemd/system/$1.service
  sed -i -e "s/MONGO_ENDPOINT/mongodb.${DNS_DOMAIN_NAME}/"  /etc/systemd/system/$1.service
  sed -i -e "s/RESDIS_ENDPOINT/redis.${DNS_DOMAIN_NAME}/"  /etc/systemd/system/$1.service
  sed -i -e "s/CATALOGUE_ENDPOINT/catalogue.${DNS_DOMAIN_NAME}/"  /etc/systemd/system/$1.service
  statusCheck
  print "Start $1 Service"
  systemctl daemon-reload
  systemctl start $1
  systemctl enable $1
  statusCheck
}
# Main Program
case $1 in
  frontend)
    Print "Installing Nginx"
    yum install nginx -y
    statusCheck
    Print "Downloading Frontend App"
    curl -s -L -o /tmp/frontend.zip "https://github.com/AbdullahGhani1/rs-frontend/archive/master.zip"
    statusCheck
     cd /usr/share/nginx/html
     rm -rf *
     Print "Extracting Frontend Archive"
     unzip /tmp/frontend.zip
     statusCheck
     mv rs-frontend-master/*  .
     rm -rf rs-frontend-master
     mv static/* .
     rm -rf static README.md
     mv localhost.conf /etc/nginx/nginx.conf
     sed -i -e '/^#/ d' /etc/nginx/nginx.conf

     for app in catalogue cart user shipping payment; do
      sed -i "/localhost/ a \ \n\tlocation /api/$app { \n\t \tproxy_pass  http://$app.$DNS_DOMAIN_NAME:8000 ; \n\t}" /etc/nginx/nginx.conf
     done

     Print "Starting Nginx"
     systemctl enable nginx
     systemctl restart nginx
     Status_Check
    ;;
  catalogue)
   Print  "Installing Catalogue"
   setupNodeJs "catalogue" "https://github.com/AbdullahGhani1/rs-catalogue/archive/master.zip"
   ;;
  cart)
    Print  "Installing Cart"
    setupNodeJs "cart" "https://github.com/AbdullahGhani1/rs-cart/archive/master.zip"
   ;;
 user)
   Print  "Installing User"
   setupNodeJs "user" "https://github.com/AbdullahGhani1/rs-user/archive/master.zip"
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
   curl -s -L -o /tmp/mongodb.zip "https://github.com/AbdullahGhani1/rs-mongo"
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
