`timescale 1us/1us

//Test Bensch For piso (Parallel In Serial Out Shift Register)
module tb_piso();
  reg clk,rst_n,load;
  reg[7:0] data_in;
  wire data_out,data_sent;
  
  piso p1(.clk(clk),.rst_n(rst_n),.load(load),.data_in(data_in),.data_out(data_out),.data_sent(data_sent));
  
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

//Test Bench for Parity Generator
module tb_parity_generator();
  reg parity_enable;
  reg[7:0] data_in;
  wire parity;
  
  parity_generator p1(.parity_enable(parity_enable),.data(data_in),.parity(parity));
  
  initial begin
    parity_enable = 0;data_in = 8'h00;
    #2  parity_enable = 1; data_in = 8'b11101010;
    #2  parity_enable = 0;
    #2  parity_enable = 1; data_in = 8'b10101010;
  end
endmodule

//TestBench for Transmitter Mux
module tb_mux_tx();
  reg clk,rst_n,load;
  wire data_bit,parity_bit,data_sent;
  reg parity_enable;
  reg[7:0] data_in;
  reg[1:0] select;
  wire mux_out;
  
  piso shift_register(.clk(clk),.rst_n(rst_n),.load(load),.data_in(data_in),.data_out(data_bit),.data_sent(data_sent));
  parity_generator p1(.parity_enable(parity_enable),.data(data_in),.parity(parity_bit));
  mux_tx m1(.data_bit(data_bit),.parity_bit(parity_bit),.select(select),.mux_out(mux_out));
  
  always #1 clk = ~clk;
  
  initial begin
    clk = 0;rst_n = 0;load = 1;data_in = 8'h00;parity_enable = 0;select = 2'bxx;
    #3  rst_n = 1;
    
    //First Test Case
    #2  load = 1; data_in = 8'b10101011;parity_enable = 1;
    #2  select = 2'b00;
    #2  select = 2'b01;load = 0;
    #16 select = 2'b10;
    #2  select = 2'b11;parity_enable  = 0;
    
    //Second Test Case
    #2  load = 1; data_in = 8'b11100101;parity_enable = 1;
    #2  select = 2'b00;
    #2  select = 2'b01;load = 0;
    #16 select = 2'b10;load = 1;data_in = 8'h00;
    #2  select = 2'b11;parity_enable  = 0;
  end
  
endmodule