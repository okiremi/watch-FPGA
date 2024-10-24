`timescale 1ns / 1ns

module hex_clock(clk,reset,DIO,SRCLK,RCLK,run);
    input clk,reset,run;
    output DIO; //串行数据
    output SRCLK; //移位寄存器时钟
    output RCLK; //存储寄存器时钟

    wire [7:0] seg, sel; // 位选数据与段选数据
    reg [31:0] disp_data; // 数码管显示控制数据

    parameter CLOCK_FREQ = 50000000; // 系统时钟
    parameter HEX_FREQ = 100; // 计时精度
    parameter HEX_CYCLE = CLOCK_FREQ / HEX_FREQ - 1; // 最大计数量

    reg [31:0] counter_100Hz; // 系统计数器
    reg [5:0] minutes; // 计分模块
    reg [5:0] seconds; // 计秒模块
    reg [6:0] hundredths; // 0.01秒模块
    reg paused; // 计时运行状态
    reg paused_last_state; // 暂停按钮在上一个时钟周期的状态
    reg paused_state; // 暂停按钮在当前时钟周期的状态

    //例化数码管显示模块
    hex_test dut(
        .clk(clk),
        .reset(reset),
        .disp_data(disp_data),
        .sel(sel),
        .seg(seg)
    );

    HC595 uut(
        .clk(clk),
        .reset(reset),
        .seg(seg),
        .sel(sel),
        .DIO(DIO),
        .SRCLK(SRCLK),
        .RCLK(RCLK)
    );

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            counter_100Hz <= 0;
            minutes <= 0;
            seconds <= 0;
            hundredths <= 0;
            paused <= 0;
            paused_state <= 0;
            paused_last_state <= 0;
        end else begin
            // 系统运行过程中的状态机配置
            paused_last_state <= paused_state;
            paused_state <= run;
            if (paused_last_state == 1 && paused_state == 0)
                paused <= ~paused;
            //系统计时逻辑
            if (!paused) begin
                if (counter_100Hz == HEX_CYCLE) begin
                    counter_100Hz <= 0;
                    if (hundredths == 99) begin
                        hundredths <= 0;
                        if (seconds == 59) begin
                            seconds <= 0;
                            if (minutes == 59) begin
                                minutes <= 0;
                            end else begin
                                minutes <= minutes + 1;
                            end
                        end else begin
                            seconds <= seconds + 1;
                        end
                    end else begin
                        hundredths <= hundredths + 1;
                    end
                end else begin
                    counter_100Hz <= counter_100Hz + 1;
                end
            end
        end
    end
    // 数码管显示控制逻辑
    always @(*) begin
        disp_data[3:0]   = hundredths % 10; // 第一个数码管
        disp_data[7:4]   = hundredths / 10; // 第二个数码管
        disp_data[11:8]  = seconds % 10; // 第三个数码管
        disp_data[15:12] = seconds / 10; // 第四个数码管
        disp_data[19:16] = minutes % 10; // 第五个数码管
        disp_data[23:20] = minutes / 10; // 第六个数码管
        disp_data[27:24] = 8'b00000000;
        disp_data[31:28] = 8'b00000000; // Unused
    end

endmodule
