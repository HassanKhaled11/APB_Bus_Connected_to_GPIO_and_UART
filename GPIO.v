module gpio(clk, rst, BUS_W, BUS_WDATA, BUS_RDATA, pins);
  output reg[5:0] pins;
	input clk;
	input rst;
	reg[5:0] DIR;
	reg PCTL;
	reg[5:0] DATA;

	output reg BUS_W;
	output reg [7:0] BUS_WDATA;
//input BUS_R;
	input [7:0] BUS_RDATA;
//reg[1:0] REGSEL;
	reg[5:0] msk;
	

	always @(posedge clk, posedge rst) begin
		if(rst) begin
			DATA <= 6'b000000;
			DIR <= 6'b000000;
			PCTL <= 0;
		end

		else begin
			
			case (BUS_RDATA[7:6])
				2'b00: begin 
						PCTL = BUS_RDATA[0];
						if(PCTL) DIR[1:0] = 2'b10; //TX and RX
				      end
				2'b01: DIR = BUS_RDATA[5:0];
				2'b10: DATA = BUS_RDATA[5:0];
			endcase
		end
	end

	always @(posedge clk) begin
		if(PCTL) begin
			BUS_W <= 1;
			DATA[5:2] <= 4'b0000;
			BUS_WDATA[0] <= DATA[0]; //TX PIN
			DATA[1] <= BUS_RDATA[0]; //RX PIN
		end

		else if(PCTL==0) begin
			pins <= DATA & DIR;
		end
	end	
			
					
endmodule
