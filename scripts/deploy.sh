#!/bin/sh

set -e

# build Site
HUGO_ENV="production" hugo

# publish Site
cd public
git add .
git commit -m "rebuilding site $(date)"
git push origin master