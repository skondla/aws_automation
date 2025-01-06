#!/bin/bash
#Author:skondla@me.com
#Purpose: Find set of strings from multiple type files from all sub-directories

#find . -name "*.md" -o -name "*.py" -o -name "*.sh" -o -name "*.sh" \
# |xargs egrep -i "(yahoo.com|me.com|gmail.com)"

find -E . -regex '.*\.(py|sh|sql|md)' |xargs egrep -i "(yahoo.com|me.com|gmail.com|outlook.com)"
