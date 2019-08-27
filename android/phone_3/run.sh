#!/usr/bin/env bash
docker build -t demo:1 .
docker run -v /root/app:/app -v /root/demo:/root -v /root/output:/app/app/build/ demo:1