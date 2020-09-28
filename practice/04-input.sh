#!/bin/bash

# 1. While executing
# it will not proceed until you provide the input in automation it stop with error.
read -p "Enter your Name: " name

echo "Hello $name , Welcome to DevOps Training"

# Before Executing
# Some Variables can help you in taking the input which provided as arguments before executing
# Variables for this are $0-$n, $*, $@ ,$#

echo script Name  = $0
echo First Argument  = $1
echo second Argument  = $2
echo All Argument  = $*
echo All Argument =  $@
echo Number of Argument = $#
