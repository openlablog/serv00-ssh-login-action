![](https://socialify.git.ci/openlablog/serv00-ssh-login-action/image?description=1&forks=1&issues=1&language=1&name=1&owner=1&pattern=Solid&pulls=1&stargazers=1&theme=Light&t=123456)

## 注意：请使用私有仓库部署！请使用私有仓库部署！请使用私有仓库部署！

## 功能

1. 两种方式：python脚本和shell脚本
2. 支持批量多账号登录
3. 支持ssh密钥登录
4. 集成smtp邮件通知

## 修改accounts.json

```json
[
    {
        "hostname": "s1.serv00.com",
        "port": "22",
        "username": "test1",
        "password": "",
        "pkey": "id_rsa.pem"
    },
    {
        "hostname": "s2.serv00.com",
        "port": "22",
        "username": "test2",
        "password": "test2",
        "pkey": ""
    }
]
```

* hostname：ssh主机地址
* port：ssh主机端口
* username：ssh用户名
* password：ssh密码 或 rsa密钥密码
* pkey：rsa密钥文件名称，一般放在仓库根目录下（shell脚本权限要求是600，chmod 600 *.pem)

## 修改以下SMTP信息

1、python脚本run.py

```python
...
# ========= 发送邮件 =========
mail_host = "smtp.qq.com"  # SMTP服务器
mail_port = 465  # SMTP端口
mail_user = "test@qq.com"  # SMTP用户名
mail_pass = "123456"  # SMTP密码
sender = 'test@qq.com' # 发件人邮箱
receivers = 'abc@126.com'  # 收件人邮箱
...
```

2、shell脚本run.sh

```bash
...
# ========= 发送邮件 =========
sendemail \
    -s smtp.qq.com \  # SMTP服务器
    -xu test@qq.com \  # SMTP用户名
    -xp 123456 \  # SMTP密码
    -f test@qq.com \ # 发件人邮箱
    -t "abc@126.com" \  # 收件人邮箱
...
```

## 运行结果

```bash
=========
正在批量登录SSH中...

test1@s1.serv00.com 登录成功 2026-01-28 02:15:08
test2@s2.serv00.com 登录失败 Authentication failed.

本次成功登录SSH共： 1 个
=========
邮件发送成功
```

## 再次提醒：请使用私有仓库部署！请使用私有仓库部署！请使用私有仓库部署！

## 定时执行cron任务

上传到github私有仓库后，点击action，选择脚本，点击run workflow运行一次，才能触发定时执行

corn修改 .github/workflows/serv00-ssh-login-action.py.yml 或 .github/workflows/serv00-ssh-login-action.sh.yml

```yml
name: serv00-ssh-login-action.py

on:
  schedule:
    - cron: '0 0 * * *' # 每天一次
    # - cron: '0 0 * * 0' #每周日一次
  workflow_dispatch: # 支持手动执行

jobs:
  serv00-ssh-login-action:
...
```
