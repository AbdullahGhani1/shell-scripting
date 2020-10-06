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

Create_AppUser() {
   id -u roboshop ||(
      Print "Add Application User"
      useradd roboshop
      statusCheck)
}
copyFile(){
  mv rs-$1-master/*  .
  rm -rf rs-$1-master
}
setupNodeJs(){
  Print "Installing NodeJs"
  yum install -y nodejs make gcc-c++
  statusCheck
  Create_AppUser
  Print "Downloadng Application"
  curl -s -L -o /tmp/$1.zip "$2"
  statusCheck
  Print "Extracting Application Archive"
  mkdir -p /home/roboshop/$1
  cd /home/roboshop/$1
  unzip -o /tmp/$1.zip
  statusCheck
  copyFile $1
  Print "Install NodeJs App Dependencies"
  npm --unsafe-perm install
  statusCheck
  chown roboshop:roboshop /home/roboshop -R
  Print "Setup $1 Service"
  mv /home/roboshop/$1/systemd.service /etc/systemd/system/$1.service
  sed -i -e "s/MONGO_ENDPOINT/mongodb.${DNS_DOMAIN_NAME}/" /etc/systemd/system/$1.service
  sed -i -e "s/REDIS_ENDPOINT/redis.${DNS_DOMAIN_NAME}/" /etc/systemd/system/$1.service
  sed -i -e "s/CATALOGUE_ENDPOINT/catalogue.${DNS_DOMAIN_NAME}/" /etc/systemd/system/$1.service

  statusCheck
  Print "Start $1 Service"
  systemctl daemon-reload
  systemctl start $1
  systemctl enable $1
  statusCheck
}
Frontend(){
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
     copyFile frontend
     mv static/* .
     rm -rf static README.md
     mv template.conf /etc/nginx/nginx.conf

     export CATALOGUE=catalogue.${DNS_DOMAIN_NAME}
     export CART=cart.${DNS_DOMAIN_NAME}
     export USER=user.${DNS_DOMAIN_NAME}
     export SHIPPING=shipping.${DNS_DOMAIN_NAME}
     export PAYMENT=payment.${DNS_DOMAIN_NAME}

     sed -i -e "s/CATALOGUE/${CATALOGUE}/" -e "s/CART/${CART}/" -e "s/USER/${USER}/" -e "s/SHIPPING/${SHIPPING}/" -e "s/PAYMENT/${PAYMENT}/" /etc/nginx/nginx.conf
     Print "Starting Nginx"
     systemctl enable nginx
     systemctl restart nginx
     statusCheck
}
MongoDb(){
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
   curl -s -L -o /tmp/mongodb.zip "https://github.com/AbdullahGhani1/rs-mongo/archive/master.zip"
   statusCheck
   cd /tmp
   Print "Extracting Archive"
   unzip -o /tmp/mongodb.zip
   copyFile mongo
   statusCheck
   Print "Load Catalogue Schema"
   mongo < catalogue.js
   Print "Load User Schema"
   mongo < users.js
   statusCheck
#   systemctl restart mongod
}
Redis (){
  Print "Install Yum Utils"
  yum install epel-release yum-utils http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
  statusCheck
  Print "Enable Remi repos"
  yum-config-manager --enable remi
  statusCheck
  Print "Install Redis"
  yum install redis -y
  statusCheck
  Print "Update Configuration"
  if [ -e /etc/redis.conf ]; then
    sed -i -e '/^bind 127.0.0.1/ c bind 0.0.0.0' /etc/redis.conf
   fi
  statusCheck
  Print "Start Service"
  systemctl enable redis
  systemctl start redis
  statusCheck
}
Shipping(){
  Print "Install Maven"
  yum install maven -y
  statusCheck
  Create_AppUser
  cd /home/roboshop
  Print "Downloading Application"
  curl -s -L -o /tmp/mongodb.zip "https://github.com/AbdullahGhani1/rs-shipping/archive/master.zip"
  statusCheck
  mkdir shipping
  cd shipping
  Print "Extracting Archive"
  unzip -o /tmp/mongodb.zip
  statusCheck
  copyFile shipping
  Print "Install Dependencies"
  mvn clean package
  statusCheck
  mv target/*dependencies.jar shipping.jar
  chown roboshop:roboshop /home/roboshop -R
  mv /home/roboshop/shipping/systemd.service /etc/systemd/system/shipping.service
  sed -i -e "s/CRATENDPOINT/cart.${DNS_DOMAIN_NAME}/" /etc/systemd/system/shipping.service
  sed -i -e "s/DBHOST/mysql.${DNS_DOMAIN_NAME}/" /etc/systemd/system/shipping.service
  systemctl daemon-reload
  systemctl enable shipping
  Print "Start Service"
  systemctl start shipping
  statusCheck
}
MySQL(){
 Print "Download MYSQL"
 case $? in
  1)
    curl -L -o /tmp/mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar
    cd /tmp
    Print "Extract Archive"
    tar -xf mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar
    statusCheck
    yum remove mariadb-libs -y
    Print "Install MySQL"
    yum install mysql-community-client-5.7.28-1.el7.x86_64.rpm \
                mysql-community-common-5.7.28-1.el7.x86_64.rpm \
                mysql-community-libs-5.7.28-1.el7.x86_64.rpm \
                mysql-community-server-5.7.28-1.el7.x86_64.rpm -y
    statusCheck
      ;;
 esac
  systemctl enable mysqld
  Print "Start MYSQL"
  systemctl start mysqld
  statusCheck
  echo "show database;"| mysql -uroot -ppassword
  case $? in
  1)
    echo -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Password@2';\nuninstall plugin validate_password;\nALTER USER
     'root'@'localhost' IDENTIFIED BY 'password';">/tmp/reset-password.sql
     ROOT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')
     Print "Reset MYSQL Password"
     mysql -uroot -p"${ROOT_PASSWORD}" < /tmp/reset-password.sql
     statusCheck
     ;;
   esac
   Print "Download Schema"
   curl -s -L -o /tmp/mysql.zip "https://github.com/AbdullahGhani1/rs-mysql.git/archive/master.zip"
   statusCheck
   Print "Extract Archive"
   cd /tmp
   unzip mysql.zip
   statusCheck
   copyFile mysql
   Print "Load Schema"
   mysql -u root -ppassword < shipping.sql
   statusCheck
}
# Main Program
case $1 in
  frontend)
   Frontend
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
 mongodb)
  MongoDb
   ;;
   redis)
    Redis
   ;;
shipping)
  Shipping
  ;;
  mysql)
    MySQL
    ;;
  *)
    echo "invalid Input, Following are the only accepted "
    echo "Usage $0 frontend | Catalogue | cart | Redis | Monho | Shipping | Mysql  "
    exit 2
 ;;
esac
