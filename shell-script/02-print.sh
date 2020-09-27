#!/bin/bash
echo Hello
# print  on multiline with \n and spaces with \t
echo -e "Welcome to Devops Training\nTopic\tshell Script"

# Syntax for enabling this is :  echo -e"\e[COLOR-CODEmMESSAGE\e[m"
# echo - prin  message
# -e to enable colors with \e
# \e - enable color
# [132  - some color code
# m - End of color code
# MESSAGE - Message to print
# \e - enable one more color
# [0m - Zero is going to disable the color.

# https://misc.flogisoft.com/bash/tip_colors_and_formatting

## Color Codes
# 1 -  bold
# 4 - underlined
# 31,41 - red
# 32,42 - green
# 33,43 - yellow
# 34,44 - blue
# 35,45 - magenta
# 36,46 - cyan
# 41-46 color for background
echo -e "\e[1mHello world in Bold text\e[0m"
echo -e "\e[4mHello world in Underlined text\e[0m"
echo -e "\e[31mHello world in Red Color\e[0m"
echo -e "yellow color,but only \e[33mYellow\e[0m in yellow color"

# Combinations
echo -e "\e[1;4;31;42mText shows bold,underline and red foreground on green background\e[0m"
