import os
import paramiko
import requests
import json
import smtplib
from email.mime.text import MIMEText
from datetime import datetime, timezone, timedelta

# ========= SSH 登录 =========
def ssh_multiple_connections(hosts_info, command):
    info = ""
    num = 0
    for host_info in hosts_info:
        hostname = host_info['hostname']
        port = host_info['port']
        username = host_info['username']
        password = host_info['password']
        pkey = host_info['pkey']
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

            if pkey != "":
                private_key = paramiko.RSAKey.from_private_key_file(os.path.dirname(os.path.abspath(__file__)) + "/" + pkey)
                if password != "":
                    ssh.connect(hostname=hostname, port=port, username=username, password=password, pkey=private_key)
                else:
                    ssh.connect(hostname=hostname, port=port, username=username, pkey=private_key)
            else:
                ssh.connect(hostname=hostname, port=port, username=username, password=password)
                
            ssh.exec_command(command)
            info += f"{username}@{hostname} 登录成功 {get_bj_time()}\n"
            num += 1
            ssh.close()
        except Exception as e:
            info += f"{username}@{hostname} 登录失败 {str(e)}\n"
    return num, info

# ========= 时间 =========
def get_bj_time():
    beijing_timezone = timezone(timedelta(hours=8))
    time = datetime.now(beijing_timezone).strftime('%Y-%m-%d %H:%M:%S')
    return time

# ========= 遍历账号 =========
print('=========')
print('正在批量SSH登录中...\n')
file = open(os.path.dirname(os.path.abspath(__file__)) + "/accounts.json", "r")
hosts_info = json.loads(file.read())
file.close()

command = 'whoami; sleep 10; exit;'
user_num, user_info = ssh_multiple_connections(hosts_info, command)
user_info += f"\n本次成功SSH登录共： {user_num} 个"
print(user_info)
print('=========')

# ========= 发送邮件 =========
mail_host = "smtp.qq.com"  # SMTP服务器
mail_port = 465  # SMTP端口
mail_user = "test@qq.com"  # SMTP用户名
mail_pass = "123456"  # SMTP密码
sender = 'test@qq.com' # 发件人邮箱
receivers = 'abc@126.com'  # 收件人邮箱

message = MIMEText(f"{user_info}", 'plain', 'utf-8') # 邮件的内容
message['From'] = sender
message['To'] = receivers
message['Subject'] = "SSH登录通知 - " + get_bj_time() # 邮件的主题

try:
    smtpObj = smtplib.SMTP_SSL(mail_host, mail_port)
    smtpObj.login(mail_user, mail_pass)
    smtpObj.sendmail(sender, receivers, message.as_string())
    smtpObj.quit()
    print("邮件发送成功")
except smtplib.SMTPException as e:
    print(f"邮件发送失败：{e}")
