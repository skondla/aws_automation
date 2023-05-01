#find . -name "*.md" -o -name "*.py" -o -name "*.sh" -o -name "*.sh" \
# |xargs egrep -i "(yahoo.com|me.com|gmail.com)"

find -E . -regex '.*\.(py|sh|sql|md)' |xargs egrep -i "(yahoo.com|me.com|gmail.com)"
