###################################################################################################################
1.用户信息
配置的是我的用户名和email。每次 Git 提交时都会引用这两条信息，说明是谁提交了更新，会随更新内容一起被永久纳入历史记录
###################################################################################################################
git config --global user.name "fipped"
git config --global user.email "823188494@qq.com"

###################################################################################################################
2.查看配置信息
###################################################################################################################
要检查已有的配置信息可以使用 git config --list 命令，单独查看某项配置信息可以用 git config user.name

###################################################################################################################
3.检查本机是否有ssh key设置,进入git bash
###################################################################################################################
$ cd ~/.ssh 或cd .ssh

如果没有则提示： No such file or directory
如果有则进入~/.ssh路径下（ls查看当前路径文件，rm * 删除所有文件）

ssh-keygen -t rsa -C "xxxxxx@yy.com" #建议填写自己真实有效的邮箱地址
Generating public/private rsa key pair.

Enter file in which to save the key (/c/Users/xxxx_000/.ssh/id_rsa):   #不填直接回车
Enter passphrase (empty for no passphrase):   #输入密码（可以为空）
Enter same passphrase again:   #再次确认密码（可以为空）

Your identification has been saved in /c/Users/xxxx_000/.ssh/id_rsa.   #生成的密钥
Your public key has been saved in /c/Users/xxxx_000/.ssh/id_rsa.pub.  #生成的公钥
The key fingerprint is:
e3:51:33:xx:xx:xx:xx:xxx:61:28:83:e2:81 xxxxxx@yy.com

###################################################################################################################
4.添加ssh key到GItHub
###################################################################################################################
登录GitHub系统；点击右上角账号头像的“▼”→Settings→SSH kyes→Add SSH key。
复制id_rsa.pub的公钥内容。

1) 进入c:/Users/xxxx_000/.ssh/目录下，打开id_rsa.pub文件，全选复制公钥内容。
2) Title自定义，将公钥粘贴到GitHub中Add an SSH key的key输入框，最后“Add Key”。

