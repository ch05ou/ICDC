
`timescale 1ns/10ps
// 165190 ns (pre-sim) / 1597820 (post-sim (ultra) )
// 5519 um^2 / 4070 um^2 (ultra) 
// Score 9104378260 (ultra) -> Grade A
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
output  reg [13:0] 	gray_addr;
output         	gray_req;
input   	    gray_ready;
input   [7:0] 	gray_data;
output  reg [13:0] 	lbp_addr;
output  	lbp_valid;
output  reg [7:0] 	lbp_data;
output  	finish;
//====================================================================
localparam INIT = 0;
localparam RD_CAL = 1;
localparam RD_0 = 2;
localparam RD_1 = 3;
localparam RD_2 = 4;
localparam RD_3 = 5;
localparam RD_4 = 6;
localparam RD_5 = 7;
localparam RD_6 = 8;
localparam RD_7 = 9;
localparam WR = 14;
localparam FINISH = 15;

reg [3:0]now_state,next_state;
reg [7:0]pic_data;

assign finish = (now_state == FINISH)? 1:0;
assign lbp_valid = (now_state == WR)? 1:0;
assign gray_req = (now_state >= 1 && now_state <= 9)? 1:0; 

always @(posedge clk , posedge reset) begin
    if(reset) now_state <= INIT;
    else now_state <= next_state;
end

always @(*) begin
    case(now_state)
        INIT    :   next_state = RD_CAL;
        RD_CAL  :   next_state = (lbp_addr <= 127 || lbp_addr >= 16256 || lbp_addr[6:0] == 127 || lbp_addr[6:0]  == 0)? WR:RD_0;
        RD_0    :   next_state = RD_1;
        RD_1    :   next_state = RD_2;
        RD_2    :   next_state = RD_3;
        RD_3    :   next_state = RD_4;
        RD_4    :   next_state = RD_5;
        RD_5    :   next_state = RD_6;
        RD_6    :   next_state = RD_7;
        RD_7    :   next_state = WR;
        WR      :   next_state = (lbp_addr == 16383)? FINISH : RD_CAL;
        default :   next_state = INIT;
    endcase
end

always @(posedge clk , posedge reset) begin
    if(reset)begin
        lbp_addr <= 0;
        lbp_data <= 0;
        gray_addr <= 0;
    end
    else begin
        case(now_state)
            RD_CAL : begin
                lbp_data <= 0;
                gray_addr <= lbp_addr - 129;
                pic_data <= gray_data;
            end
            RD_0 : begin
                gray_addr <= lbp_addr - 128;
                lbp_data[0] <= (pic_data <= gray_data)? 1:0;
            end
            RD_1 : begin
                gray_addr <= lbp_addr - 127;
                lbp_data[1] <= (pic_data <= gray_data)? 1:0;
            end
            RD_2 : begin
                gray_addr <= lbp_addr - 1;
                lbp_data[2] <= (pic_data <= gray_data)? 1:0;
            end
            RD_3 : begin
                gray_addr <= lbp_addr + 1;
                lbp_data[3] <= (pic_data <= gray_data)? 1:0;
            end
            RD_4 : begin
                gray_addr <= lbp_addr + 127;
                lbp_data[4] <= (pic_data <= gray_data)? 1:0;
            end
            RD_5 : begin
                gray_addr <= lbp_addr + 128;
                lbp_data[5] <= (pic_data <= gray_data)? 1:0;
            end
            RD_6 :begin
                gray_addr <= lbp_addr + 129;
                lbp_data[6] <= (pic_data <= gray_data)? 1:0;
            end
            RD_7 :begin
                lbp_data[7] <= (pic_data <= gray_data)? 1:0;
            end
            WR : begin
                lbp_addr <= lbp_addr + 1;
                gray_addr <= lbp_addr + 1;
                //lbp_data <= lbp_data + 1;
            end
        endcase
    end
end
//====================================================================
endmodule
