#!/usr/bin/env bash

work_dir="project"
project="https://git.coding-space.cn/guange/demo-android.git"
echo '清理工作空间'
rm -rf ${work_dir}
echo "克隆代码"

git clone ${project} ${work_dir}

cd ${work_dir}
chmod 777 gradlew
docker run --tty --interactive --volume=$(pwd):/opt/workspace --workdir=/opt/workspace --rm jacekmarchwicki/android  /bin/sh -c "./gradlew build"
cd ..



echo "build结束"
