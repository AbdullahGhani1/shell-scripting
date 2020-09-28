#!/bin/bash
set -e
USER_ID=(id -u)

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
case $1 in
  frontend)
    echo -e "\e[1;33m**********>>>>>>>>>>>> Installing Nginx <<<<<<<<<<***********\e[0m"
    echo    Installing Frontend
    echo -e "\e[1;33m**********>>>>>>>>>>>> Starting Nginx <<<<<<<<<<***********\e[0m"
    yum install nginx -y
    ;;
  catalogue)
   echo  Installing Catalogue
   echo Completed Installing Catalogue
   ;;
  cart)
    echo  Installing Cart
    echo  Completed Cart
   ;;
  *)
    echo "invalid Input, Following are the only accepted "
    echo "Usage $0 frontend | Catalogue | cart "
    exit 2
 ;;
esac
