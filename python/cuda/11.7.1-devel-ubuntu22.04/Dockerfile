#FROM registry.cn-zhangjiakou.aliyuncs.com/guanweiming/www:cuda-base
FROM nvidia/cuda:11.7.1-devel-ubuntu22.04
RUN apt update && apt install -y python3 python3-pip git libgl1 libglib2.0-0
RUN cp /usr/bin/python3 /usr/bin/python
#RUN pip3 install torch==2.5.0 torchvision==0.20.0 torchaudio==2.5.0 -i https://mirrors.aliyun.com/pypi/simple/
#RUN pip3 install mmcv-full -f https://download.openmmlab.com/mmcv/dist/cu124/torch2.5.0/index.html
RUN pip install torch==1.13.1 torchvision==0.14.1 torchaudio==0.13.1
# -i https://mirrors.aliyun.com/pypi/simple/
ADD requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
#-i https://mirrors.aliyun.com/pypi/simple/
WORKDIR /workdir
RUN git clone https://ghfast.top/https://github.com/lbin/DCNv2.git  \
    && cd DCNv2  \
    && git checkout pytorch_1.11 \
    && python3 setup.py build develop \
    && /bin/bash make.sh
RUN pip3 install mmengine==0.7.3
#-i https://mirrors.aliyun.com/pypi/simple/
RUN apt install -y vim
#RUN pip3 install mmcv-full -f https://download.openmmlab.com/mmcv/dist/cu117/torch1.13.1/index.html
RUN pip3 install -U openmim
#-i https://mirrors.aliyun.com/pypi/simple/
RUN mim install mmcv-full
#RUN mim install mmcv-full==1.5.0
WORKDIR /workdir/app
RUN mkdir -p /root/.cache/torch/hub/checkpoints/
RUN wget https://files.tulan.wang/dla34-ba72cf86.pth /root/.cache/torch/hub/checkpoints/dla34-ba72cf86.pth
# 修改欢迎命令
COPY .bashrc /root/.bashrc
