FROM elasticsearch:8.19.5

# 复制本地 IK 插件文件
COPY elasticsearch-analysis-ik-8.19.5.zip /tmp/elasticsearch-analysis-ik-8.19.5.zip

# 安装 IK 中文分词插件（使用本地文件）
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch file:///tmp/elasticsearch-analysis-ik-8.19.5.zip

# 复制破解文件
COPY x-pack-core-8.19.5.crack.jar /usr/share/elasticsearch/modules/x-pack-core/x-pack-core-8.19.5.jar

