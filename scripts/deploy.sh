#!/bin/sh

set -e

# Build Site
HUGO_ENV="production" hugo

# Publish Site
cd public
git add .
commit_msg="rebuilding site $(date)"
if [ -n "$*" ]; then
	commit_msg="$*"
fi
git commit -m "$commit_msg"
git push origin master