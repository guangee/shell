#!/bin/bash

LICENSE_FILE="/GitLabBV.gitlab-license"

# 1. 检查物理文件是否存在，不存在说明已经安装过并删除了
if [ ! -f "$LICENSE_FILE" ]; then
    echo "License file not found, assuming already installed. Exiting."
    exit 0
fi
echo "Importing license..."
# 2. 执行导入（合并 stderr，便于看到完整报错）
IMPORT_LOG="$(
  gitlab-rails runner "
if License.count == 0
  begin
    License.create!(data: File.read('$LICENSE_FILE'))
    puts 'SUCCESS'
  rescue => e
    puts \"ERROR: #{e.message}\"
  end
else
  puts 'EXISTS'
end
" 2>&1
)" || true
# gitlab-rails runner "License.create(data: File.read('/GitLabBV.gitlab-license'))"
echo "----- gitlab-rails runner 输出 -----"
echo "$IMPORT_LOG"
echo "--------------------------------------"

# 3. 若输出含 SUCCESS 则删除物理文件，防止重启后脚本再次触发
if echo "$IMPORT_LOG" | grep -q "SUCCESS"; then
    echo "License secured. Removing temporary license file."
    rm "$LICENSE_FILE"
    echo "License imported successfully."
else
    echo "License import failed (no SUCCESS). Check runner output for ERROR / EXISTS. License file kept." >&2
fi