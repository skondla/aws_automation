aws s3api list-objects-v2 --bucket cp-prod-eu-bookmarks-parallel --query '[length(Contents[?LastModified].{Key: Key})]' --output text

