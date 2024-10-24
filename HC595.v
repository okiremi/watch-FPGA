`timescale 1ns / 1ns

module HC595(clk,reset,seg,sel,DIO,SRCLK,RCLK);
    input clk,reset;
    input [7:0] seg;
    input [7:0] sel;
    output reg DIO; //串行数据
    output reg SRCLK; //移位寄存器时钟
    output reg RCLK; //存储寄存器时钟

    parameter CLOCK_FREQ = 50000000;
    parameter SRCLK_FREQ = 12500000; //74HC595工作频率
    parameter MCNT = CLOCK_FREQ / (SRCLK_FREQ * 2) - 1;

    reg [29:0] div_cnt; //分频计数器
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            div_cnt <= 0;
        end
        else if (div_cnt == MCNT) begin
            div_cnt <= 0;
        end
        else
            div_cnt <= div_cnt + 1;
    end
    reg [4:0] cnt; //移位计数器
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            cnt <= 0;
        end
        else if (div_cnt == MCNT) begin
            cnt <= cnt + 1;
        end
    end

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            DIO <= seg[7];
            SRCLK <= 0;
            RCLK <= 1;
        end
        else begin
            case (cnt)
                0: begin DIO <= seg[7]; SRCLK <= 0; RCLK <= 1; end
                1: begin SRCLK <= 1; RCLK <= 0; end
                2: begin DIO <= seg[6]; SRCLK <= 0; end
                3: begin SRCLK <= 1; end
                4: begin DIO <= seg[5]; SRCLK <= 0; end
                5: begin SRCLK <= 1; end
                6: begin DIO <= seg[4]; SRCLK <= 0; end
                7: begin SRCLK <= 1; end
                8: begin DIO <= seg[3]; SRCLK <= 0; end
                9: begin SRCLK <= 1; end
                10: begin DIO <= seg[2]; SRCLK <= 0; end
                11: begin SRCLK <= 1; end
                12: begin DIO <= seg[1]; SRCLK <= 0; end
                13: begin SRCLK <= 1; end
                14: begin DIO <= seg[0]; SRCLK <= 0; end
                15: begin SRCLK <= 1; end
                16: begin DIO <= sel[7]; SRCLK <= 0; end
                17: begin SRCLK <= 1; end
                18: begin DIO <= sel[6]; SRCLK <= 0; end
                19: begin SRCLK <= 1; end
                20: begin DIO <= sel[5]; SRCLK <= 0; end
                21: begin SRCLK <= 1; end
                22: begin DIO <= sel[4]; SRCLK <= 0; end
                23: begin SRCLK <= 1; end
                24: begin DIO <= sel[3]; SRCLK <= 0; end
                25: begin SRCLK <= 1; end
                26: begin DIO <= sel[2]; SRCLK <= 0; end
                27: begin SRCLK <= 1; end
                28: begin DIO <= sel[1]; SRCLK <= 0; end
                29: begin SRCLK <= 1; end
                30: begin DIO <= sel[0]; SRCLK <= 0; end
                31: begin SRCLK <= 1; end
            endcase
        end
    end
endmodule
