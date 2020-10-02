#!/bin/bash

case $1 in
  create|apply)
    terraform init
    terraform apply -auto-approve
    ;;
  destroy|delete)
    terraform init
    terraform destroy -auto-approve
    ;;
  *)
    echo "Usage $0 : create | delete"
    exit 1
    ;;
esac