
# Desktop Docker with LXQt

这是一个基于 Docker 的轻量级桌面环境镜像，使用 **LXQt** 桌面环境，并预装了 **Fcitx5 输入法** 和 **Chromium 浏览器**。支持通过 VNC 或 RDP 远程访问。

---

##  构建命令

```bash
docker build -t desktop-docker .
```

---

##  桌面环境信息

- **桌面环境**: LXQt
- **输入法**: Fcitx5（中文输入法支持）
- **浏览器**: Chromium

---

##  可选环境变量与默认值

| 环境变量名      | 默认值        | 说明                          |
|----------------|---------------|-------------------------------|
| `USER_PASSWORD` | `qweasd`      | 用户账户密码                  |
| `VNC_PASSWORD`  | `qweasd`      | VNC 访问密码                  |
| `DISPLAY`       | `:1`          | 显示编号（用于 X11）          |
| `VNC_PORT`      | `5901`        | VNC 服务端口                  |
| `RDP_PORT`      | `3389`        | RDP 服务端口                  |
| `GEOMETRY`      | `1600*900`    | 分辨率设置（格式：宽*高）     |

---

##  使用示例

运行容器时可以通过 `-e` 设置自定义环境变量：

```bash
docker run -d \
  -e USER_PASSWORD=myuserpass \
  -e VNC_PASSWORD=myvncpass \
  -e GEOMETRY=1920*1080 \
  -p 5901:5901 \
  -p 3389:3389 \
  desktop-docker
```

---

##  注意事项

- 若需更改分辨率，请确保 `GEOMETRY` 值格式为 `宽度*高度`，如 `1920*1080`。
- VNC 和 RDP 端口可根据需要映射到不同的主机端口。

