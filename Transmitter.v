`timescale 1us/1us

//Module Piso implementation 
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

//Test Bensch For piso (Parallel In Serial Out Shift Register)
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

//Parity Generator Module
module parity_generator #(parameter data_width = 8)(input wire parity_enable,input wire[data_width-1:0] data,output reg parity);
  always@(parity_enable or data) begin
    if(parity_enable)
      parity = ^data;
    else
      parity = 0;
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

//MUX module which generate bit (start/data/parity/stop) according to section number
module mux_tx(input wire data_bit,input wire parity_bit,input wire[1:0] select,output reg mux_out);
  reg start_bit = 1'b0;
  reg stop_bit  = 1'b1;

  always@(select or data_bit) begin
    case(select)
      2'b00:   mux_out = start_bit;
      2'b01:   mux_out = data_bit;
      2'b10:   mux_out = parity_bit;
      2'b11:   mux_out = stop_bit;
      default: mux_out = stop_bit;
    endcase
  end
endmodule

//TestBench for Transmitter Mux
module tb_mux_tx();
  reg clk,rst_n,load;
  wire data_bit,parity_bit;
  reg parity_enable;
  reg[7:0] data_in;
  reg[1:0] select;
  wire mux_out;
  
  
  piso shift_register(.clk(clk),.rst_n(rst_n),.load(load),.data_in(data_in),.data_out(data_bit));
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

//Finite State Machine Module
module fsm_transmitter();
endmodule

module transmitter(input wire clk,input wire rst_n,input wire tx_start,input wire[7:0]tx_data_in,output wire tx_data_out);
endmodule