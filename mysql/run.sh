#!/usr/bin/env bash

createUser() {
    echo "请输入要创建的账号"
    read user
    echo "请输入要创建的密码"
    read passwd

    mysql -u$username -p$password -e "
    tee /tmp/temp.log
    create user $user;
    create database $user character set utf8mb4;
    grant all privileges on $user.* to $user@'%' identified by '$passwd';
    quit"

    echo "数据库创建成功，账号:$user 密码:$passwd"
}
echo "请输入数据库账号"
read username
echo "请输入数据库密码"
read password

createUser


