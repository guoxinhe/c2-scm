#!/bin/sh

#goes to target folder and clone a repo from local, otherwise will from website.
if [ ! -d .repo ]; then
mkdir -p .repo; git clone ssh://git.bj.c2micro.com/c2sdk/repo.git .repo/repo
fi

BR=${1:-master}
mf=${2:-default.xml}

if [ -d .repo/manifests ]; then
repo start $BR --all
else
yes "" | repo init -u ssh://git.bj.c2micro.com/c2sdk/manifests.git -b $BR -m $mf
fi
repo sync
repo start $BR --all
