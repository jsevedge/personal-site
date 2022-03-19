#!/bin/sh

set -e

NOTEBOOK_FOLDER="notebooks"
NOTEBOOK_FILE="notebook.ipynb"
NOTEBOOKS=$(ls -d ${NOTEBOOK_FOLDER}/*/)

for NOTEBOOK in "${NOTEBOOKS[@]}"; do
    NOTEBOOK_FILE_LOCATION="${NOTEBOOK_FOLDER}/$(basename ${NOTEBOOK})/${NOTEBOOK_FILE}"
    DEST_LOCATION="static/notebook-$(basename ${NOTEBOOK}).html"
    jupyter nbconvert --execute --to html ${NOTEBOOK_FILE_LOCATION} --stdout > ${DEST_LOCATION}
done