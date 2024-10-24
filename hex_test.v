`timescale 1ns / 1ns

module hex_test(clk,reset,disp_data,sel,seg);
    input clk; //时钟
    input reset; //复位
    input [31:0] disp_data; //32位二极管驱动显示数据
    output reg [7:0] sel; //位选信号
    output reg [7:0] seg; //段选信号

    reg [29:0] disp_counter; //数码管切换定时计数器

    parameter CLOCK_FREQ = 50000000; //时钟频率
    parameter TURN_FREQ = 1000; //转码频率
    parameter MCNT = CLOCK_FREQ/TURN_FREQ - 1; //1个周期的计数值

    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            disp_counter <= 0;
        end
        else if (disp_counter == MCNT) begin
            disp_counter <= 0;
        end
        else begin
            disp_counter <= disp_counter + 1;
        end
    end

    reg [2:0] sel_counter; //位选计数器
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            sel_counter <= 0;
        end
        else if (disp_counter == MCNT) begin
            sel_counter <= sel_counter + 1;
        end
    end
    //通过三八译码器输出位选信号
    always @(posedge clk) begin
        case (sel_counter)
            0: sel <= 8'b00000001;
            1: sel <= 8'b00000010;
            2: sel <= 8'b00000100;
            3: sel <= 8'b00001000;
            4: sel <= 8'b00010000;
            5: sel <= 8'b00100000;
            6: sel <= 8'b01000000;
            7: sel <= 8'b10000000;
        endcase
    end

    reg [3:0] data_temp; //段选索引
    always @(posedge clk) begin
        case(data_temp)
            0: seg <= 8'b11000000;
            1: seg <= 8'b11111001;
            2: seg <= 8'b10100100;
            3: seg <= 8'b10110000;
            4: seg <= 8'b10011001;
            5: seg <= 8'b10010010;
            6: seg <= 8'b10000010;
            7: seg <= 8'b11111000;
            8: seg <= 8'b10000000;
            9: seg <= 8'b10010000;
            default : seg <= 8'b11111111;
        endcase
    end
    //通过位选控制段选
    always @(*) begin
        case (sel_counter)
            0: data_temp <= disp_data[3:0] % 10;
            1: data_temp <= disp_data[7:4] % 10;
            2: data_temp <= disp_data[11:8] % 10;
            3: data_temp <= disp_data[15:12] % 10;
            4: data_temp <= disp_data[19:16] % 10;
            5: data_temp <= disp_data[23:20] % 10;
            6: data_temp <= disp_data[27:24] % 10;
            7: data_temp <= disp_data[31:28] % 10;
        endcase
    end
endmodule
