#!/bin/bash

set -o errexit -o pipefail -o noclobber -o nounset


SHORT_OPTION_NAME="rp"
LONG_OPTION_NAME="repo_name,path"

set +o errexit

USAGE="$(basename "$0") [(-r|--repo_name) repo_name] [(-p|--path) path] -- set up bjacotg local_repo

where:
   -r|--repo_name  repository name for the local_repo (default: local_repo)
   -p|--path       path to install the repository
"

OPTIONS=$(getopt -o $SHORT_OPTION_NAME --long $LONG_OPTION_NAME -- "$@")

[ $? -eq 0 ] || {
  echo "Incorrect options provided"
  echo "$USAGE"
  exit 1
}

set -o errexit

set +o nounset

eval set -- "$OPTIONS"
while true; do
  [ -z $1 ] || { break; }
  case "$1" in
    -r)
      ;&
    --repo_name)
      shift;
      REPO_NAME=$1
      ;;
    -p)
      ;&
    --path)
      shift; 
      REPO_PATH=$1
      ;;
  esac
  shift
done

shift 

[ -z $REPO_NAME ] && {
  REPO_NAME="local_repo"
}

[ -z $REPO_PATH ] && {
  REPO_PATH="$HOME/.local_repo/"
}

set -o nounset


PACKAGES=("https://github.com/bjacotg/st.git")

echo "Ready to handles $PACKAGES"


[ -d "$REPO_PATH" ] && {
  echo "We are not smart enough to handle updated. Deleting and starting from scratch."
  rm -rf "$REPO_PATH"
}

mkdir "$REPO_PATH"

cd "$REPO_PATH"

# Cloning everyhting
for PACKAGE in $PACKAGES
do
  git clone $PACKAGE
done

for dir in */
do 
  cd $dir
  makepkg
  cd ..
done

for dir in */
do
  repo-add "$REPO_NAME.db.tar.xz" $dir*.pkg.tar.xz
done

echo "Add to /etc/pacman.conf

[$REPO_NAME]
Server = file://$(realpath $REPO_PATH)
SigLevel = Never
"








