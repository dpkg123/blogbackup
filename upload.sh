#!/bin/bash
set +e
git pull --rebase
git add .
git commit -m "Site source uploaded: $(LANG=en_US.UTF-8 date)"
git push -u origin +main
