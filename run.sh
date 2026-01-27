#!/bin/bash

# ========= SSH 登录 =========
try_login() {
    local hostname="$1"
    local port="$2"
    local username="$3"
    local password="$4"
    local pkey="$5"

    if [ $pkey != "" ]; then
        sshpass -p "$password" ssh \
            -p "$port" \
            -i "$(cd "$(dirname "$0")" && pwd)/$pkey" "$username@$hostname" \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o ConnectTimeout=20 \
            -o ServerAliveInterval=10 \
            -o ServerAliveCountMax=2 \
            -tt "whoami; sleep 10; exit;" >/dev/null 2>&1
    else
        sshpass -p "$password" ssh \
            -p "$port" "$username@$hostname" \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o ConnectTimeout=20 \
            -o ServerAliveInterval=10 \
            -o ServerAliveCountMax=2 \
            -tt "whoami; sleep 10; exit;" >/dev/null 2>&1
    fi
}

# ========= 时间 =========
get_bj_time() {
    TZ=Asia/Shanghai date "+%Y-%m-%d %H:%M:%S"
}

# ========= 遍历账号 =========
echo "========="
echo "正在批量SSH登录中..."
accounts=$(jq -c '.[]' "$(cd "$(dirname "$0")" && pwd)/accounts.json")
info=""
num=0;
for account in $accounts; do
    hostname=$(echo "$account" | jq -r '.hostname')
    port=$(echo "$account" | jq -r '.port')
    username=$(echo "$account" | jq -r '.username')
    password=$(echo "$account" | jq -r '.password')
    pkey=$(echo "$account" | jq -r '.pkey')

    if try_login "$hostname" "$port" "$username" "$password" "$pkey"; then
        info="$info$username@$hostname 登录成功 $(get_bj_time)\n"
        num=$((num + 1))
    else
        # 重试一次
        sleep 5
        if try_login "$hostname" "$port" "$username" "$password" "$pkey"; then
            info="$info$username@$hostname 登录成功 $(get_bj_time)\n"
            num=$((num + 1))
        else
            info="$info$username@$hostname 登录失败\n"
        fi
    fi
done
info="$info\n本次成功SSH登录共： $num 个"
echo $info
echo "========="

# ========= 发送邮件 =========
sendemail \
    -s smtp.qq.com \
    -xu test@qq.com \
    -xp 123456 \
    -f test@qq.com \
    -t "abc@126.com" \
    -o message-content-type=text \
    -o message-charset=utf8 \
    -o tls=yes \
    -u "SSH登录通知 - $(get_bj_time)" \
    -m "$info"

# -s  smtp.qq.com  smtp服务器
# -xu test@qq.com  SMTP账号
# -xp 123456  SMTP密码
# -f  test@qq.com 发件人邮箱
# -t  abc@126.com  收件人邮箱
# -o message-content-type=text  邮件内容的格式为html，也可以是text
# -o message-charset=utf8  邮件内容编码
# -o tls=yes  启动TLS
# -u  '邮件主题'  邮件的主题
# -m  '邮件内容'  邮件的内容
