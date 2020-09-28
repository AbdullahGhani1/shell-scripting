#!/bin/bash

# syntax  varName - Data
# ====== Data Types
a=10 #Number
b=xyz #characters
c=true #Boolean
d=0.01  # Float

# Yet you have Different Data types, shell will consider everything as string
# mainly string is a combination of numbers and characters

# How to acess variables
# $variables  or ${variables}
echo $a

# SOME TIMES you need to store multiple values in a single variable
# In shell we call it as array,In some scripting languages this is called as a list.

Array=(1 2 abc 20 0.01)

# Single Array can hold multiple data types, Of Course in shell everything is a String.

# How to access a particular value

echo Index =${Array[0]}

# Since we are accessing arrays with Index, in shell we call this as index Arrays

# Alternate to that your array can be accessed with Name as well, that becomes named Arrays & in other scripting languages we call it as MAP
declare  -A MYMAP=([course]=DevOps [time]=0730 [zone]=IST)

echo "Welcome to ${MYMAP[course]}  Training, Timinmg is ${MYMAP[time]} ${MYMAP[zone]}"

# variables name can contain numbers characters & _ (UnderScore) you can not Special Character in Name like :,;./$%^&*())@
# variable can not start with number