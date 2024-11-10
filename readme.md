# Ge-MIPS

- 原始仓库：[https://gitee.com/kevenge/GeMIPS](https://gitee.com/kevenge/GeMIPS)
- 镜像仓库：[https://github.com/KevenGe/GeMIPS](https://github.com/KevenGe/GeMIPS)
- Vivado 2019.2 可直接打开的项目：[https://gitee.com/kevenge/GeMIPS/releases/v0.4](https://gitee.com/kevenge/GeMIPS/releases/v0.4)

## News

### 2024-11-10🥰

😄😄😄最近了看到了[806](https://ustb-806.github.io/)师弟们的一些关于龙芯杯的相关比赛成就（[第八届全国大学生计算机系统能力培养大赛（龙芯杯）](https://ustb-806.github.io/news/2024/10/lxb/)和[第四届全国大学生计算机系统能力大赛（操作系统设计赛）](https://ustb-806.github.io/news/2024/10/os-competition/)），感慨万分，虽不曾谋面，祝所有的师弟师妹们都能够取得更好的成就!

## 介绍

本项目是 2020 年全国计算机系统能力大赛个人赛的参赛代码，关于该比赛的详细信息可以访问[计算机系统能力大赛](http://www.nscscc.org/a/guanyudasai/2020/0418/60.html)

本项目是使用 Verilog 语言编写的基于 MIPS 指令集的 CPU。本项目目前支持 MIPS 的 22 条指令，并且通过 FPGA 上板测试。

| 序号 |  指令   | 编码                             |
| :--: | :-----: | :------------------------------- |
|  1   | `ADDIU` | 001001ssssstttttiiiiiiiiiiiiiiii |
|  2   | `ADDU`  | 000000ssssstttttddddd00000100001 |
|  3   |  `AND`  | 000000ssssstttttddddd00000100100 |
|  4   | `ANDI`  | 001100ssssstttttiiiiiiiiiiiiiiii |
|  5   |  `BEQ`  | 000100ssssstttttoooooooooooooooo |
|  6   | `BGTZ`  | 000111sssss00000oooooooooooooooo |
|  7   |  `BNE`  | 000101ssssstttttoooooooooooooooo |
|  8   |   `J`   | 000010iiiiiiiiiiiiiiiiiiiiiiiiii |
|  9   |  `JAL`  | 000011iiiiiiiiiiiiiiiiiiiiiiiiii |
|  10  |  `JR`   | 000000sssss0000000000hhhhh001000 |
|  11  |  `LB`   | 100000bbbbbtttttoooooooooooooooo |
|  12  |  `LUI`  | 00111100000tttttiiiiiiiiiiiiiiii |
|  13  |  `LW`   | 100011bbbbbtttttoooooooooooooooo |
|  14  |  `MUL`  | 011100ssssstttttddddd00000000010 |
|  15  |  `OR`   | 000000ssssstttttddddd00000100101 |
|  16  |  `ORI`  | 001101ssssstttttiiiiiiiiiiiiiiii |
|  17  |  `SB`   | 101000bbbbbtttttoooooooooooooooo |
|  18  |  `SLL`  | 00000000000tttttdddddaaaaa000000 |
|  19  |  `SRL`  | 00000000000tttttdddddaaaaa000010 |
|  20  |  `SW`   | 101011bbbbbtttttoooooooooooooooo |
|  21  |  `XOR`  | 000000ssssstttttddddd00000100110 |
|  22  | `XORI`  | 001110ssssstttttiiiiiiiiiiiiiiii |

本项目在项目中的评测性能主要是性能测试，在功能测试以及性能测试通过的前提下，执行时间越短便具有越高的性能。

性能测试的三个测试可以在`supervisor_v2.01`中的`supervisor_v2.01\kernel\kern\test.s`找到对应的MIPS汇编代码。

<img src="./docs/imgs/性能测试%20STREAM%20结果.jpg" style="width:500px"/>

<img src="./docs/imgs/性能测试%20MATRIX%20结果.jpg" style="width:500px"/>

<img src="./docs/imgs/性能测试%20COPYTONIGHT%20结果.jpg" style="width:500px"/>

决赛任务的测试结果

<img src="./docs/imgs/决赛编程任务%20结果.jpg" style="width:500px"/>

<img src="./docs/imgs/决赛编程任务%20结果（只读低22位）.jpg" style="width:500px"/>

## 项目特点

-   项目采用五级流水线架构
-   项目采用单发射机制
-   完成基本指令
-   具有比较详细的注释（中间由于一些原因，造成了一些注释乱码，后期未有精力进行修改）
-   具有良好的公开串口通信代码，并且在本项目测试可用

## 项目结构

注意，本项目使用Vivado 2019.2 进行构建，并且本仓库只包括重要的源代码部分，如果需要使用，请先建立好项目，再复制本代码。

```text
D:.
├─constrs_1                         # 限制
│  └─new
├─sim_1                             # 仿真
│  ├─imports
│  └─new
│      └─include
└─sources_1                         # Verilog源代码
    ├─GeMIPS
    │  ├─EX                         # 执行
    │  ├─ID                         # 译指
    │  ├─IF                         # 取指
    │  ├─include                    # 全局文件（包含宏定义）
    │  ├─MEM                        # 访存
    │  └─WB                         # 写回
    ├─ip
    │  ├─ila_0                      # IP核，JTAG远程调试使用
    │  │  ├─doc
    │  │  ├─hdl
    │  │  │  └─verilog
    │  │  ├─ila_v6_2
    │  │  │  └─constraints
    │  │  ├─sim
    │  │  └─synth
    │  └─pll_example
    │      └─doc
    └─new
```

## 使用方法

1. 使用Vivado在本地创建好项目
2. 复制本项目代码到`src`目录
3. 设置`include.v`为全局文件
4. 设置`thinktop.v`为顶层文件

## 联系方式

USTB - KevenGe

QQ Mail: 1985996902@qq.com

## 鸣谢

在完成本项目的时候，通过雷思磊的《自己动手写 CPU》进行了前期的分析以及测试，特此感谢。

同时也非常感谢龙芯带来的竞赛支持，促使本人提升了个人能力。

## License

GPL 3.0
