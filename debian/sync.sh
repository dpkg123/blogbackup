#!/bin/bash

set -x
# 使用 GitHub API 获取最新发行版的信息
RELEASE=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/repos/"$OWNER"/"$REPO"/releases/latest)

# 使用 jq 解析 JSON，获取 ARM64 的 deb 文件下载链接
if [ ARCH = arm64 ]; then
    ASSET=$(echo $RELEASE | jq -r '.assets[] | select(.name | endswith("arm64.deb"))')
elif [ ARCH = amd64 ]; then
    ASSET=$(echo $RELEASE | jq -r '.assets[] | select(.name | endswith("amd64.deb"))')
fi

if [ "$ASSET" == "" ]; then
    echo "No $ARCH.deb asset found in the latest release."
    exit 1
fi

DOWNLOAD_URL=$(echo "$ASSET" | jq -r '.browser_download_url')
FILENAME=$(echo "$ASSET" | jq -r '.name')

# 下载文件
aria2c "$DOWNLOAD_URL" -o "$FILENAME"

echo "Downloaded: $FILENAME"
