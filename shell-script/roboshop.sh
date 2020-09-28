#!/bin/bash

case $1 in
  frontend)
    echo Installing Frontend
    echo Completed Installing Frontend
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
 ;;
esac
