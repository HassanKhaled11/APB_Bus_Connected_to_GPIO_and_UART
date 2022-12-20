`timescale 1us/1us

module transmitter(input wire clk,input wire rst_n,input wire tx_start,input wire[7:0]tx_data_in,output wire tx_data_out);

endmodule

module fsm_transmitter();
endmodule

module piso(input wire clk,input wire rst_n,input wire load,input wire[7:0]data_in,output reg data_out);
  reg[7:0] data_reg;
  
  always @(posedge clk or negedge rst_n)  begin
    if(!rst_n)
      data_reg <= 8'h00; //Reset data register 
    else begin
      //if load signal is set then load the parallel data inside the register and reset serial data out
      if(load) 
      {data_reg,data_out} <= {data_in,1'b0};
    // if load is 0 then shift the data register by 1 bit right and out the right significant inside register to the serial out
    else
      {data_reg,data_out} <= {1'b0,data_reg};
    end
  end

endmodule

module tb_piso();
  reg clk,rst_n,load;
  reg[7:0] data_in;
  wire data_out;
  
  piso p1(.clk(clk),.rst_n(rst_n),.load(load),.data_in(data_in),.data_out(data_out));
  
  always #1 clk = ~clk;
  
  initial begin
    clk = 0;rst_n = 0;load = 1;data_in = 8'h00;
    #3  rst_n = 1;
    #2  load = 1; data_in = 8'b10101010;
    #2  load = 0;
    #16 load = 1; data_in = 8'b00011001;
    #2  load = 0;
  end
  
endmodule

