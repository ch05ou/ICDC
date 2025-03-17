`timescale 1ns/10ps

module  CONV(
	input		clk,
	input		reset,
	output	reg busy,	
	input		ready,	
			
	output	reg [11:0]iaddr,
	input		[19:0]idata,	
	
	output	reg cwr,
	output	reg[11:0]caddr_wr,
	output 	reg[19:0]cdata_wr,
	
	output	reg crd,
	output	reg [11:0]caddr_rd,
	input	 	[19:0]cdata_rd,
	
	output  reg[2:0]csel);

localparam INIT = 0;
localparam LAYER0 = 1;
localparam LAYER1 = 2;
localparam LAYER2 = 3;
localparam FINISH = 15;

parameter signed K0_bias = 20'h01310;
parameter signed K1_bias = 20'hF7295;

reg [3:0]now_state,nxt_state;
reg [3:0]adder_count;
reg [11:0]iaddr_tmp,caddr_tmp,caddr_wr_tmp,caddr_rd_tmp;

reg signed[19:0]pix_data,kernel0,kernel1;
wire signed[39:0]k0_product,k1_product;
reg signed[19:0]k0_round,k1_round;

reg signed[39:0]k0_sum,k1_sum;
reg [19:0]k0_max,k1_max,k0_tmp,k1_tmp;

wire [3:0]edge_detect;

integer i;

assign edge_detect[0] = (iaddr_tmp < 64)? 1:0;			// upper bound
assign edge_detect[1] = (iaddr_tmp >= 4032)? 1:0;		// lower bound
assign edge_detect[2] = (iaddr_tmp % 64 == 0)? 1:0;		// left  bound
assign edge_detect[3] = (iaddr_tmp % 64 == 63)? 1:0;	// right bound

assign k0_product = pix_data * kernel0;
assign k1_product = pix_data * kernel1;

always @(posedge clk , posedge reset) begin
	if(reset)now_state <= INIT;
	else now_state <= nxt_state;
end

always @(*) begin
	case(now_state)
		INIT:begin
			nxt_state = (busy)? LAYER0 : INIT;
		end
		LAYER0:begin
			nxt_state = (adder_count == 12 && iaddr_tmp == 4095)? LAYER1 : LAYER0;
		end
		LAYER1:begin
			nxt_state = (adder_count == 9 && caddr_tmp == 4030)? LAYER2:LAYER1;
		end
		LAYER2:begin
			nxt_state = (adder_count == 4 && caddr_wr_tmp == 2047)? FINISH:LAYER2;
		end
		FINISH:begin
			nxt_state = INIT;
		end
		default:begin
			nxt_state = INIT;
		end
	endcase
end

always @(posedge clk , posedge reset) begin
	if(reset)begin
		iaddr <= 0;
		iaddr_tmp <= 0;
		adder_count <= 0;
		k0_sum <= 0;
		k1_sum <= 0;
		k0_round <= 0;
		k1_round <= 0;
		caddr_tmp <= 0;
		caddr_wr_tmp <= 0;
		caddr_rd_tmp <= 0;
	end
	else begin
		case(now_state)
			INIT:begin
				adder_count <= 0;
			end
			LAYER0:begin
				adder_count <= (adder_count == 12)? 0:adder_count + 1;
				case(adder_count)
					0:begin
						iaddr_tmp <= iaddr;
						iaddr <= iaddr - 65;
						k0_sum <= 0;
						k1_sum <= 0;
					end
					1:begin
						iaddr <=  iaddr_tmp - 64;
						k0_sum <= k0_sum + k0_product;
						k1_sum <= k1_sum + k1_product;
					end
					2:begin
						iaddr <=  iaddr_tmp - 63;
						k0_sum <= k0_sum + k0_product;
						k1_sum <= k1_sum + k1_product;
					end
					3:begin
						iaddr <=  iaddr_tmp - 1;
						k0_sum <= k0_sum + k0_product;
						k1_sum <= k1_sum + k1_product;
					end
					4:begin
						iaddr <=  iaddr_tmp+1;
						k0_sum <= k0_sum + k0_product;
						k1_sum <= k1_sum + k1_product;
					end
					5:begin
						iaddr <=  iaddr_tmp + 63;
						k0_sum <= k0_sum + k0_product;
						k1_sum <= k1_sum + k1_product;
					end
					6:begin
						iaddr <=  iaddr_tmp + 64;
						k0_sum <= k0_sum + k0_product;
						k1_sum <= k1_sum + k1_product;
					end
					7:begin
						iaddr <=  iaddr_tmp + 65;
						k0_sum <= k0_sum + k0_product;
						k1_sum <= k1_sum + k1_product;
					end
					8:begin
						iaddr <= iaddr_tmp + 1;
						k0_sum <= k0_sum + k0_product;
						k1_sum <= k1_sum + k1_product;
					end
					9:begin
						k0_sum <= k0_sum + k0_product;
						k1_sum <= k1_sum + k1_product;
					end
					10:begin
						k0_round <= (k0_sum[15])? k0_sum[35:16] + K0_bias + 1 : k0_sum[35:16] + K0_bias;
						k1_round <= (k1_sum[15])? k1_sum[35:16] + K1_bias + 1 : k1_sum[35:16] + K1_bias;
					end
					default:begin
					end
				endcase
			end
			LAYER1:begin
				adder_count <= (adder_count == 9)? 0:adder_count + 1;
				if(adder_count == 9)begin
					caddr_tmp <= (caddr_rd % 64 == 63)? caddr_tmp + 66:caddr_tmp + 2;
				end
				else begin
				end
			end
			LAYER2:begin
				adder_count <= (adder_count == 4)? 0:adder_count + 1;
				caddr_wr_tmp <= (adder_count >= 3 )? caddr_wr_tmp + 1:caddr_wr_tmp;
				caddr_rd_tmp <= (adder_count == 3)? caddr_rd_tmp + 1:caddr_rd_tmp;
			end
			default:begin
			end
		endcase
	end
end

// Memory Control
always @(posedge clk , posedge reset) begin
	if(reset)begin
		cwr <= 0;
		crd <= 0;
		caddr_wr <= 0;
		cdata_wr <= 0;
		caddr_rd <= 0;
		csel <= 0;
		k0_max <= 0;
		k1_max <= 0;
		k0_tmp <= 0;
		k1_tmp <= 0;
	end
	else begin
		case(now_state)
			INIT:begin
				cwr <= 0;
				caddr_wr <= 0;
				cdata_wr <= 0;
			end
			LAYER0:begin
				cwr <= (adder_count>  10)? 1:0;
				caddr_wr <= iaddr_tmp;
				cdata_wr <= (adder_count == 11)? (k0_round[19])? 0:k0_round: (k1_round[19])? 0:k1_round;
				csel <= (adder_count == 11)? 3'b001:(adder_count == 12)? 3'b010:3'b000;
			end
			LAYER1:begin
				case(adder_count)
					0:begin
						cwr <= 0;
						crd <= 1;
						caddr_rd <= caddr_tmp;
						csel <= 3'b001;
						k0_max <= 0;
						k1_max <= 0;
					end
					1:begin
						csel <= 3'b010;
						k0_max <= cdata_rd;
					end
					2:begin
						caddr_rd <= caddr_tmp + 1;
						csel <= 3'b001;
						k1_max <= cdata_rd;
					end
					3:begin
						csel <= 3'b010;
						k0_max <= (cdata_rd > k0_max)? cdata_rd:k0_max;
					end
					4:begin
						caddr_rd <= caddr_tmp + 64;
						csel <= 3'b001;
						k1_max <= (cdata_rd > k1_max)? cdata_rd:k1_max;
					end
					5:begin
						csel <= 3'b010;
						k0_max <= (cdata_rd > k0_max)? cdata_rd:k0_max;
					end
					6:begin
						caddr_rd <= caddr_tmp + 65;
						csel <= 3'b001;
						k1_max <= (cdata_rd > k1_max)? cdata_rd:k1_max;
					end
					7:begin
						csel <= 3'b010;
						k0_max <= (cdata_rd > k0_max)? cdata_rd:k0_max;
					end
					8:begin
						crd <= 0;
						cwr <= 1;
						csel <= 3'b011;
						caddr_wr <= caddr_wr + 1;
						k1_max <= (cdata_rd > k1_max)? cdata_rd:k1_max;
						cdata_wr <= k0_max;
					end
					9:begin
						cdata_wr <= k1_max;
						csel <= 3'b100;
					end
					default:begin
					end
				endcase
			end
			LAYER2:begin
				case(adder_count)
					0:begin
						cwr <= 0;
						crd <= 1;
						caddr_rd <= caddr_rd_tmp;
						cdata_wr <= 0;
						csel <= 3'b011;
					end
					1:begin
						csel <= 3'b100;
						k0_tmp <= cdata_rd;
					end
					2:begin
						crd <= 0;
						cwr <= 1;
						csel <= 3'b101;
						k1_tmp <= cdata_rd;
						cdata_wr <= k0_tmp;
						caddr_wr <= caddr_wr_tmp;
					end
					3:begin
						cdata_wr <= k1_tmp;
						caddr_wr <= caddr_wr_tmp+1;
					end
					4:begin
						cwr <= 0;
						crd <= 0;
						csel <= 3'b011;
					end
					default:begin
					end
				endcase
			end
			FINISH:begin
				cwr <= 0;
				caddr_wr <= 0;
				cdata_wr <= 0;
			end
			default:begin
			end
		endcase
	end
end

// Kernel Parameter Control
always @(posedge clk , posedge reset) begin
	if(reset)begin
	end
	else begin
		case(adder_count)
			0:begin
				kernel0 <= 20'hF8F71;
				kernel1 <= 20'h02F20;
			end
			1:begin
				kernel0 <= 20'h0A89E;
				kernel1 <= 20'hFDB55;
			end
			2:begin
				kernel0 <= 20'h092D5;
				kernel1 <= 20'h02992;
			end
			3:begin
				kernel0 <= 20'h06D43;
				kernel1 <= 20'hFC994;
			end
			4:begin
				kernel0 <= 20'h01004;
				kernel1 <= 20'h050FD;
			end
			5:begin
				kernel0 <= 20'hF6E54;
				kernel1 <= 20'h0202D;
			end
			6:begin
				kernel0 <= 20'hFA6D7;
				kernel1 <= 20'h03BD7;
			end
			7:begin
				kernel0 <= 20'hFC834;
				kernel1 <= 20'hFD369;
			end
			8:begin
				kernel0 <= 20'hFAC19;
				kernel1 <= 20'h05E68;
			end
			default:begin
				kernel0 <= 20'h00000;
				kernel1 <= 20'h00000;
			end
		endcase
	end
end

// Pixel data control
always @(posedge clk , posedge reset)begin
	if(reset)begin
		pix_data <= 0;
	end
	else begin
		case(adder_count)
			0:pix_data <= (ready)? 0:idata;
			1:pix_data <= (edge_detect[0] || edge_detect[2])? 0:idata;
			2:pix_data <= (edge_detect[0])? 0:idata;
			3:pix_data <= (edge_detect[0] || edge_detect[3])? 0:idata;
			4:pix_data <= (edge_detect[2])? 0:idata;
			5:pix_data <= (edge_detect[3])? 0:idata;
			6:pix_data <= (edge_detect[1] || edge_detect[2])? 0:idata;
			7:pix_data <= (edge_detect[1])? 0:idata;
			8:pix_data <= (edge_detect[1] || edge_detect[3])? 0:idata;
			default:begin
				pix_data <= 0;
			end
		endcase
	end
end

// Busy control
always @(posedge clk , posedge reset) begin
	if(reset)begin
		busy <= 0;
	end
	else begin
		busy <= (ready)? 1:(now_state == FINISH)? 0:1;
	end
end

endmodule


