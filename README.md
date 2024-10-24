# watch-FPGA
功能描述：基于Xilinx AXC750的计时秒表，可进行分、秒和0.01秒的计时，通过两个按键控制重置计时和暂停计时。
开发环境：vivado 2018.2
编程语言：verilog
芯片型号：Xilinx ACX750
板卡型号：xc7a35tfgg484-2
hex_clock.v //主模块
hex_test.v //数码管显示配置
HC595.v //HC595驱动模块
hex_clock_xdc.xdc //管脚配置文件
