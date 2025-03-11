module JAM (
input CLK,
input RST,
output [2:0] W,
output [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg Valid );

localparam CAL_COST = 0;
localparam FINISH = 1;

reg [2:0]now_state,nxt_state;
reg [2:0]data[0:7];
reg [3:0]cost_count;
reg [9:0]sum;

reg [2:0]change_spot,bigger_spot;
reg NONE;

integer i;

assign J = data[W];
assign W = (cost_count <= 7)? cost_count:0;
//assign sum = cost_data[0] + cost_data[1] + cost_data[2] + cost_data[3] + cost_data[4] + cost_data[5] + cost_data[6] + cost_data[7];

always @(posedge CLK , posedge RST) begin
    if(RST)now_state = CAL_COST;
    else now_state = nxt_state;
end

always @(*) begin
    case(now_state)
        CAL_COST:begin
            nxt_state = (NONE)? FINISH:CAL_COST;
        end
        FINISH:begin
            nxt_state = CAL_COST;
        end
        default:begin
            nxt_state = CAL_COST;
        end
    endcase
end

always @(posedge CLK , posedge RST) begin
    if(RST)begin
        //W <= 3'b0;
        Valid <= 1'b0;
        cost_count <= 0;
        MatchCount <= 0;
        MinCost <= 10'd1023;
        for(i=0;i<8;i=i+1)begin
            data[i] <= i;
        end
    end
    else begin
        case(now_state)
            CAL_COST:begin
                if(cost_count <= 7)begin
                    cost_count <= cost_count + 1;
                    //W <=cost_count;
                end
                else if(cost_count == 8)begin
                    //W <= W;
                    MinCost <= (MinCost > sum+Cost)? sum+Cost:MinCost;
                    cost_count <= cost_count + 1;
                    MatchCount <= (sum+Cost == MinCost)? MatchCount+1:(MinCost > sum+Cost)? 1:MatchCount;
                            
                    data[bigger_spot] <= data[change_spot];
                    data[change_spot] <= data[bigger_spot];
                end
                else begin
                    cost_count <= 0;
                    case(change_spot)
                        5:begin
                            data[6] <= data[7];
                            data[7] <= data[6];   
                        end
                        4:begin
                            data[5] <= data[7];
                            data[7] <= data[5];   
                        end
                        3:begin
                            data[4] <= data[7];
                            data[7] <= data[4];
                            data[5] <= data[6];
                            data[6] <= data[5];   
                        end
                        2:begin
                            data[3] <= data[7];
                            data[7] <= data[3];
                            data[4] <= data[6];
                            data[6] <= data[4];   
                        end
                        1:begin
                            data[2] <= data[7];
                            data[7] <= data[2];
                            data[3] <= data[6];
                            data[6] <= data[3];
                            data[4] <= data[5];
                            data[5] <= data[4];  
                        end
                        0:begin
                            data[1] <= data[7];
                            data[7] <= data[1];
                            data[2] <= data[6];
                            data[6] <= data[2];
                            data[3] <= data[5];
                            data[5] <= data[3];  
                        end
                        default:begin
                        end
                    endcase
                end
            end
            FINISH:begin
                Valid <= 1'b1;
            end
            default:begin
            end
        endcase
    end
end

always @(posedge CLK , posedge RST) begin
    if(RST)begin
        sum <= 0;
    end
    else begin
        if(cost_count>0)begin
            sum <= sum + Cost;
        end
        else begin
            sum <= 0;
        end
    end
end

always@(*)begin
    if(cost_count < 8)begin
        if(data[7] > data[6])begin
            change_spot = 6;
            bigger_spot = 7;
            NONE = 0;
        end
        else if(data[6] > data[5])begin
            change_spot = 5;
            bigger_spot = (data[7] > data[5] && data[7] < data[6])? 7:6;
            NONE = 0;
        end
        else if(data[5] > data[4])begin
            change_spot = 4;
            bigger_spot = (data[7] > data[4] && data[7] < data[5])? 7:
                            (data[6] > data[4] && data[6] < data[5])? 6:5;
            NONE = 0;
        end
        else if(data[4] > data[3])begin
            change_spot = 3;
            bigger_spot = (data[7] > data[3] && data[7] < data[4])? 7:
                            (data[6] > data[3] && data[6] < data[4])? 6:
                            (data[5] > data[3] && data[5] < data[4])? 5:4;
            NONE = 0;
        end
        else if(data[3] > data[2])begin
            change_spot = 2;
            bigger_spot = (data[7] > data[2] && data[7] < data[3])? 7:
                            (data[6] > data[2] && data[6] < data[3])? 6:
                            (data[5] > data[2] && data[5] < data[3])? 5:
                            (data[4] > data[2] && data[4] < data[3])? 4:3;
            NONE = 0;
        end
        else if(data[2] > data[1])begin
            change_spot = 1;
            bigger_spot = (data[7] > data[1] && data[7] < data[2])? 7:
                            (data[6] > data[1] && data[6] < data[2])? 6:
                            (data[5] > data[1] && data[5] < data[2])? 5:
                            (data[4] > data[1] && data[4] < data[2])? 4:
                            (data[3] > data[1] && data[3] < data[2])? 3:2;
            NONE = 0;
        end
        else if(data[1] > data[0])begin
            change_spot = 0;
            bigger_spot = (data[7] > data[0] && data[7] < data[1])? 7:
                            (data[6] > data[0] && data[6] < data[1])? 6:
                            (data[5] > data[0] && data[5] < data[1])? 5:
                            (data[4] > data[0] && data[4] < data[1])? 4:
                            (data[3] > data[0] && data[3] < data[1])? 3:
                            (data[2] > data[0] && data[2] < data[1])? 2:1;
            NONE = 0;
        end
        else begin
            change_spot = 0;
            bigger_spot =0;
            NONE = 1;
        end
    end
    else begin
    end
end

endmodule

