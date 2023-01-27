build() {
  image=$1
  path=$2
  docker build -t registry.cn-zhangjiakou.aliyuncs.com/tulan/${image} ./${path}
  docker push registry.cn-zhangjiakou.aliyuncs.com/tulan/${image}
}

build "$1" "$2"
