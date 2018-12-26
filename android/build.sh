#!/usr/bin/env bash

work_dir="project"
project="git@git.coding-space.cn:coding/android-upload-connect.git"
echo '清理工作空间'
rm -rf ${work_dir}
echo "克隆代码"

git clone ${project} ${work_dir}

cd ${work_dir}
docker run --tty --interactive --volume=$(pwd):/opt/workspace --workdir=/opt/workspace --rm jacekmarchwicki/android:java7  /bin/sh -c "./gradlew build"
cd ..



echo "build结束"
