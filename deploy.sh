#!/bin/bash
set -eux

export HME=$(pwd)
cd $HME

git pull --rebase
yarn install
yarn cache clean -f

hexo cl
hexo g
cp ~/debian ./public/repos/ -rv
git clone https://github.com/NekoSekaiMoe/hen_webpage public/hen --depth=1
git clone https://github.com/NekoSekaiMoe/henkaku_webpage public/henkaku --depth=1
mkdir -p -v public/gh-down
wget -O public/gh-down/jszip.js  https://github.com/Momo707577045/github-directory-downloader/raw/master/jszip.js 
wget -O public/gh-down/index.html https://github.com/Momo707577045/github-directory-downloader/raw/master/index.html 
git clone https://github.com/cbepx-me/cbepx-me.github.io public/hen/ps4 --depth=1
git clone https://github.com/jslinux/jslinux public/jslinux --depth=1
git clone https://github.com/shelljs/shelljs public/shelljs --depth=1
cp public/henkaku/exploit.html public/
cp public/henkaku/payload.js public/
#git clone https://github.com/ubc26/ubc26.github.io public/ubc26 --depth=1
#rm -rf -v public/ubc26/.git*
rm -rf -v piblic/jslinux/.git*
rm -rf -v public/shelljs/.git*
rm -rf -v public/shelljs/test*
rm -rf -v public/hen/ps4/.git*
rm -rf -v public/hen/.git*
rm -rf -v public/henkaku/.git*

hexo d
hexo cl

rm -rf *.bak
bash upload.sh
