#!/bin/bash

# This script builds the package.opendylan.org website. It builds the
# docs and copies files to ${dest_dir}, meaning that there could be
# cruft left around in ${dest_dir}. Might want to fix that some day.

# Note that 'git pull --rebase origin main' was done in the calling
# script so that updates to this script take effect.

echo ""

if [[ $# -ne 1 ]]; then
    echo "Usage: `basename $0` dest-dir"
    echo
    echo "  DEST-DIR: Directory into which the website content should be copied."
    echo
    echo "  Example: update.sh /var/www/package.opendylan.org"
    exit 2
fi

dest_dir=$(realpath "$1")

if [[ ! -d "$dest_dir" ]]; then
    echo "${dest_dir} doesn't exist; aborting."
    exit 2
fi

set -e   # die on any error
set -x   # debug output

gendoc_dir=$(dirname $(realpath "$0"))

cd ${gendoc_dir}

# Get latest gendoc, DRM, etc, as specified in dylan-package.json.
echo "Updating the Dylan workspace to get latest package dependencies..."
dylan update

echo "Building gendoc ..."
dylan build gendoc

_build/bin/gendoc --excludes-file exclude-list.txt docs/source/index.rst
cd docs
make html

echo "Copying package docs to ${dest_dir} ..."
rsync -av ${gendoc_dir}/docs/_build/html/ ${dest_dir}
