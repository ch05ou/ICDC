module LASER (
input CLK,
input RST,
input [3:0] X,
input [3:0] Y,
output reg [3:0] C1X,
output reg [3:0] C1Y,
output reg [3:0] C2X,
output reg [3:0] C2Y,
output DONE);

localparam DATA_IN = 0;
localparam C1_INIT = 1;
localparam C2_INIT = 2;
localparam C1_ITER_INIT = 3;
localparam C1_ITER = 4;
localparam C2_ITER_INIT = 5;
localparam C2_ITER = 6;
localparam FINISH = 7;

parameter r = 4;
parameter R = 16;

integer i;

reg [2:0]now_state,nxt_state;
reg [5:0]data_count,count;
reg [3:0]x[0:39];
reg [3:0]y[0:39];
reg [7:0]c1_max,c2_max,C1_in,C2_in;
reg [3:0]cal_C1X,cal_C1Y,old_C1X,old_C1Y;
reg [3:0]cal_C2X,cal_C2Y,old_C2X,old_C2Y;
reg [3:0]end_loc[0:1];
wire inC1,inC2;

IN_or_OUT U0(.X(x[count]),.Y(y[count]),.CX1(cal_C1X),.CY1(cal_C1Y),.CX2(cal_C2X),.CY2(cal_C2Y),.inC1(inC1),.inC2(inC2));

assign DONE = (now_state == FINISH);

always @(posedge CLK) begin
    if(RST) now_state <= DATA_IN;
    else now_state <= nxt_state;
end

always @(*) begin
    case(now_state)
        DATA_IN:begin
            nxt_state = (data_count == 40)? C1_INIT : DATA_IN;
        end
        C1_INIT:begin
            nxt_state = (cal_C1X == 15 && cal_C1Y == 15 && count == 39)? C2_INIT: C1_INIT;
        end
        C2_INIT:begin
            nxt_state = (cal_C2X == 15 && cal_C2Y == 15 && count == 39)? C1_ITER_INIT: C2_INIT;
        end
        C1_ITER_INIT:begin
            nxt_state = (C2X == old_C2X && C2Y == old_C2Y)? FINISH:C1_ITER;
        end
        C1_ITER:begin
            nxt_state = (cal_C1X == end_loc[0] && cal_C1Y == end_loc[1] && count == 39)? C2_ITER_INIT : C1_ITER;
        end
        C2_ITER_INIT:begin
            nxt_state = (C1X == old_C1X && C1Y == old_C1Y)? FINISH:C2_ITER;
        end
        C2_ITER:begin
            nxt_state = (cal_C2X == end_loc[0] && cal_C2Y == end_loc[1])? C1_ITER_INIT : C2_ITER;
        end
        FINISH:begin
            nxt_state = DATA_IN;
        end
        default:begin
            nxt_state = DATA_IN;
        end
    endcase
end

always @(posedge CLK) begin
    if(RST)begin
        data_count <= 0;
        count <= 0;
        C1X <= 0;
        C1Y <= 0;
        C2X <= 0;
        C2Y <= 0;
        C1_in <= 0;
        C2_in <= 0;
        cal_C1X <= 0;
        cal_C1Y <= 0;
        cal_C2X <= 0;
        cal_C2Y <= 0;
        c1_max <= 0;
        c2_max <= 0;
        old_C1X <= 0;
        old_C1Y <= 0;
        old_C2X <= 0;
        old_C2Y <= 0;
        end_loc[0] <= 0;
        end_loc[1] <= 0; 
        for(i=0;i<40;i=i+1)begin
            x[i] <= 0;
            y[i] <= 0;
        end
    end
    else begin
        case(now_state)
            DATA_IN:begin
                C1X <= 0;
                C1Y <= 0;
                C2X <= 0;
                C2Y <= 0;
                C1_in <= 0;
                C2_in <= 0;
                cal_C1X <= 0;
                cal_C1Y <= 0;
                cal_C2X <= 0;
                cal_C2Y <= 0;
                c1_max <= 0;
                c2_max <= 0;
                old_C1X <= 0;
                old_C1Y <= 0;
                old_C2X <= 0;
                old_C2Y <= 0;
                end_loc[0] <= 0;
                end_loc[1] <= 0; 
                data_count <= data_count + 1;
                x[data_count] <= X;
                y[data_count] <= Y;
            end
            C1_INIT:begin
                count <= (count == 39)? 0:count + 1;
                cal_C1X <= (count == 39)? (cal_C1X == 15 && cal_C1Y == 15)? C1X : cal_C1X+1 : cal_C1X;
                cal_C1Y <= (count == 39 && cal_C1X == 15)? (cal_C1Y == 15)? C1Y : cal_C1Y+1 : cal_C1Y;
                C1_in <= (count == 39)? 0:(inC1)? C1_in + 1 : C1_in;
                c1_max <= (C1_in >= c1_max)? C1_in : c1_max;
                C1X <= (C1_in >= c1_max)? cal_C1X : C1X;
                C1Y <= (C1_in >= c1_max)? cal_C1Y : C1Y;
            end
            C2_INIT:begin
                cal_C1X <= C1X;
                cal_C1Y <= C1Y;
                count <= (count == 39)? 0:count + 1;
                cal_C2X <= (count == 39)? (cal_C2X == 15 && cal_C2Y == 15)? C2X:cal_C2X+1 : cal_C2X;
                cal_C2Y <= (count == 39 && cal_C2X == 15)? (cal_C2Y == 15)? C2Y:cal_C2Y+1 : cal_C2Y;
                C2_in <= (count == 39)? 0:(!inC1 && inC2)? C2_in + 1 : C2_in;
                c2_max <= (C2_in >= c2_max)? C2_in : c2_max;
                C2X <= (C2_in >= c2_max)? cal_C2X : C2X;
                C2Y <= (C2_in >= c2_max)? cal_C2Y : C2Y;
            end
            C1_ITER_INIT:begin
                old_C1X <= C1X;
                old_C1Y <= C1Y;
                old_C2X <= C2X;
                old_C2Y <= C2Y;
                cal_C1X <= C1X-3;
                cal_C1Y <= C1Y-3;
                end_loc[0] <= C1X+3;
                end_loc[1] <= C1Y+3;
                cal_C2X <= C2X;
                cal_C2Y <= C2Y;
                c1_max <= 0;
            end
            C1_ITER:begin
                count <= (count == 39)? 0:count + 1;
                cal_C1X <= (count == 39)? (cal_C1X == end_loc[0])? old_C1X-3 : cal_C1X+1 : cal_C1X;
                cal_C1Y <= (count == 39 && cal_C1X == end_loc[0])? cal_C1Y+1 : cal_C1Y;
                C1_in <= (count == 39)? 0:(inC1 && ~inC2)? C1_in + 1 : C1_in;
                c1_max <= (count == 39 && C1_in >= c1_max)? C1_in : c1_max;
                C1X <= (count == 39 && C1_in >= c1_max)? cal_C1X : C1X;
                C1Y <= (count == 39 && C1_in >= c1_max)? cal_C1Y : C1Y;
            end
            C2_ITER_INIT:begin
                old_C1X <= C1X;
                old_C1Y <= C1Y;
                old_C2X <= C2X;
                old_C2Y <= C2Y;
                cal_C2X <= C2X-3;
                cal_C2Y <= C2Y-3;
                end_loc[0] <= C2X+3;
                end_loc[1] <= C2Y+3;
                cal_C1X <= C1X;
                cal_C1Y <= C1Y;
                c2_max <= 0;
            end
            C2_ITER:begin
                count <= (count == 39)? 0:count + 1;
                cal_C2X <= (count == 39)? (cal_C2X == end_loc[0])? old_C2X-3 : cal_C2X+1 : cal_C2X;
                cal_C2Y <= (count == 39 && cal_C2X == end_loc[0])? cal_C2Y+1 : cal_C2Y;
                C2_in <= (count == 39)? 0:(inC2 && ~inC1)? C2_in + 1 : C2_in;
                c2_max <= (count == 39 && C2_in >= c2_max)? C2_in : c2_max;
                C2X <= (count == 39 && C2_in >= c2_max)? cal_C2X : C2X;
                C2Y <= (count == 39 && C2_in >= c2_max)? cal_C2Y : C2Y;
            end
            FINISH:begin
                data_count <= 0;
                count <= 0;
                //DONE <= 0;
                //data_count <= 0;
            end
            default:begin
                data_count <= 0;
            end
        endcase
    end
end

endmodule

module IN_or_OUT(
    input [3:0] X,
    input [3:0] Y,
    input [3:0] CX1,CX2,
    input [3:0] CY1,CY2,
    output inC1,inC2);

    wire [3:0] X1 = (X > CX1)? X - CX1 : CX1 - X;
    wire [3:0] Y1 = (Y > CY1)? Y - CY1 : CY1 - Y;
    wire [3:0] X2 = (X > CX2)? X - CX2 : CX2 - X;
    wire [3:0] Y2 = (Y > CY2)? Y - CY2 : CY2 - Y;
    assign inC1 = (X1*X1 + Y1*Y1) <= 16;
    assign inC2 = (X2*X2 + Y2*Y2) <= 16;
endmodule

