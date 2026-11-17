# Windows USB 接口采集

用于确认战甲 X Pro 在你的 Windows 10/11 上有哪些 USB/HID 接口，便于设计后续诊断通道。此脚本只读取系统设备描述信息，不发送配置、宏或刷写命令，也不能直接测出手柄剩余 RAM。

1. 下载本仓库 ZIP 并解压，或使用已有 Git 克隆目录。
2. 通过 USB 连接设备，先保持正常运行状态。
3. 在项目目录打开 PowerShell，执行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\Collect-ArmorXUsbInfo.ps1
```

生成 `armorx-usb-info.json`。将这个文件发回当前对话，并说明设备是本体直连还是接收器连接。此命令只对这一次 PowerShell 进程使用 Bypass，不修改系统的持久执行策略，不需要管理员权限。

如果可以，拔掉战甲设备后再采一次，便于对照哪些接口属于它：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\Collect-ArmorXUsbInfo.ps1 -OutputPath .\armorx-usb-disconnected.json
```

报告包含当前 USB 设备名称、VID/PID、驱动服务，以及 HID Usage 和报告长度；不包含设备序列号或接口路径。脚本不会安装软件或驱动。

Windows 自动检查仅验证脚本语法、C# 编译、系统 API 调用和输出结构，不能代替连接真实战甲设备后的验证。
