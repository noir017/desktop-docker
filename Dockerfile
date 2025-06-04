# 基于Debian Bookworm
FROM docker.nohara.eu.org/debian:bookworm-slim

# 设置环境变量（所有密码集中管理）
ENV USER_PASSWORD="qweasd" \
    VNC_PASSWORD="qweasd" \
    USER_NAME="user" \
    DISPLAY=":1" \
    VNC_PORT=5901 \
    RDP_PORT=3389 \
    GEOMETRY=1600*900

# 安装基础工具和桌面环境
RUN apt-get update && apt-get install -y \
    # 基础工具
    ca-certificates \
    curl \
    iputils-ping \
    net-tools \
    openssh-server \
    sudo \
    wget \
    nano 
    # LXQt桌面
RUN apt-get update && apt-get install -y \
    chromium \
    lxqt-core \
    lxqt-session \
    qterminal \
    featherpad \
    pcmanfm-qt \
    # 图形支持
    mesa-utils \
    libgl1-mesa-dri \
    # VNC/RDP服务
    tigervnc-standalone-server \
    tightvncserver \
    xterm \
    dbus-x11 \
    x11-xserver-utils \
    locales \
    fonts-noto-cjk \
    fonts-wqy-microhei \
    # 输入法框架
    fcitx5 fcitx5-chinese-addons 


#edge
#RUN curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --dearmor > microsoft.gpg \
#    && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
#    && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge  stable main" > /etc/apt/sources.list.d/microsoft-edge.list' \
#    && apt-get update && apt-get install -y microsoft-edge-stable


# 配置中文环境
RUN sed -i 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen zh_CN.UTF-8 \
    && update-locale LANG=zh_CN.UTF-8

#RUN dbus-uuidgen > /var/lib/dbus/machine-id
#ENV DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 创建用户并配置权限
RUN useradd -m -G sudo,video,audio -s /bin/bash $USER_NAME \
    && echo "$USER_NAME:$USER_PASSWORD" | chpasswd \
    && echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# 配置SSH
RUN mkdir /var/run/sshd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 预配置用户模板文件
USER $USER_NAME
WORKDIR /home/$USER_NAME
RUN mkdir -p .vnc \
    && echo $VNC_PASSWORD | vncpasswd -f > .vnc/passwd \
    && chmod 600 .vnc/passwd \
    && echo '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startlxqt' > .vnc/xstartup \
    && chmod +x .vnc/xstartup \
    #输入法环境变量
    && echo "export GTK_IM_MODULE=fcitx" >> .bashrc \
    && echo "export QT_IM_MODULE=fcitx" >> .bashrc \
    && echo "export XMODIFIERS=@im=fcitx" >> .bashrc


# 创建自动启动目录
RUN mkdir -p .config/autostart
COPY entrypoint.sh ./entrypoint.sh
COPY fcitx5.desktop ./.config/autostart/fcitx5.desktop


# 备份配置文件到/etc/skel_backup
USER root
RUN chown -R $USER_NAME:$USER_NAME /home/$USER_NAME
RUN mkdir -p /etc/skel_backup \
    && cp -r /home/$USER_NAME /etc/skel_backup \
    && chown -R $USER_NAME:$USER_NAME /etc/skel_backup


# 暴露端口
EXPOSE $VNC_PORT $RDP_PORT 22

# 启动脚本
USER $USER_NAME
WORKDIR /home/$USER_NAME
#RUN chmod +x entrypoint.sh
ENTRYPOINT ["sh","entrypoint.sh"]
