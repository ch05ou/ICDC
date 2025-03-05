// Area : 11034
// Simlation time: 963211 ns
module DT(
	input 			clk, 
	input			reset,
	output	 		done ,
	output			sti_rd ,
	output	reg 	[9:0]	sti_addr ,
	input		[0:15]	sti_di,
	output			res_wr ,
	output			res_rd ,
	output	reg 	[13:0]	res_addr ,
	output	reg 	[7:0]	res_do,
	input		[7:0]	res_di
	);

localparam INIT = 0;
localparam S1 = 1;
localparam S2 = 2;
localparam S3 = 3;
localparam S4 = 4;
localparam S5 = 5;
localparam S6 = 6;
localparam S7 = 7;
localparam S8 = 8;
localparam S9 = 9;
localparam S10 = 10;
localparam S11 = 11;
localparam S12 = 12;
localparam S13 = 13;
localparam S14 = 14;
localparam S15 = 15;
localparam FINISH = 16;

reg [4:0]now_state,next_state;
reg [3:0]res_cout;
reg [7:0]buffer[4:0];

reg [13:0]tmp_addr;

assign done = (now_state == FINISH);
assign sti_rd = (now_state == S1);
assign res_wr = (now_state == S2 || now_state == S8 || now_state == S14);
assign res_rd = (now_state == S3 || now_state == S4 || now_state == S5 || now_state == S6 || now_state == S7
				|| now_state == S9 || now_state == S10 || now_state == S11 || now_state == S12 || now_state == S13);

always @(posedge clk , negedge reset) begin
	if(!reset)begin
		now_state <= INIT;
	end
	else begin
		now_state <= next_state;
	end
end

always @(*) begin
	case(now_state)
		INIT:begin
			next_state = S1;
		end
		S1:begin
			next_state = S2;
		end
		S2:begin
			next_state = (res_addr == 16383)? S3:(res_cout == 15)? S1:S2;
		end
		S3:begin
			next_state = (res_di)? S4:(res_addr+1 == 16383)? S9:S3;
		end
		S4:begin
			next_state = S5;
		end
		S5:begin
			next_state = S6;
		end
		S6:begin
			next_state = S7;
		end
		S7:begin
			next_state = S8;
		end
		S8:begin
			next_state = S3;
		end
		S9:begin
			next_state = (res_di)? S10:(res_addr == 0)? FINISH:S9;
		end
		S10:begin
			next_state = S11;
		end
		S11:begin
			next_state = S12;
		end
		S12:begin
			next_state = S13;
		end
		S13:begin
			next_state = S14;
		end
		S14:begin
			next_state = S9;
		end
		FINISH:begin
			next_state = INIT;
		end
		default:begin
			next_state = INIT;
		end
	endcase
end

always @(*) begin
	case(now_state)
		S2:begin
			res_do = {7'd0,sti_di[res_cout]};
		end
		S8:begin
			res_do = ((buffer[0] <= buffer[1]) && (buffer[0] <= buffer[2]) && (buffer[0] <= buffer[3]))? buffer[0]+1:
					 ((buffer[1] <= buffer[0]) && (buffer[1] <= buffer[2]) && (buffer[1] <= buffer[3]))? buffer[1]+1:
					 ((buffer[2] <= buffer[1]) && (buffer[2] <= buffer[0]) && (buffer[2] <= buffer[3]))? buffer[2]+1:
					 buffer[3]+1;
		end
		S14:begin
			res_do = ((buffer[0] <= buffer[1]) && (buffer[0] <= buffer[2]) && (buffer[0] <= buffer[3])&& (buffer[0] <= buffer[4]))? buffer[0]:
					 ((buffer[1] <= buffer[0]) && (buffer[1] <= buffer[2]) && (buffer[1] <= buffer[3])&& (buffer[1] <= buffer[4]))? buffer[1]:
					 ((buffer[2] <= buffer[1]) && (buffer[2] <= buffer[0]) && (buffer[2] <= buffer[3])&& (buffer[2] <= buffer[4]))? buffer[2]:
					 ((buffer[3] <= buffer[1]) && (buffer[3] <= buffer[2]) && (buffer[3] <= buffer[0])&& (buffer[3] <= buffer[4]))? buffer[3]:
					 buffer[4];
		end
		default:begin
			res_do = 8'd0;
		end
	endcase
end

always @(posedge clk , negedge reset) begin
	if(!reset)begin
		sti_addr <= 10'd0;
	end
	else begin
		if(now_state == S1)begin
			sti_addr <= sti_addr + 10'd1;
		end
		else begin
			sti_addr <= sti_addr;
		end
	end
end

always @(posedge clk , negedge reset) begin
	if(!reset)begin
		res_addr <= 14'd0;
		res_cout <= 4'd0;
		tmp_addr <= 14'd0;
	end
	else begin
		case (now_state)
			S2:begin
				res_addr <= res_addr + 14'd1;
				res_cout <= res_addr + 4'd1;
			end
			S3:begin
				res_addr <= (res_di)? res_addr-129: res_addr + 14'd1;
				tmp_addr <= (res_di)? res_addr: tmp_addr;
			end
			S4:begin
				res_addr <= res_addr+1;
			end
			S5:begin
				res_addr <= res_addr+1;
			end
			S6:begin
				res_addr <= tmp_addr-1;
			end
			S7:begin
				res_addr <= tmp_addr ;
			end
			S8:begin
				res_addr <= res_addr+1;
			end
			S9:begin
				res_addr <= (res_di)? res_addr+1: res_addr - 14'd1;
				tmp_addr <= (res_di)? res_addr: tmp_addr;
			end
			S10:begin
				res_addr <= tmp_addr+127;
			end
			S11:begin
				res_addr <= tmp_addr+128;
			end
			S12:begin
				res_addr <= tmp_addr+129;
			end
			S13:begin
				res_addr <= tmp_addr ;
			end
			S14:begin
				res_addr <= res_addr-1;
			end
			S15:begin
			end
			default:begin
			end
		endcase
	end
end

always @(posedge clk , negedge reset) begin
	if(!reset)begin
		buffer[0] <= 8'd0;
		buffer[1] <= 8'd0;
		buffer[2] <= 8'd0;
		buffer[3] <= 8'd0;
		buffer[4] <= 8'd0;
	end
	else begin
		case(now_state)
			S4:begin
				buffer[0] <= res_di;
			end
			S5:begin
				buffer[1] <= res_di;
			end
			S6:begin
				buffer[2] <= res_di;
			end
			S7:begin
				buffer[3] <= res_di;
			end
			S8:begin
				buffer[0] <= 8'd0;
				buffer[1] <= 8'd0;
				buffer[2] <= 8'd0;
				buffer[3] <= 8'd0;
				buffer[4] <= 8'd0;
			end
			S9:begin
				buffer[4] <= res_di;
			end
			S10:begin
				buffer[0] <= res_di+1;
			end
			S11:begin
				buffer[1] <= res_di+1;
			end
			S12:begin
				buffer[2] <= res_di+1;
			end
			S13:begin
				buffer[3] <= res_di+1;
			end
			S14:begin
			end
			default:begin
			end
		endcase
	end
end

endmodule
