#!/usr/bin/env bash

set -e

dest_dir="$1"


#--------------------------------------------------------------
# functions
#--------------------------------------------------------------
error() {
  >&2 echo "ERROR: $@"
  exit 1
}

usage() {
  echo "usage: ./$(basename $0) dest_dir"
}


#--------------------------------------------------------------
# execution
#--------------------------------------------------------------
if ! [ -d "$dest_dir" ]; then
  usage
  error "dest_dir=$dest_dir does not exist"
fi

rsync -avzph $(dirname $0)/ $dest_dir \
  --exclude "generated_tb"            \
  --exclude ".git*"                   \
  --exclude "fifo_*.tpl"              \
  --exclude "pinlist"
