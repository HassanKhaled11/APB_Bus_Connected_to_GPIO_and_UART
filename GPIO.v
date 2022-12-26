module GPIO(clk, rst_n, BUSW, BUSWDATA, BUSRDATA, REGSEL, pins);
 	inout[7:0] pins;
	input clk;
	input rst_n;
	input [1:0] REGSEL;
	
	reg[7:0] DIR; //R/W
	reg[7:0] PIN; //READONLY
	reg PCTL;	//R/W
	reg[7:0] PORT; //R/W

	input BUSW;
	input [7:0] BUSWDATA;
	output reg [7:0] BUSRDATA;
	
	
	
	assign pins = PIN;

	initial begin
		PORT <= 8'b00000000;
		DIR <= 8'b00000000;
		PCTL <= 0;
		BUSRDATA <= 8'b00000000;
	end
	
	

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			PORT <= 8'b00000000;
			DIR <= 8'b00000000;
			PCTL <= 0;
			BUSRDATA <= 8'b00000000;
		end

		else if(BUSW) begin
			case (REGSEL)
				2'b01:begin 
						   PCTL = BUSWDATA[0];
						   if(PCTL) begin
						     DIR = 8'b00000010; //TX and RX
						     BUSRDATA = 8'b00000000;
						   end
				      end
				2'b10: DIR = BUSWDATA;
				2'b11: PORT = BUSWDATA;		
			endcase
		end
	end

	always @(posedge clk) begin
		if(PCTL) begin //UART
			PORT[7:2] <= 6'b000000;
			PIN = (pins & ~DIR) | (DIR & PORT);
			if(!BUSW) BUSRDATA[0] <= PIN[0]; //RX PIN
			else PORT[1] <= BUSWDATA[0]; //TX PIN
		end

		else if(PCTL==0) begin //DIO
			PIN = (pins & ~DIR) | (DIR & PORT);
			if(!BUSW) BUSRDATA[7:0] <= PIN;
		end
	end

	
	
			
					
endmodule
