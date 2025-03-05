module huffman(clk, reset, gray_valid,gray_data, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,
    code_valid, HC1, HC2, HC3, HC4, HC5, HC6,M1, M2, M3, M4, M5, M6);

input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output CNT_valid;
output reg [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output code_valid;
output reg [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output reg [7:0] M1, M2, M3, M4, M5, M6;

reg [7:0]sort_data[0:5];
reg [7:0]sort_symbol[0:5];

reg [7:0]C1_data[0:4];
reg [7:0]C1_symbol[0:4];
reg [7:0]C1_merge_symbol[0:1];

reg [7:0]C2_data[0:3];
reg [7:0]C2_symbol[0:3];
reg [7:0]C2_merge_symbol[0:2];

reg [7:0]C3_data[0:2];
reg [7:0]C3_symbol[0:2];
reg [7:0]C3_merge_symbol[0:3];

reg [7:0]C4_data[0:1];
reg [7:0]C4_symbol[0:1];
reg [7:0]C4_merge_symbol[0:4];

reg [2:0]sort_count;
reg [2:0]C1_sort_count,C2_sort_count,C3_sort_count;

reg [3:0]dot_10,dot_9,dot_8,dot_7;

localparam INIT = 5'b00000;
localparam DATA_IN = 5'b00001;
localparam DATA_INIT = 5'b00010;
localparam DATA_C1 = 5'b00011;
localparam DATA_C1_SORT = 5'b00100;
localparam DATA_C2 = 5'b00101;
localparam DATA_C2_SORT = 5'b00110;
localparam DATA_C3 = 5'b00111;
localparam DATA_C3_SORT = 5'b01000;
localparam DATA_C4 = 5'b01001;
localparam DATA_C4_SORT = 5'b01010;
localparam SPLT_C4 = 5'b01011;
localparam SPLT_C3 = 5'b01100;
localparam SPLT_C2 = 5'b01101;
localparam SPLT_C1 = 5'b01110;
localparam RES = 5'b10000;
localparam RES_OUT = 5'b01111;

parameter A1 = 8'd1;
parameter A2 = 8'd2;
parameter A3 = 8'd3;
parameter A4 = 8'd4;
parameter A5 = 8'd5;
parameter A6 = 8'd6;

parameter C1 = 8'd7;
parameter C2 = 8'd8;
parameter C3 = 8'd9;
parameter C4 = 8'd10;

reg [4:0]now_state,nxt_state;
reg [5:0]valid;
reg [7:0]bit_valid;

assign code_valid = (now_state == RES_OUT);
assign CNT_valid = (now_state == RES_OUT);

always @(posedge clk  , posedge reset) begin
    if(reset)begin
        now_state <= INIT;
    end
    else begin
        now_state <= nxt_state;
    end
end

always @(*) begin
    case(now_state)
        INIT:begin
            if(gray_valid)begin
                nxt_state = DATA_IN;
            end
            else begin
                nxt_state = INIT;
            end
        end
        DATA_IN:begin
            nxt_state = (gray_valid)? DATA_IN:DATA_INIT;
        end
        DATA_INIT:begin
            nxt_state = (sort_count == 3'd6)? DATA_C1:DATA_INIT;
        end
        DATA_C1:begin
            nxt_state = DATA_C1_SORT;
        end
        DATA_C1_SORT:begin
            nxt_state = (C1_sort_count == 5)? DATA_C2:DATA_C1_SORT;
        end
        DATA_C2:begin
            nxt_state = DATA_C2_SORT;
        end
        DATA_C2_SORT:begin
            nxt_state = (C2_sort_count == 4)? DATA_C3:DATA_C2_SORT;
        end
        DATA_C3:begin
            nxt_state = DATA_C3_SORT;
        end
        DATA_C3_SORT:begin
            nxt_state = (C3_sort_count == 3)? DATA_C4:DATA_C3_SORT;
        end
        DATA_C4:begin
            nxt_state = DATA_C4_SORT;
        end
        DATA_C4_SORT:begin
            nxt_state = SPLT_C4;
        end
        SPLT_C4:begin
            nxt_state = SPLT_C3;
        end
        SPLT_C3:begin
            nxt_state = SPLT_C2;
        end
        SPLT_C2:begin
            nxt_state = SPLT_C1;
        end
        SPLT_C1:begin
            nxt_state = RES;
        end
        RES:begin
            nxt_state = RES_OUT;
        end
        RES_OUT:begin
            nxt_state = INIT;
        end
    endcase
end
// INIT
always @(posedge clk , posedge reset) begin
    if(reset)begin
        sort_data[0] <= 8'b0;
        sort_data[1] <= 8'b0;
        sort_data[2] <= 8'b0;
        sort_data[3] <= 8'b0;
        sort_data[4] <= 8'b0;
        sort_data[5] <= 8'b0;

        sort_symbol[0] <= A1;
        sort_symbol[1] <= A2;
        sort_symbol[2] <= A3;
        sort_symbol[3] <= A4;
        sort_symbol[4] <= A5;
        sort_symbol[5] <= A6;

        sort_count <= 3'b000;
    end
    else begin
        case (now_state)
            DATA_IN :begin
                sort_data[0] <= CNT1;
                sort_data[1] <= CNT2;
                sort_data[2] <= CNT3;
                sort_data[3] <= CNT4;
                sort_data[4] <= CNT5;
                sort_data[5] <= CNT6;
            end
            DATA_INIT:begin
                sort_count <= sort_count + 1;
                if(sort_count[0])begin
                    if(sort_data[1] < sort_data[2])begin
                        sort_data[1] <= sort_data[2];
                        sort_data[2] <= sort_data[1];
                        sort_symbol[1] <= sort_symbol[2];
                        sort_symbol[2] <= sort_symbol[1];
                    end
                    else begin
                    end
                    if(sort_data[3] < sort_data[4])begin
                        sort_data[3] <= sort_data[4];
                        sort_data[4] <= sort_data[3];
                        sort_symbol[3] <= sort_symbol[4];
                        sort_symbol[4] <= sort_symbol[3];
                    end
                    else begin
                    end
                end
                else begin
                    if(sort_data[0] < sort_data[1])begin
                        sort_data[0] <= sort_data[1];
                        sort_data[1] <= sort_data[0];
                        sort_symbol[0] <= sort_symbol[1];
                        sort_symbol[1] <= sort_symbol[0];
                    end
                    else begin
                    end
                    if(sort_data[2] < sort_data[3])begin
                        sort_data[2] <= sort_data[3];
                        sort_data[3] <= sort_data[2];
                        sort_symbol[2] <= sort_symbol[3];
                        sort_symbol[3] <= sort_symbol[2];
                    end
                    else begin
                    end
                    if(sort_data[4] < sort_data[5])begin
                        sort_data[4] <= sort_data[5];
                        sort_data[5] <= sort_data[4];
                        sort_symbol[4] <= sort_symbol[5];
                        sort_symbol[5] <= sort_symbol[4];
                    end
                    else begin
                    end
                end
            end
            default:begin
            end
        endcase
    end
end
// C1
always @(posedge clk , posedge reset) begin
    if(reset)begin
        C1_data[0] <= 8'b0;
        C1_data[1] <= 8'b0;
        C1_data[2] <= 8'b0;
        C1_data[3] <= 8'b0;
        C1_data[4] <= 8'b0;

        C1_symbol[0] <= 8'b0;
        C1_symbol[1] <= 8'b0;
        C1_symbol[2] <= 8'b0;
        C1_symbol[3] <= 8'b0;
        C1_symbol[4] <= 8'b0;

        C1_merge_symbol[0] <= 8'b0;
        C1_merge_symbol[1] <= 8'b0;

        C1_sort_count <= 3'd0;
    end
    else begin
        case (now_state)
            DATA_C1:begin
                C1_data[0] <= sort_data[0];
                C1_data[1] <= sort_data[1];
                C1_data[2] <= sort_data[2];
                C1_data[3] <= sort_data[3];
                C1_data[4] <= sort_data[4] + sort_data[5];

                C1_symbol[0] <= sort_symbol[0];
                C1_symbol[1] <= sort_symbol[1];
                C1_symbol[2] <= sort_symbol[2];
                C1_symbol[3] <= sort_symbol[3];
                C1_symbol[4] <= C1;

                C1_merge_symbol[0] <= sort_symbol[4];
                C1_merge_symbol[1] <= sort_symbol[5];
            end
            DATA_C1_SORT:begin
                C1_sort_count <= C1_sort_count + 1;
                if(C1_sort_count[0])begin
                    if(C1_data[1] < C1_data[2])begin
                        C1_data[1] <= C1_data[2];
                        C1_data[2] <= C1_data[1];
                        C1_symbol[1] <= C1_symbol[2];
                        C1_symbol[2] <= C1_symbol[1];
                    end
                    else begin
                    end
                    if(C1_data[3] < C1_data[4])begin
                        C1_data[3] <= C1_data[4];
                        C1_data[4] <= C1_data[3];
                        C1_symbol[3] <= C1_symbol[4];
                        C1_symbol[4] <= C1_symbol[3];
                    end
                    else begin
                    end
                end
                else begin
                    if(C1_data[0] < C1_data[1])begin
                        C1_data[0] <= C1_data[1];
                        C1_data[1] <= C1_data[0];
                        C1_symbol[0] <= C1_symbol[1];
                        C1_symbol[1] <= C1_symbol[0];
                    end
                    else begin
                    end
                    if(C1_data[2] < C1_data[3])begin
                        C1_data[2] <= C1_data[3];
                        C1_data[3] <= C1_data[2];
                        C1_symbol[2] <= C1_symbol[3];
                        C1_symbol[3] <= C1_symbol[2];
                    end
                    else begin
                    end
                end
            end
            default:begin
            end 
        endcase
    end
end
// C2
always @(posedge clk , posedge reset) begin
    if(reset)begin
        C2_data[0] <= 8'b0;
        C2_data[1] <= 8'b0;
        C2_data[2] <= 8'b0;
        C2_data[3] <= 8'b0;

        C2_symbol[0] <= 8'b0;
        C2_symbol[1] <= 8'b0;
        C2_symbol[2] <= 8'b0;
        C2_symbol[3] <= 8'b0;

        C2_merge_symbol[0] <= 8'b0;
        C2_merge_symbol[1] <= 8'b0;
        C2_merge_symbol[2] <= 8'b0;

        C2_sort_count <= 3'd0;
    end
    else begin
        case (now_state)
            DATA_C2:begin
                C2_data[0] <= C1_data[0];
                C2_data[1] <= C1_data[1];
                C2_data[2] <= C1_data[2];
                C2_data[3] <= C1_data[3] + C1_data[4];

                C2_symbol[0] <= C1_symbol[0];
                C2_symbol[1] <= C1_symbol[1];
                C2_symbol[2] <= C1_symbol[2];
                C2_symbol[3] <= C2;

                C2_merge_symbol[2] <= C1_merge_symbol[1];
                C2_merge_symbol[1] <= C1_merge_symbol[0];
                C2_merge_symbol[0] <= C1_symbol[3];
            end
            DATA_C2_SORT:begin
                C2_sort_count <= C2_sort_count + 1;
                if(C2_sort_count[0])begin
                    if(C2_data[0] < C2_data[1])begin
                        C2_data[0] <= C2_data[1];
                        C2_data[1] <= C2_data[0];
                        C2_symbol[0] <= C2_symbol[1];
                        C2_symbol[1] <= C2_symbol[0];
                    end
                    else begin
                    end
                    if(C2_data[2] < C2_data[3])begin
                        C2_data[2] <= C2_data[3];
                        C2_data[3] <= C2_data[2];
                        C2_symbol[2] <= C2_symbol[3];
                        C2_symbol[3] <= C2_symbol[2];
                    end
                    else begin
                    end
                end
                else begin
                    if(C2_data[1] < C2_data[2])begin
                        C2_data[1] <= C2_data[2];
                        C2_data[2] <= C2_data[1];
                        C2_symbol[1] <= C2_symbol[2];
                        C2_symbol[2] <= C2_symbol[1];
                    end
                    else begin
                    end
                end
            end
            default:begin
            end
        endcase
    end
end
// C3
always @(posedge clk , posedge reset) begin
    if(reset)begin
        C3_data[0] <= 8'b0;
        C3_data[1] <= 8'b0;
        C3_data[2] <= 8'b0;
        
        C3_symbol[0] <= 8'b0;
        C3_symbol[1] <= 8'b0;
        C3_symbol[2] <= 8'b0;

        C3_merge_symbol[0] <= 8'b0;
        C3_merge_symbol[1] <= 8'b0;
        C3_merge_symbol[2] <= 8'b0;
        C3_merge_symbol[3] <= 8'b0;

        C3_sort_count <= 3'd0;
    end
    else begin
        case (now_state)
            DATA_C3:begin
                C3_data[0] <= C2_data[0];
                C3_data[1] <= C2_data[1];
                C3_data[2] <= C2_data[2] + C2_data[3];

                C3_symbol[0] <= C2_symbol[0];
                C3_symbol[1] <= C2_symbol[1];
                C3_symbol[2] <= C3;

                C3_merge_symbol[3] <= C2_merge_symbol[2];
                C3_merge_symbol[2] <= C2_merge_symbol[1];
                C3_merge_symbol[1] <= C2_merge_symbol[0];
                C3_merge_symbol[0] <= C2_symbol[3];
            end
            DATA_C3_SORT:begin
                C3_sort_count <= C3_sort_count + 1;
                if(C3_sort_count[0])begin
                    if(C3_data[0] < C3_data[1])begin
                        C3_data[0] <= C3_data[1];
                        C3_data[1] <= C3_data[0];
                        C3_symbol[0] <= C3_symbol[1];
                        C3_symbol[1] <= C3_symbol[0];
                    end
                    else begin
                    end
                end
                else begin
                    if(C3_data[1] < C3_data[2])begin
                        C3_data[1] <= C3_data[2];
                        C3_data[2] <= C3_data[1];
                        C3_symbol[1] <= C3_symbol[2];
                        C3_symbol[2] <= C3_symbol[1];
                    end
                    else begin
                    end
                end
            end
            default:begin
            end 
        endcase
    end
end
// C4
always @(posedge clk , posedge reset) begin
    if(reset)begin
        C4_data[0] <= 8'b0;
        C4_data[1] <= 8'b0;

        C4_symbol[0] <= 8'b0;
        C4_symbol[1] <= 8'b0;

        C4_merge_symbol[0] <= 8'b0;
        C4_merge_symbol[1] <= 8'b0;
        C4_merge_symbol[2] <= 8'b0;
        C4_merge_symbol[3] <= 8'b0;
        C4_merge_symbol[4] <= 8'b0;
    end
    else begin
        case (now_state)
            DATA_C4:begin
                C4_data[0] <= C3_data[0];
                C4_data[1] <= C3_data[1] + C3_data[2];

                C4_symbol[0] <= C3_symbol[0];
                C4_symbol[1] <= C4;

                C4_merge_symbol[4] <= C3_merge_symbol[3];
                C4_merge_symbol[3] <= C3_merge_symbol[2];
                C4_merge_symbol[2] <= C3_merge_symbol[1];
                C4_merge_symbol[1] <= C3_merge_symbol[0];
                C4_merge_symbol[0] <= C3_symbol[2];
            end
            DATA_C4_SORT:begin
                if(C4_data[0] < C4_data[1])begin
                    C4_data[0] <= C4_data[1];
                    C4_data[1] <= C4_data[0];
                    C4_symbol[0] <= C4_symbol[1];
                    C4_symbol[1] <= C4_symbol[0];
                end
                else begin
                end
            end
            default:begin
            end
        endcase
    end
end
// HC & M
always @(posedge clk , posedge reset) begin
    if(reset)begin
        HC1 <= 8'b0;
        HC2 <= 8'b0;
        HC3 <= 8'b0;
        HC4 <= 8'b0;
        HC5 <= 8'b0;
        HC6 <= 8'b0;

        dot_10 <= 4'd0;
        dot_9 <= 4'd0;
        dot_8 <= 4'd0;
        dot_7 <= 4'd0;

        M1 <= 8'b0;
        M2 <= 8'b0;
        M3 <= 8'b0;
        M4 <= 8'b0;
        M5 <= 8'b0;
        M6 <= 8'b0;

        valid <= 6'b111111;
        bit_valid <= 8'b00000001;
    end
    else begin
        case(now_state)
            SPLT_C4:begin
                case (C4_symbol[0])
                    1: begin
                        HC1 <= (valid)? 0:HC1;
                        M1 <= 8'b00000001;
                        valid[0] <= 1'b0;
                    end
                    2:begin
                        HC2 <= (valid)? 0:HC2;
                        valid[1] <= 1'b0;
                        M2 <= 8'b00000001;
                    end
                    3:begin
                        HC3 <= (valid)? 0:HC3;
                        valid[2] <= 1'b0;
                        M3 <= 8'b00000001;
                    end
                    4:begin
                        HC4 <= (valid)? 0:HC4;
                        valid[3] <= 1'b0;
                        M4 <= 8'b00000001;
                    end
                    5:begin
                        HC5 <= (valid)? 0:HC5;
                        valid[4] <= 1'b0;
                        M5 <= 8'b00000001;
                    end
                    6:begin
                        HC6 <= (valid)? 0:HC6;
                        valid[5] <= 1'b0;
                        M6 <= 8'b00000001;
                    end
                    7:begin
                        dot_7 <= {dot_7 , 1'b0};
                        bit_valid <= {bit_valid , 1'b1};
                    end
                    8:begin
                        dot_8 <= {dot_8 , 1'b0};
                        bit_valid <= {bit_valid , 1'b1};
                    end
                    9:begin
                        dot_9 <= {dot_9 , 1'b0};
                        bit_valid <= {bit_valid , 1'b1};
                    end
                    default:begin
                        dot_10 <= {dot_10 , 1'b0};
                        bit_valid <= {bit_valid , 1'b1};
                    end
                endcase

                case (C4_symbol[1])
                    1: begin
                        HC1 <= (valid)? 1:HC1;
                        valid[0] <= 1'b0;
                        M1 <= 8'b0000001;
                    end
                    2:begin
                        HC2 <= (valid)? 1:HC2;
                        valid[1] <= 1'b0;
                        M2 <= 8'b0000001;
                    end
                    3:begin
                        HC3 <= (valid)? 1:HC3;
                        valid[2] <= 1'b0;
                        M3 <= 8'b0000001;
                    end
                    4:begin
                        HC4 <= (valid)? 1:HC4;
                        valid[3] <= 1'b0;
                        M4 <= 8'b0000001;
                    end
                    5:begin
                        HC5 <= (valid)? 1:HC5;
                        valid[4] <= 1'b0;
                        M5 <= 8'b0000001;
                    end
                    6:begin
                        HC6 <= (valid)? 1:HC6;
                        valid[5] <= 1'b0;
                        M6 <= 8'b0000001;
                    end
                    7:begin
                        dot_7 <= {dot_7 , 1'b1};
                        bit_valid <= {bit_valid , 1'b1};
                    end
                    8:begin
                        dot_8 <= {dot_8 , 1'b1};
                        bit_valid <= {bit_valid , 1'b1};
                    end
                    9:begin
                        dot_9 <= {dot_9 , 1'b1};
                        bit_valid <= {bit_valid , 1'b1};
                    end
                    default:begin
                        dot_10 <= {dot_10 , 1'b1};
                        bit_valid <= {bit_valid , 1'b1};
                    end
                endcase
            end
            SPLT_C3:begin
                case (C3_symbol[1])
                    1:begin
                        HC1 <= (valid[0])? {dot_10,1'b0}:HC1;
                        M1 <= 8'b00000011;
                        valid[0] <= 1'b0;
                    end
                    2:begin
                        HC2 <= (valid[1])? {dot_10,1'b0}:HC2;
                        valid[1] <= 1'b0;
                        M2 <= 8'b00000011;
                    end
                    3:begin
                        HC3 <= (valid[2])? {dot_10,1'b0}:HC3;
                        valid[2] <= 1'b0;
                        M3 <= 8'b00000011;
                    end
                    4:begin
                        HC4 <= (valid[3])? {dot_10,1'b0}:HC4;
                        valid[3] <= 1'b0;
                        M4 <= 8'b00000011;
                    end
                    5:begin
                        HC5 <= (valid[4])? {dot_10,1'b0}:HC5;
                        valid[4] <= 1'b0;
                        M5 <= 8'b00000011;
                    end
                    6:begin
                        HC6 <= (valid[5])? {dot_10,1'b0}:HC6;
                        valid[5] <= 1'b0;
                        M6 <= 8'b00000011;
                    end
                    7:begin
                        dot_7 <= {dot_10 , 1'b0};
                    end
                    8:begin
                        dot_8 <= {dot_10 , 1'b0};
                    end
                    9:begin
                        dot_9 <= {dot_10 , 1'b0};
                    end 
                    default:begin
                    end
                endcase
                case (C3_symbol[2])
                    1:begin
                        HC1 <= (valid[0])? {dot_10,1'b1}:HC1;
                        valid[0] <= 1'b0;
                        M1 <= 8'b00000011;
                    end
                    2:begin
                        HC2 <= (valid[1])? {dot_10,1'b1}:HC2;
                        valid[1] <= 1'b0;
                        M2 <= 8'b00000011;
                    end
                    3:begin
                        HC3 <= (valid[2])? {dot_10,1'b1}:HC3;
                        valid[2] <= 1'b0;
                        M3 <= 8'b00000011;
                    end
                    4:begin
                        HC4 <= (valid[3])? {dot_10,1'b1}:HC4;
                        valid[3] <= 1'b0;
                        M4 <= 8'b00000011;
                    end
                    5:begin
                        HC5 <= (valid[4])? {dot_10,1'b1}:HC5;
                        valid[4] <= 1'b0;
                        M5 <= 8'b00000011;
                    end
                    6:begin
                        HC6 <= (valid[5])? {dot_10,1'b1}:HC6;
                        valid[5] <= 1'b0;
                        M6 <= 8'b00000011;
                    end
                    7:begin
                        dot_7 <= {dot_10 , 1'b1};
                    end
                    8:begin
                        dot_8 <= {dot_10 , 1'b1};
                    end
                    9:begin
                        dot_9 <= {dot_10 , 1'b1};
                    end 
                    default:begin
                    end
                endcase
            end
            SPLT_C2:begin
                case (C2_symbol[2])
                    1:begin
                        HC1 <= (valid[0])? {dot_9,1'b0}:HC1;
                        valid[0] <= 1'b0;
                        M1 <= {bit_valid , 1'b1};
                    end
                    2:begin
                        HC2 <= (valid[1])? {dot_9,1'b0}:HC2;
                        valid[1] <= 1'b0;
                        M2 <= {bit_valid , 1'b1};
                    end
                    3:begin
                        HC3 <= (valid[2])? {dot_9,1'b0}:HC3;
                        valid[2] <= 1'b0;
                        M3 <= {bit_valid , 1'b1};
                    end
                    4:begin
                        HC4 <= (valid[3])? {dot_9,1'b0}:HC4;
                        valid[3] <= 1'b0;
                        M4 <= {bit_valid , 1'b1};
                    end
                    5:begin
                        HC5 <= (valid[4])? {dot_9,1'b0}:HC5;
                        valid[4] <= 1'b0;
                        M5 <= {bit_valid , 1'b1};
                    end
                    6:begin
                        HC6 <= (valid[5])? {dot_9,1'b0}:HC6;
                        valid[5] <= 1'b0;
                        M6 <= {bit_valid , 1'b1};
                    end
                    7:begin
                        dot_7 <= {dot_9 , 1'b0};
                        bit_valid <= {bit_valid , 1'b1};
                    end
                    8:begin
                        dot_8 <= {dot_9 , 1'b0};
                        bit_valid <= {bit_valid , 1'b1};
                    end
                    default:begin
                    end
                endcase
                case (C2_symbol[3])
                    1:begin
                        HC1 <= (valid[0])? {dot_9,1'b1}:HC1;
                        valid[0] <= 1'b0;
                        M1 <= {bit_valid , 1'b1};
                    end
                    2:begin
                        HC2 <= (valid[1])? {dot_9,1'b1}:HC2;
                        valid[1] <= 1'b0;
                        M2 <= {bit_valid , 1'b1};
                    end
                    3:begin
                        HC3 <= (valid[2])? {dot_9,1'b1}:HC3;
                        valid[2] <= 1'b0;
                        M3 <= {bit_valid , 1'b1};
                    end
                    4:begin
                        HC4 <= (valid[3])? {dot_9,1'b1}:HC4;
                        valid[3] <= 1'b0;
                        M4 <= {bit_valid , 1'b1};
                    end
                    5:begin
                        HC5 <= (valid[4])? {dot_9,1'b1}:HC5;
                        valid[4] <= 1'b0;
                        M5 <= {bit_valid , 1'b1};
                    end
                    6:begin
                        HC6 <= (valid[5])? {dot_9,1'b1}:HC6;
                        valid[5] <= 1'b0;
                        M6 <= {bit_valid , 1'b1};
                    end
                    7:begin
                        dot_7 <= {dot_9, 1'b1};
                        bit_valid <= {bit_valid , 1'b1};
                    end
                    8:begin
                        dot_8 <= {dot_9, 1'b1};
                        bit_valid <= {bit_valid , 1'b1};
                    end
                    default:begin
                        bit_valid <= {bit_valid , 1'b1};
                    end
                endcase
            end
            SPLT_C1:begin
                case (C1_symbol[3])
                    1:begin
                        HC1 <= (valid[0])? {dot_8,1'b0}:HC1;
                        M1 <={bit_valid , 1'b1};
                        valid[0] <= 1'b0;
                    end
                    2:begin
                        HC2 <= (valid[1])? {dot_8,1'b0}:HC2;
                        valid[1] <= 1'b0;
                        M2 <= {bit_valid , 1'b1};
                    end
                    3:begin
                        HC3 <= (valid[2])? {dot_8,1'b0}:HC3;
                        valid[2] <= 1'b0;
                        M3 <= {bit_valid , 1'b1};
                    end
                    4:begin
                        HC4 <= (valid[3])? {dot_8,1'b0}:HC4;
                        valid[3] <= 1'b0;
                        M4 <= {bit_valid , 1'b1};
                    end
                    5:begin
                        HC5 <= (valid[4])? {dot_8,1'b0}:HC5;
                        valid[4] <= 1'b0;
                        M5 <= {bit_valid , 1'b1};
                    end
                    6:begin
                        HC6 <= (valid[5])? {dot_8,1'b0}:HC6;
                        valid[5] <= 1'b0;
                        M6 <= {bit_valid , 1'b1};
                    end
                    7:begin
                        dot_7 <= {dot_8 , 1'b0};
                        bit_valid <= {bit_valid , 1'b1};
                    end
                    default:begin
                        bit_valid <= {bit_valid , 1'b1};
                    end
                endcase
                case (C1_symbol[4])
                    1:begin
                        HC1 <= (valid[0])? {dot_8,1'b1}:HC1;
                        valid[0] <= 1'b0;
                        M1 <= {bit_valid , 1'b1};
                    end
                    2:begin
                        HC2 <= (valid[1])? {dot_8,1'b1}:HC2;
                        valid[1] <= 1'b0;
                        M2 <= {bit_valid , 1'b1};
                    end
                    3:begin
                        HC3 <= (valid[2])? {dot_8,1'b1}:HC3;
                        valid[2] <= 1'b0;
                        M3 <= {bit_valid , 1'b1};
                    end
                    4:begin
                        HC4 <= (valid[3])? {dot_8,1'b1}:HC4;
                        valid[3] <= 1'b0;
                        M4 <= {bit_valid , 1'b1};
                    end
                    5:begin
                        HC5 <= (valid[4])? {dot_8,1'b1}:HC5;
                        valid[4] <= 1'b0;
                        M5 <= {bit_valid , 1'b1};
                    end
                    6:begin
                        HC6 <= (valid[5])? {dot_8,1'b1}:HC6;
                        valid[5] <= 1'b0;
                        M6 <= {bit_valid , 1'b1};
                    end
                    7:begin
                        dot_7 <= {dot_8, 1'b1};
                        bit_valid <= {bit_valid , 1'b1};
                    end
                    default:begin
                        bit_valid <= {bit_valid , 1'b1};
                    end
                endcase
            end
            RES:begin
                case (sort_symbol[4])
                    1:begin
                        HC1 <= (valid[0])? {dot_7,1'b0}:HC1;
                        valid[0] <= 1'b0;
                        M1 <= {bit_valid , 1'b1};
                    end
                    2:begin
                        HC2 <= (valid[1])? {dot_7,1'b0}:HC2;
                        valid[1] <= 1'b0;
                        M2 <= {bit_valid , 1'b1};
                    end
                    3:begin
                        HC3 <= (valid[2])? {dot_7,1'b0}:HC3;
                        valid[2] <= 1'b0;
                        M3 <= {bit_valid , 1'b1};
                    end
                    4:begin
                        HC4 <= (valid[3])? {dot_7,1'b0}:HC4;
                        valid[3] <= 1'b0;
                        M4 <= {bit_valid , 1'b1};
                    end
                    5:begin
                        HC5 <= (valid[4])? {dot_7,1'b0}:HC5;
                        valid[4] <= 1'b0;
                        M5 <= {bit_valid , 1'b1};
                    end
                    6:begin
                        HC6 <= (valid[5])? {dot_7,1'b0}:HC6;
                        valid[5] <= 1'b0;
                        M6 <= {bit_valid , 1'b1};
                    end
                    default:begin
                    end
                endcase
                case (sort_symbol[5])
                    1:begin
                        HC1 <= (valid[0])? {dot_7,1'b1}:HC1;
                        valid[0] <= 1'b0;
                        M1 <= {bit_valid , 1'b1};
                    end
                    2:begin
                        HC2 <= (valid[1])? {dot_7,1'b1}:HC2;
                        valid[1] <= 1'b0;
                        M2 <= {bit_valid , 1'b1};
                    end
                    3:begin
                        HC3 <= (valid[2])? {dot_7,1'b1}:HC3;
                        valid[2] <= 1'b0;
                        M3 <= {bit_valid , 1'b1};
                    end
                    4:begin
                        HC4 <= (valid[3])? {dot_7,1'b1}:HC4;
                        valid[3] <= 1'b0;
                        M4 <= {bit_valid , 1'b1};
                    end
                    5:begin
                        HC5 <= (valid[4])? {dot_7,1'b1}:HC5;
                        valid[4] <= 1'b0;
                        M5 <= {bit_valid , 1'b1};
                    end
                    6:begin
                        HC6 <= (valid[5])? {dot_7,1'b1}:HC6;
                        valid[5] <= 1'b0;
                        M6 <= {bit_valid , 1'b1};
                    end
                    default:begin
                    end
                endcase
            end
        endcase
    end
end
// CNT
always @(posedge clk , posedge reset) begin
    if(reset)begin
        CNT1 <= 8'b0;
        CNT2 <= 8'b0;
        CNT3 <= 8'b0;
        CNT4 <= 8'b0;
        CNT5 <= 8'b0;
        CNT6 <= 8'b0;
    end
    else begin
        case(gray_data)
            8'd1:begin
                CNT1 <= (gray_valid)? CNT1 + 1:CNT1;
            end
            8'd2:begin
                CNT2 <= (gray_valid)? CNT2 + 1:CNT2;
            end
            8'd3:begin
                CNT3 <= (gray_valid)? CNT3 + 1:CNT3;
            end
            8'd4:begin
                CNT4 <= (gray_valid)? CNT4 + 1:CNT4;
            end
            8'd5:begin
                CNT5 <= (gray_valid)? CNT5 + 1:CNT5;
            end
            8'd6:begin
                CNT6 <= (gray_valid)? CNT6 + 1:CNT6;
            end
            default:begin
                CNT1 <= CNT1;
                CNT2 <= CNT2;
                CNT3 <= CNT3;
                CNT4 <= CNT4;
                CNT5 <= CNT5;
                CNT6 <= CNT6;
            end
        endcase
    end
end

endmodule

