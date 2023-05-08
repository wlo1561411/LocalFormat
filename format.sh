#!/bin/sh

# 使用git status進行查找
git status --porcelain | while read -r line; do
  # 檢查當前行是否包含.swift文件
  if echo "$line" | grep -q "\.swift"; then
    # 獲取文件名
    filename=$(echo "$line" | awk '{print $2}')
    # 檢查文件是否有變更
    if echo "$line" | grep -q -E "^(M|MM|A|AM|R|RM|D|MD)[[:space:]]"; then
      echo "Format Swift file: $filename"
      /usr/local/Cellar/swiftformat/0.51.9/bin/swiftformat "$filename"
    fi
  fi
done
