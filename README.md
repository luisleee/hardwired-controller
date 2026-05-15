# hardwired

一个用 SystemVerilog 编写、面向 **Altera MAX7000 / EPM7128SLC84-15** 的小型硬布线控制实验工程（CPLD）。

目前仓库包含：
- 本地开源仿真流程（Icarus Verilog / Verilator / GTKWave）
- Quartus 13.0 云端综合流程（GitHub Actions，用于 CPLD 构建）
- CI 产出 `.sof` / `.pof` / `.svf`，其中 `.svf` 可直接用于 OpenOCD

## 目录结构

```text
cpld/   Quartus CPLD 工程与引脚约束
rtl/    SystemVerilog 源码
sim/    本地仿真 testbench 与 Makefile
```

## 本地依赖

### 仿真依赖

- `iverilog`
- `vvp`
- `verilator`
- `gtkwave`
- `make`

在 Arch Linux 上大致是：

```bash
sudo pacman -S iverilog verilator gtkwave make
```

### 综合依赖

本地**不需要**安装 Quartus。

综合由 GitHub Actions 完成，使用预构建镜像：

- `ghcr.io/luisleee/quartus13-max7000:latest`

## 本地仿真

进入 `sim/` 目录：

```bash
cd sim
```

### 运行仿真

```bash
make sim
```

作用：
- 用 `iverilog -g2012` 编译 testbench
- 用 `vvp` 运行仿真
- 生成波形文件

### 打开波形

```bash
make wave
```

### 运行 Verilator lint

```bash
make lint
```

### 清理产物

```bash
make clean
```

## GitHub Actions CPLD 综合

推送到 GitHub 后，workflow 会自动：

1. 拉取 `ghcr.io/luisleee/quartus13-max7000:latest`
2. 运行 `quartus_sh --flow compile cpld/project.qpf`
3. 额外生成 OpenOCD 可用的 `.svf`
4. 上传 artifact

上传产物包括：
- `*.pof`
- `*.svf`
- `*.map.rpt`
- `*.fit.rpt`
- `*.sta.rpt`

## 烧录

CI 会生成`project.svf`。

可以用 OpenOCD进行烧录（暂时没有正确的方法）

会出错：
```bash
openocd -f interface/altera-usb-blaster.cfg -c "jtag newtap epm7128s tap -irlen 10 -expected-id 0x071280DD" -c "init" -c "svf project.svf" -c "shutdown"
```

## 引脚约束

当前引脚定义在：

- `cpld/project.qsf`

顶层端口定义在：

- `rtl/top.sv`

修改引脚时，请保持这两个文件中的信号名一致。
