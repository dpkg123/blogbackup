#!/bin/bash
set -eux

export HME=$(pwd)
cd $HME

test -f yarn.lock && mv yarn.lock yarn.lock.bak
wget https://github.com/dpkg123/blogbackup/raw/main/yarn.lock
test -f package.json && mv package.json pwckage.json.bak
wget https://github.com/dpkg123/blogbackup/raw/main/package.json
yarn install
yarn cache clean -f

hexo cl
hexo g
cp ~/debian ~/test/public/repos -rv
git clone https://github.com/NekoSekaiMoe/hen_webpage public/hen --depth=1
git clone https://github.com/NekoSekaiMoe/henkaku_webpage public/henkaku --depth=1
mkdir -p -v public/gh-down
wget -O public/gh-down/jszip.js  https://github.com/Momo707577045/github-directory-downloader/raw/master/jszip.js 
wget -O public/gh-down/index.html https://github.com/Momo707577045/github-directory-downloader/raw/master/index.html 
git clone https://github.com/cbepx-me/cbepx-me.github.io public/hen/ps4 --depth=1
#git clone https://github.com/ubc26/ubc26.github.io public/ubc26 --depth=1
#rm -rf -v public/ubc26/.git*
rm -rf -v public/hen/ps4/.git*
rm -rf -v public/hen/.git*
rm -rf -v public/henkaku/.git*
hexo d
hexo cl

rm -rf *.bak
