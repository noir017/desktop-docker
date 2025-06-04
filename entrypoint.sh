#!/bin/bash

# 初始化用户主目录
if [ ! -f "/home/$USER_NAME/.bashrc" ]; then
    echo "初始化用户主目录..."
    cp -r /etc/skel_backup/user/. /home/$USER_NAME/
    sudo chown -R $USER_NAME:$USER_NAME /home/$USER_NAME
fi

# 设置用户密码
echo "$USER_NAME:$USER_PASSWORD" | chpasswd

# 设置VNC密码
echo "$VNC_PASSWORD" | vncpasswd -f > /home/$USER_NAME/.vnc/passwd
chown $USER_NAME:$USER_NAME /home/$USER_NAME/.vnc/passwd
chmod 600 /home/$USER_NAME/.vnc/passwd

# 启动服务
sudo service ssh start
#service xrdp start
#vncserver :1 -geometry 1920x1080 -depth 24  -interface 0.0.0.0  -localhost no
#sudo -u $USER_NAME vncserver $DISPLAY -geometry 1920x1080 -depth 24

echo "start vnc"
# 清理旧会话
vncserver -kill :1
# 删除锁文件
rm -f /tmp/.X11-unix/X1 /tmp/.X1-lock
export $(dbus-launch)
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XAUTHORITY=~/.Xauthority

vncserver $DISPLAY -geometry $GEOMETRY -depth 24  -interface 0.0.0.0  -localhost no -extension GLX

# 保持容器运行
tail -f /dev/null
