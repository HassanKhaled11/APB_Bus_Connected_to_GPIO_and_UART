module GPIO(clk, rst_n, BUSW, BUSWDATA, BUSRDATA, REGSEL, pins);
 	inout[7:0] pins;
	input clk;
	input rst_n;
	input [1:0] REGSEL;
	
	reg[7:0] DIR; //R/W
	reg[7:0] PIN; //READONLY
	reg[7:0] PORT; //R/W

	input BUSW;
	input [7:0] BUSWDATA;
	output reg [7:0] BUSRDATA;
	
	
	
	assign pins = PIN;
	

	initial begin
		PORT <= 8'b00000000;
		DIR <= 8'b00000000;
		PIN <= 8'b00000000;
		BUSRDATA <= 8'b00000000;
	end
	
	

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			PORT <= 8'b00000000;
			DIR <= 8'b00000000;
			BUSRDATA <= 8'b00000000;
			PIN <= 0;
		end

		else if(BUSW) begin
			case (REGSEL)
				2'b10: DIR = BUSWDATA;
				2'b11: PORT = BUSWDATA;
			endcase
		end
	end

	always @(posedge clk) begin
      //DIO
			PIN <= (pins & ~DIR) | (DIR & PORT);			
			if(!BUSW) begin
			     case (REGSEL)
				        2'b10: BUSRDATA <= DIR;
				        2'b11: BUSRDATA <= PORT;	
				        default: BUSRDATA <= PIN;
			     endcase
		  end
	end

					
endmodule
