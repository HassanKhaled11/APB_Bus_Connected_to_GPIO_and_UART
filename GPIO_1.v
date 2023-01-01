module gpio(clk, rst, BUS_W, BUS_WDATA, BUS_RDATA, pins);
 	inout[5:0] pins;
	input clk;
	input rst;
	reg[5:0] DIR; //R/W
	reg[5:0] PIN; //READONLY
	reg PCTL;	//R/W
	reg[5:0] PORT; //R/W

	output reg BUS_W;
	output reg [7:0] BUS_WDATA;
	//input BUS_R;
	input [7:0] BUS_RDATA;
	assign pins = PIN;

	initial begin
		PORT <= 6'b000000;
		DIR <= 6'b000000;
		PCTL <= 0;
		BUS_W <= 0;
		BUS_WDATA <= 8'b00000000;
		
	end
	
	

	always @(posedge clk, posedge rst) begin
		if(rst) begin
			PORT <= 6'b000000;
			DIR <= 6'b000000;
			PCTL <= 0;
			BUS_W <= 0;
			BUS_WDATA <= 8'b00000000;
		end

		else begin
			case (BUS_RDATA[7:6])
				2'b00:  begin 
						PCTL = BUS_RDATA[0];
						if(PCTL) begin
						  DIR = 6'b000010; //TX and RX
						  BUS_WDATA = 8'b00000000;
						  end
				end
				2'b01: DIR = BUS_RDATA[5:0];
				2'b10: PORT = BUS_RDATA[5:0];		
			endcase
		end
	end

	always @(posedge clk) begin
		if(PCTL) begin //UART
			PORT[5:2] <= 4'b0000;
			PIN = (pins & ~DIR) | (DIR & PORT);
			BUS_W <= 1;
			BUS_WDATA[0] <= PIN[0]; //TX PIN
			PORT[1] <= BUS_RDATA[0]; //RX PIN
		end

		else if(PCTL==0) begin //DIO
			PIN = (pins & ~DIR) | (DIR & PORT);
			BUS_W <= 1;
			BUS_WDATA[5:0] <= PIN;
		end
	end

	
	
			
					
endmodule
