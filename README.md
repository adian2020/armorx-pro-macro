# ARMOR-X Pro Macro

战甲X Pro V41宏录制容量扩展研究。当前验证目标：保留三组配置、每组四个独立宏，使每个宏可容纳32次完整按下/松开；64步扩展暂缓。

**目前没有完成可刷写的扩容固件。仓库包含经过离线测试的存储核心和固件分析，不应将目标处理器 `.o` 文件交给升级工具。**

## 已完成

- 核对官方V41包身份，拆解BUP、UFW和八份Flash变体。
- 定位35条内部记录上限、6字节记录、220字节宏槽和1024字节配置布局。
- 定位D8写宏、D9读宏，以及录制、回放、清除、配置切换和保存相关路径。
- 实现三组配置、十二个独立宏槽的C存储原型，每槽67条记录/412字节。
- 验证旧数据迁移、容量边界、CRC、十二槽互不覆盖及保存数据恢复。
- 补充完整配置对象迁移原型，保留68字节前缀和12字节尾记录；核对尾记录长度字节序，避免误改`0xc00`常数。
- 使用杰理官方工具链交叉编译为Q32s处理器代码。

## 构建和测试

```sh
make check
```

需要C编译器和Python 3。C测试默认开启AddressSanitizer与UndefinedBehaviorSanitizer。这里的保存/恢复测试在主机内存中执行，不能替代手柄断电测试。

有杰理官方工具链时可交叉编译：

```sh
make q32s JL_CLANG=/path/to/common/bin/clang JL_OBJDUMP=/path/to/common/bin/objdump
```

## 固件分析

自行下载官方包并解压出本体BUP，执行：

```sh
python3 tools/inspect_bup.py '01战甲X Pro固件-V41.bup' build/inspection
```

脚本验证头部和载荷CRC、提取两份UFW，并检查外层重建能否逐字节还原原版。原始包身份和官方地址见[original-identity.json](docs/original-identity.json)。

准备好原版解码后的 `app.bin` 和官方工具生成的Q32s反汇编后：

```sh
python3 tools/audit_original.py --app /path/to/app.bin --asm /path/to/app-q32s.asm --output build/integration-audit.json
```

## 可刷固件仍缺少什么

原完整配置对象3152字节，新布局连同相同前后缀需要5456字节。原地扩容会与已有RAM对象冲突；若保留原静态对象再申请新对象，需至少5456字节连续可用堆内存及运行余量。

以下环节尚未闭环验证：新对象分配与初始化、完整地址引用迁移、工厂重置、通信缓冲容量、断电保存和恢复、八份Flash的补丁及重打包、实机录制和回放。

构建脚本会检查这些条件；条件不满足时拒绝生成标称“扩容成功”的刷机包。当前失败不是升级工具问题，也不应通过跳过检查解决。

- [第二路线详细进展](docs/route2-prototype.zh-CN.md)
- [集成审查清单](docs/integration-audit.json)
- [手柄录制与APP互通](docs/recording-app-interop.zh-CN.md)
- [最初固件分析](docs/initial-analysis.zh-CN.md)

## 文件范围

仓库提供本项目源码、测试、研究记录和必要反汇编片段。官方固件、官方APP、升级程序、完整反汇编和工具链应从对应来源获取；它们不适用本项目源码的许可。

参考：杰理[官方Linux工具链](https://pkgman.jieliapp.com/s/linux-toolchain)、[jl-misctools](https://github.com/kagaimiq/jl-misctools)、[armorx-toolkit](https://github.com/feshinkof-boop/armorx-toolkit)。这些项目为研究提供参考，不表示其作者验证了本项目补丁。
