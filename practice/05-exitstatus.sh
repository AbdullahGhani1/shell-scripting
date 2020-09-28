#!/bin/bash

# in shell scripting we dont bother mych on command outputs, But we look for exit status of the commands which is  executed
# to determine wheather that is successfull or failure.
# Exit status is number, it ranges from 0-255

# 0 - Successful
# 1-255 - Non Successfull / semi Successful / semi failure

#3 EXIT 0-255

# But system uses the numbers from 126+

# so for them user use 1-125 values for exit status