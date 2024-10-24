`timescale 1ns / 1ns

module hex_clock(clk,reset,DIO,SRCLK,RCLK,run);
    input clk,reset,run;
    output DIO; //��������
    output SRCLK; //��λ�Ĵ���ʱ��
    output RCLK; //�洢�Ĵ���ʱ��

    wire [7:0] seg, sel; // λѡ�������ѡ����
    reg [31:0] disp_data; // �������ʾ��������

    parameter CLOCK_FREQ = 50000000; // ϵͳʱ��
    parameter HEX_FREQ = 100; // ��ʱ����
    parameter HEX_CYCLE = CLOCK_FREQ / HEX_FREQ - 1; // ��������

    reg [31:0] counter_100Hz; // ϵͳ������
    reg [5:0] minutes; // �Ʒ�ģ��
    reg [5:0] seconds; // ����ģ��
    reg [6:0] hundredths; // 0.01��ģ��
    reg paused; // ��ʱ����״̬
    reg paused_last_state; // ��ͣ��ť����һ��ʱ�����ڵ�״̬
    reg paused_state; // ��ͣ��ť�ڵ�ǰʱ�����ڵ�״̬

    //�����������ʾģ��
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
            // ϵͳ���й����е�״̬������
            paused_last_state <= paused_state;
            paused_state <= run;
            if (paused_last_state == 1 && paused_state == 0)
                paused <= ~paused;
            //ϵͳ��ʱ�߼�
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
    // �������ʾ�����߼�
    always @(*) begin
        disp_data[3:0]   = hundredths % 10; // ��һ�������
        disp_data[7:4]   = hundredths / 10; // �ڶ��������
        disp_data[11:8]  = seconds % 10; // �����������
        disp_data[15:12] = seconds / 10; // ���ĸ������
        disp_data[19:16] = minutes % 10; // ����������
        disp_data[23:20] = minutes / 10; // �����������
        disp_data[27:24] = 8'b00000000;
        disp_data[31:28] = 8'b00000000; // Unused
    end

endmodule
