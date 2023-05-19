#!/bin/bash
set +e
cd ~/test ||.exit 1
hexo cl || exit 1
hexo g || exit 1
cp ~/debian ~/test/public/repos -rv || exit 1
hexo d || exit 1
hexo cl || exit 1
