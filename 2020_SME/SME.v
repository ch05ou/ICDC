module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
    input clk;
    input reset;
    input [7:0] chardata;
    input isstring;
    input ispattern;
    output reg match;
    output reg [4:0] match_index;
    output reg valid;
    // reg match;
    // reg [4:0] match_index;
    // reg valid;

    //localparam INIT = 0;
    localparam DATA_IN = 0;
    localparam COMP = 1;
    localparam FINISH = 15;

    parameter HAT = 8'h5E;
    parameter MONEY = 8'h24;
    parameter DOT = 8'h2E;
    parameter STAR = 8'h2A;

    integer i,j;

    reg [3:0]now_state,nxt_state;

    reg [7:0] str_data [0:31];
    reg [7:0] pat_data [0:7];

    reg [5:0] str_count,str_len,str_ptr;
    reg [4:0] pat_count,pat_len,correct_count,pat_ptr;

    wire [7:0] str = (str_ptr > 31)? 0:str_data[str_ptr];
    wire [7:0] pat = (pat_ptr >7)? 0:pat_data[pat_ptr];

    wire check = (pat == str);
    reg star_flag,bf_star;
    reg [3:0]star_loc;
    reg [3:0]star_count;

    always@(posedge clk or posedge reset)begin
        if(reset)begin
            now_state <= DATA_IN;
        end
        else begin
            now_state <= nxt_state;
        end
    end

    always@(*)begin
        case(now_state)
            DATA_IN:begin
                if(isstring || ispattern)begin
                    nxt_state = DATA_IN;
                end
                else begin
                    nxt_state = COMP;
                end
            end
            COMP:begin
                //nxt_state = FINISH;
                nxt_state = (pat_ptr == pat_len || str_ptr == str_len)? FINISH:COMP;
            end
            FINISH:begin
                nxt_state = DATA_IN;
            end
            default:begin
                nxt_state = FINISH;
            end
        endcase
    end

    always @(posedge clk , posedge reset) begin
        if(reset)begin
            for(i=0;i<32;i=i+1)begin
                str_data[i] <= 8'h20;
            end
            for(j=0;j<8;j=j+1)begin
                pat_data[j] <= 8'h20;
            end
            str_count <= 0;
            pat_count <= 0;
            //match <= 0;
            match_index <= 0;
            valid <= 0;
            pat_len <= 0;
            str_len <= 0;
            correct_count <= 0;
            str_ptr <= 0;
            pat_ptr <= 0;
            valid <= 0;
            star_flag <= 0;
            star_loc <= 0;
            star_count <= 0;
            match <= 0;
            bf_star <= 1;
        end
        else begin
            case(now_state)
                DATA_IN:begin
                    valid <= 0;
                    if(ispattern)begin
                        pat_count <= pat_count + 1;
                        pat_len <= pat_count +1;
                        pat_data[pat_count] <= chardata;
                        for(i=31;i>pat_count;i=i-1)begin
                            pat_data[i] <= 8'h20;
                        end
                    end
                    else if(isstring)begin
                        str_count <= str_count + 1;
                        str_len <= str_count +1;
                        str_data[str_count] <= chardata;
                        for(i=31;i>str_count;i=i-1)begin
                            str_data[i] <= 8'h20;
                        end
                    end
                end
                COMP:begin
                    match <= (correct_count+star_flag >= pat_len)? 1:0;
                    case (pat)
                        HAT:begin
                            if(str_ptr == 0 || str_data[str_ptr-1] == 8'h20)begin
                                match_index <= str_ptr;
                                pat_ptr <= 1;
                                correct_count <= 1;
                            end
                            else begin
                                pat_ptr <= 0;
                                correct_count <= 1;
                                str_ptr <= str_ptr + 1;
                            end
                        end
                        MONEY:begin
                            if(str == 8'h20)begin
                                correct_count <= correct_count + 1;
                                pat_ptr <= pat_ptr + 1;
                                match <=  1;
                                str_ptr <= str_ptr + 1;
                            end
                            else begin
                                correct_count <= (star_flag)? star_loc+1:0;
                                pat_ptr <= (star_flag)? star_loc+1:0;
                                str_ptr <= str_ptr + 1;
                            end
                        end
                        STAR:begin
                            star_flag <= 1;
                            //correct_count <= correct_count + 1;
                            pat_ptr <= pat_ptr + 1;
                            star_loc <= pat_ptr;
                            bf_star <= 0;
                            //str_ptr <= str_ptr + 1;
                        end
                        DOT:begin
                            correct_count <= correct_count + 1;
                            pat_ptr <= pat_ptr + 1;
                            str_ptr <= str_ptr + 1;
                            match_index <= (correct_count == 0)? str_ptr:match_index;
                        end
                        default:begin
                            if(pat == str)begin
                                correct_count <= correct_count + 1;
                                pat_ptr <= pat_ptr + 1;
                                str_ptr <= str_ptr + 1;
                                star_count <= (star_flag)? star_count+1:star_count;
                                //star_flag <= 0;
                                if(pat_data[0] == HAT)begin
                                    match_index <= (correct_count == 1)? str_ptr:match_index;
                                end
                                else begin
                                    match_index <= (correct_count == 0)? str_ptr:match_index;
                                end
                            end
                            else begin
                                correct_count <= (star_flag)? star_loc+1:0;
                                pat_ptr <= (star_flag)? star_loc+1:0;
                                str_ptr <= (correct_count == 0 || pat_data[0] == HAT || star_flag)? str_ptr + 1 : match_index+1;
                            end
                        end 
                    endcase
                end
                FINISH:begin
                    star_flag <= 0;
                    valid <= 1;
                    str_count <= 0;
                    pat_count <= 0;
                    correct_count <= 0;
                    str_ptr <= 0;
                    pat_ptr <= 0;
                    star_flag <= 0;
                    star_count <= 0;
                    bf_star <= 1;    
                end
                default:begin
                end
            endcase
        end
    end
    
endmodule
