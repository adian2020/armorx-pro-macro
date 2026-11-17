# 固件接入进展：打包、代码空间与通信缓冲

本次完成了真实V41原包的嵌套容器处理和代码空间增长验证，未生成扩容运行固件。用户的验证环境为Windows 10/11，仅有USB线和官方升级工具。64步目标仍暂缓。

## 已实际运行的验证

`tools/jieli_flash.py`检查Flash头、顶层JLFS头、SPL银行头/载荷、芯片密钥记录、应用父目录、子文件和P11资源CRC；保留区描述符不当作实际文件载荷读取。SFC以32字节块解码，支持资源头跨块边界。

`tools/firmware_container.py`检查两份UFW的所有条目载荷CRC。配置、script.ver、farg.cfg和blimit.bin使用各自芯片密钥，并以**UFW容器偏移**作为SFC块偏移，不能以条目开头作为零点。

`tools/verify_package.py`在原包上完成：

- 完整解码、重建后的BUP与原版逐字节一致。
- 在内存中修改应用一个字节，八份Flash均更新应用CRC、父目录CRC和头CRC；UFW表和头CRC也更新，重新解析通过。
- 再把应用换回原版，完整BUP逐字节还原。
- 为应用增加4096字节测试内容，移动后续配置和资源数据、更新JLFS偏移/长度、重新分配UFW载荷并按新位置重编码辅助元数据。八份变体均通过重解析，配置与P11资源内容不变，VM/BTIF/EXIF/USERIF描述符不变。

4096字节增长是在内存中使用测试图案执行的，不包含宏扩容接入代码，也没有输出测试固件文件。

## Flash空间静态边界

| 变体 | 原载荷字节 | 按原保留区描述符计算的增长空间 |
| --- | ---: | ---: |
| flash.bin | 241664 | 8192 |
| flash2.bin | 237824 | 5120 |
| flash3.bin | 241664 | 12288 |
| flash4.bin | 237824 | 9216 |

两份UFW的同名变体布局一致，芯片密钥不同。增长空间按`app_dir_base + VM.offset - 原Flash载荷长度`计算，并在打包器中执行边界检查；这不替代运行时Flash驱动映射验证。所有变体共同支持的静态上限为5120字节，已验证其中4096字节。

UFW的tail.bin保持原字节；目前尚未解释其全部字段及升级工具对修改包的处理。CRC通过不能证明升级工具接受或设备能够启动。

## 确认的第二个RAM限制

启动代码把`0x1e352b0`处的0x880字节复制到RAM `0x840`。其中四个12字节描述符为：

| 描述符RAM | 容量 | 缓冲区RAM | 结束地址（不包含） |
| --- | ---: | --- | --- |
| 0x928 | 256 | 0x3d70 | 0x3e70 |
| 0x934 | 328 | 0x3e70 | 0x3fb8 |
| 0x940 | 256 | 0x3fb8 | 0x40b8 |
| 0x94c | 256 | 0x40b8 | 0x41b8 |

接收重组路径`0x1e06634`读取描述符`+2`的容量，`0x1e0663c`在新重组长度大于等于容量时跳过复制。长度累计字段是16位，但现有容量仍装不下412字节宏，且协议自身还有包头等开销。因此只修改35条记录上限或只扩大宏存储对象，都不能完成APP长宏互通。

旧配置对象正好结束于0x3d70，紧接第一个通信缓冲区。后面还有其他全局对象，不能覆盖。

## 接入方案与未完成部分

方案是分配新配置对象、迁移所有配置引用后，再把已经废弃的旧3152字节静态对象用于控制信息和四个512字节通信缓冲。仅布局上，64字节控制区加2048字节缓冲能放入旧空间；**这一复用尚未写入原固件**，依赖初始化顺序和完整引用迁移。

另外找到物理页分配初始化参数0x8a68..0xfb60。它只说明静态传参范围，不能推导连接、录制和蓝牙工作时还剩多少RAM，也不能把物理页与虚拟堆空间等同。

尚缺运行时分配/跳转接入、全部槽与配置步长修改、工厂重置、版本化迁移与断电恢复、通信长包验证，以及实际升级/回放验证。构建脚本仍不会生成标称可用的扩容包。

## 重现

```sh
make check
python3 -m tools.audit_memory /path/to/app.bin --output build/memory-audit.json
python3 -m tools.verify_package '/path/to/01战甲X Pro固件-V41.bup' --exercise-replacement --exercise-growth 4096 --output build/container-verification.json
```

真实包的校验报告保存在`container-verification.json`，内存证据保存在`memory-audit.json`。源码测试使用合成样本，官方二进制不提交仓库。

格式参考：[jl-misctools](https://github.com/kagaimiq/jl-misctools)的ENC/SFC/JLFS/芯片密钥布局；辅助条目的容器偏移规则也参考了[独立AC791N研究记录](https://github.com/ip2k/lunar-modulator/blob/main/notes/2026-10-09-offline-container.md)，随后针对本项目实际AC632N V41包逐项验证。ROM符号对应参考[杰理bd19 ROM符号表](https://github.com/Jieli-Tech/fw-AC63_BT_SDK/blob/master/cpu/bd19/maskrom_stubs.ld)，未据此声称运行时内存已验证。
