module SET ( clk , rst, en, central, radius, mode, busy, valid, candidate );

input clk, rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0] mode;
output reg busy;
output reg valid;
output reg [7:0] candidate;

localparam INIT = 0;
localparam RD = 1;
localparam MD_0 = 2;
localparam MD_1 = 3;
localparam MD_2 = 4;
localparam MD_3 = 5;
localparam S6 = 6;
localparam FINISH = 7;

reg [2:0]now_state,nxt_state;
reg [3:0]ax,ay,bx,by,cx,cy,ra,rb,rc,cal_x,cal_y;
reg a_in,b_in,c_in;
reg [5:0]count,count_ab;

reg signed [4:0]ux,uy,ur,ucx,ucy;
wire [2:0]in;

cal_in U1(.ax({1'b0,ax}),.ay({1'b0,ay}),.ar({1'b0,ra}),
          .bx({1'b0,bx}),.by({1'b0,by}),.br({1'b0,rb}),
          .cx({1'b0,cx}),.cy({1'b0,cy}),.cr({1'b0,rc}),
          .cal_x({1'b0,cal_x}),.cal_y({1'b0,cal_y}),.in(in));

always @(posedge clk ,posedge rst) begin
    if(rst)begin
        now_state <= INIT;
    end
    else begin
        now_state <= nxt_state;
    end
end

always @(*) begin
    case (now_state)
        INIT:begin
            nxt_state = RD;
        end 
        RD:begin
            if(mode == 2'b00)begin
                nxt_state = MD_0;
            end
            else if(mode == 2'b01)begin
                nxt_state = MD_1;
            end
            else if(mode == 2'b10)begin
                nxt_state = MD_2;
            end
            else begin
                nxt_state = MD_3;
            end
        end
        MD_0:begin
            nxt_state = (cal_x == 8 && cal_y == 8)? S6:MD_0;
        end
        MD_1:begin
            nxt_state = (cal_x == 8 && cal_y == 8)? S6:MD_1;
        end
        MD_2:begin
            nxt_state = (cal_x == 8 && cal_y == 8)? S6:MD_2;
        end
        MD_3:begin
            nxt_state = (cal_x == 8 && cal_y == 8)? S6:MD_3;
        end
        S6:begin
            nxt_state = FINISH;
        end
        FINISH:begin
            nxt_state = INIT;
        end
        default:nxt_state = INIT; 
    endcase
end

always @(posedge clk or posedge rst) begin
    if(rst)begin
        count <= 0;
        cal_x <= 1;
        cal_y <= 1;
    end
    else begin
        case (now_state)
            INIT:begin
                count <= 0;
            end
            RD:begin
                count <= 0;
                cal_x <= 1;
                cal_y <= 1;
            end
            MD_0:begin
                cal_x <= (cal_x == 8)? 1:cal_x+1;
                cal_y <= (cal_x == 8)? cal_y+1:cal_y;
                count <= (in[0])? count+1:count;
            end
            MD_1:begin
                cal_x <= (cal_x == 8)? 1:cal_x+1;
                cal_y <= (cal_x == 8)? cal_y+1:cal_y;
                count <= (in[0] && in[1])? count+1:count;
            end
            MD_2:begin
                cal_x <= (cal_x == 8)? 1:cal_x+1;
                cal_y <= (cal_x == 8)? cal_y+1:cal_y;
                count <= ((in[0] && !in[1]) || ((!in[0]) && in[1]))? count+1:count;
            end
            MD_3:begin
                cal_x <= (cal_x == 8)? 1:cal_x+1;
                cal_y <= (cal_x == 8)? cal_y+1:cal_y;
                count <= (in[0]&& in[1] && !in[2]) || 
                            (in[0]&& !in[1] && in[2]) || 
                            (!in[0]&& in[1] && in[2])? count+1:count;
            end
            S6:begin
                candidate <= count;
            end
            default:begin
            end
        endcase
    end
end

// Read Data
always @(*) begin
    ax = (en)? central[23:20]:ax;
    ay = (en)? central[19:16]:ay;
    bx = (en)? central[15:12]:bx;
    by = (en)? central[11:8]:by;
    cx = (en)? central[7:4]:cx;
    cy = (en)? central[3:0]:cy;
    ra = (en)? radius[11:8]:ra;
    rb = (en)? radius[7:4]:rb;
    rc = (en)? radius[3:0]:rc;
end

// Busy signal
always @(*) begin
    if(rst)begin
        busy = 1'b0;
    end
    else begin
        busy = (now_state == RD)? 1'b0:1'b1;
    end
end

// Valid signal
always @(*) begin
    if(rst)begin
        valid = 1'b0;
    end
    else begin
        valid = (now_state == FINISH)? 1'b1:1'b0;
    end
end

endmodule

module cal_in(
    input signed[4:0]ax,ay,ar,bx,by,br,cx,cy,cr,cal_x,cal_y,
    output [2:0]in);

    wire [9:0]tmp_a,tmp_b,tmp_c,r2a,r2b,r2c;
    
    assign r2a = ar*ar;
    assign r2b = br*br;
    assign r2c = cr*cr;

    assign tmp_a = (((ax-cal_x)*(ax-cal_x)) + ((ay-cal_y)*(ay-cal_y)));
    assign tmp_b = (((bx-cal_x)*(bx-cal_x)) + ((by-cal_y)*(by-cal_y)));
    assign tmp_c = (((cx-cal_x)*(cx-cal_x)) + ((cy-cal_y)*(cy-cal_y)));

    assign in[0] = (tmp_a <= r2a)? 1'b1:1'b0;
    assign in[1] = (tmp_b <= r2b)? 1'b1:1'b0;
    assign in[2] = (tmp_c <= r2c)? 1'b1:1'b0;

endmodule
