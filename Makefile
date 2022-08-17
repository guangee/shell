jre11:
	docker build -t registry.cn-zhangjiakou.aliyuncs.com/guanweiming/openjdk:11.0.16-jre java/openjdk/11
	docker push registry.cn-zhangjiakou.aliyuncs.com/guanweiming/openjdk:11.0.16-jre
