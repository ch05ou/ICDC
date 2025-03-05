module geofence ( clk,reset,X,Y,R,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
input [10:0] R;
output valid;
output is_inside;
//reg valid;
//reg is_inside;

localparam DATA_IN = 0;
localparam SORT = 1;
localparam DATA_SWAP = 2;
localparam CAL_AREA6 = 3;
localparam CAL_AREA6_WR = 4;
localparam CAL_EDGE = 5;
localparam CAL_EDGE_WR = 6;
localparam CAL_AREA7 = 7;
localparam CAL_AREA7_WR = 8;
localparam FINISH = 9;

reg [3:0]now_state,nxt_state;
reg [9:0]data_X[0:5];
reg [9:0]data_Y[0:5];
reg [10:0]data_R[0:5];
reg [2:0]data_count;
reg [2:0]sort_count,edge_count,edge7_count,aera7_count;

reg signed[10:0]ref_X,d1_X,d2_X;
reg signed[10:0]ref_Y,d1_Y,d2_Y;
reg signed[11:0]Ax,Ay,Bx,By;
reg signed[21:0]res;

wire [10:0]sqrt1_res,sqrt2_res,sqrt3_res;
reg [10:0]sqrt1_res_pip;

reg [9:0]dis_x1,dis_y1,dis_x2,dis_y2;
wire [21:0]dis_x,dis_y;

reg signed [22:0]edge7res;
wire [10:0]D;
reg signed [22:0]area6edge,area7edge;
reg [10:0]edge_D[0:5];

reg [10:0]a,b,c;
wire [12:0]sum;
wire [12:0]s_a,s_b,s_c;
wire [21:0]area;

integer i;

assign valid = (now_state == FINISH);
assign is_inside = ( now_state == FINISH && area7edge < area6edge)? 1:0;

assign dis_x = (dis_x1 - dis_x2) * (dis_x1 - dis_x2);
assign dis_y = (dis_y1 - dis_y2) * (dis_y1 - dis_y2);

assign sum = (a + b + c)>>>1;
assign s_a = sum - a;
assign s_b = sum - b;
assign s_c = sum - c;
assign area = sqrt2_res * sqrt3_res;

DW_sqrt #(.width(22))SQRT1(.a(dis_x+dis_y),.root(sqrt1_res));
DW_sqrt #(.width(22))SQRT2(.a({9'd0,sum}*{9'd0,s_a}),.root(sqrt2_res));
DW_sqrt #(.width(22))SQRT3(.a({9'd0,s_b}*{9'd0,s_c}),.root(sqrt3_res));

always @(*) begin
    Ax = d1_X - ref_X;
    Ay = d1_Y - ref_Y;
    Bx = d2_X - ref_X;
    By = d2_Y - ref_Y ;
    res = Ax*By - Bx*Ay;
end

always @(posedge clk , posedge reset) begin
    if(reset) now_state <= DATA_IN;
    else now_state <= nxt_state;
end

always @(*) begin
    case(now_state)
        DATA_IN:begin
            nxt_state = (data_count == 5)? SORT:DATA_IN;
        end
        SORT:begin
            nxt_state = DATA_SWAP;
        end
        DATA_SWAP:begin
            nxt_state = (sort_count == 4)? CAL_AREA6:SORT;
            // nxt_state = FINISH;
        end
        CAL_AREA6:begin
            nxt_state = CAL_AREA6_WR;
        end
        CAL_AREA6_WR:begin
            nxt_state = (edge_count == 5)? CAL_EDGE : CAL_AREA6;
        end
        CAL_EDGE:begin
            nxt_state = CAL_EDGE_WR;
        end
        CAL_EDGE_WR:begin
            nxt_state = (edge7_count == 5)? CAL_AREA7:CAL_EDGE;
        end
        CAL_AREA7:begin
            nxt_state = CAL_AREA7_WR;
        end
        CAL_AREA7_WR:begin
            nxt_state = (aera7_count== 5)? FINISH:CAL_AREA7;
        end
        FINISH:begin
            nxt_state = DATA_IN;
        end
        default:begin
        end
    endcase
end

always @(posedge clk , posedge reset) begin
    if(reset)begin
        for(i=0;i<6;i=i+1)begin
            data_X[i] <= 0;
            data_Y[i] <= 0;
            data_R[i] <= 0;
            edge_D[i] <= 0;
        end
        data_count <= 0;
        sort_count <= 0;
        edge_count <= 0;
        edge7_count <= 0;
        aera7_count <= 0;
        //is_inside <= 0;
        a <= 0;
        b <= 0;
        c <= 0;
        ref_X <= 0;
        ref_Y <= 0;
        d1_X <= 0;
        d1_Y <= 0;
        d2_X <= 0;
        d2_Y <= 0;
        ref_X <= 0;
        ref_Y <= 0;
        area6edge <= 0;
        area7edge <= 0;
        edge7res <= 0;
        dis_x1 <= 0;
        dis_y1 <= 0;
        dis_x2 <= 0;
        dis_y2 <= 0;
        sqrt1_res_pip <= 0;
    end
    else begin
        case(now_state)
            DATA_IN:begin
                data_count <= data_count + 1;
                data_X[data_count] <= X;
                data_Y[data_count] <= Y;
                data_R[data_count] <= R;
            end
            SORT:begin
                ref_X <= {1'b0,data_X[0]};
                ref_Y <= {1'b0,data_Y[0]};
                d1_X <=  {1'b0,data_X[sort_count+1]};
                d1_Y <=  {1'b0,data_Y[sort_count+1]};
                d2_X <= (sort_count == 4)? {1'b0,data_X[1]}: {1'b0,data_X[sort_count+2]};
                d2_Y <= (sort_count == 4)? {1'b0,data_Y[1]}: {1'b0,data_Y[sort_count+2]};
            end
            DATA_SWAP:begin
                if(sort_count < 4)begin
                    if(res[21])begin
                        data_X[sort_count+1] <= data_X[sort_count+2];
                        data_Y[sort_count+1] <= data_Y[sort_count+2];
                        data_R[sort_count+1] <= data_R[sort_count+2];
                        data_X[sort_count+2] <= data_X[sort_count+1];
                        data_Y[sort_count+2] <= data_Y[sort_count+1];
                        data_R[sort_count+2] <= data_R[sort_count+1];
                        sort_count <= 0;
                    end
                    else begin
                        sort_count <= sort_count + 1;
                    end
                end
                else begin
                    if(~res[21])begin
                        data_X[sort_count+1] <= data_X[1];
                        data_Y[sort_count+1] <= data_Y[1];
                        data_R[sort_count+1] <= data_R[1];
                        data_X[1] <= data_X[sort_count+1];
                        data_Y[1] <= data_Y[sort_count+1];
                        data_R[1] <= data_R[sort_count+1];
                        sort_count <= 0;
                    end
                    else begin
                        sort_count <= sort_count + 1;
                    end
                end
            end
            CAL_AREA6:begin
                ref_X <= 0;
                ref_Y <= 0;
                d1_X <= {1'b0,data_X[edge_count]};
                d1_Y <= {1'b0,data_Y[edge_count]};
                d2_X <= (edge_count == 5)? {1'b0,data_X[0]}:{1'b0,data_X[edge_count+1]};
                d2_Y <= (edge_count == 5)? {1'b0,data_Y[0]}:{1'b0,data_Y[edge_count+1]};
            end
            CAL_AREA6_WR:begin
                edge_count <= edge_count + 1;
                area6edge <= area6edge + (res>>>1);
            end
            CAL_EDGE:begin
                dis_x1 <= data_X[edge7_count];
                dis_y1 <= data_Y[edge7_count];
                dis_x2 <= (edge7_count == 5)? data_X[0]:data_X[edge7_count+1];
                dis_y2 <= (edge7_count == 5)? data_Y[0]:data_Y[edge7_count+1];
                sqrt1_res_pip <= sqrt1_res;
            end
            CAL_EDGE_WR:begin
                edge7_count <= edge7_count + 1;
                edge_D[edge7_count] <= sqrt1_res;
            end
            CAL_AREA7:begin
                //edge_D[5] <= sqrt1_res_pip;
                a <= data_R[aera7_count];
                b <= (aera7_count == 5)? data_R[0]:data_R[aera7_count+1];
                c <= edge_D[aera7_count];
            end
            CAL_AREA7_WR:begin
                aera7_count <= aera7_count + 1;
                area7edge <= area7edge + area;
            end
            FINISH:begin
                aera7_count <= 0;
                data_count <= 0;
                sort_count <= 0;
                edge_count <= 0;
                edge7_count <= 0;
                area6edge <= 0;
                area7edge <= 0;
                dis_x1 <= 0;
                dis_y1 <= 0;
                dis_x2 <= 0;
                dis_y2 <= 0;
                for(i=0;i<6;i=i+1)begin
                    data_X[i] <= 0;
                    data_Y[i] <= 0;
                    data_R[i] <= 0;
                    edge_D[i] <= 0;
                end
                //is_inside <= (area7edge + area6edge < 0)? 1:0;
            end
            default:begin
            end
        endcase
    end
end

endmodule
