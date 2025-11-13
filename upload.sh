#!/bin/bash
set +eu
git add .
git commit -m "Site source uploaded: $(LANG=en_US.UTF-8 date)"
git pull --rebase
git push -u origin +main
