`timescale 1ns/1ns

module tb_baud_clock_generator();
  reg clk, rst_n;
  reg[16:0] tx_bits_counter = 'b0;
  reg[16:0] rx_bits_counter = 'b0;
  
  wire tx_clk;
  wire rx_clk;
  
  localparam  CLOCK_RATE = 100000000;              //Need configuration
  localparam  BAUD_RATE = 9600;                   //Need configuration
  
  localparam  PERIOD = (1000000000/CLOCK_RATE);
  localparam  _1SEC = 1000000000;
  
  baud_clock_generator#(.CLOCK_RATE(CLOCK_RATE),.BAUD_RATE(BAUD_RATE)) b1(.clk(clk),.rst_n(rst_n),.tx_clk(tx_clk),.rx_clk(rx_clk));
  
  always #(PERIOD/2) clk = ~clk;
  
  initial begin
    clk = 1;rst_n = 0;
    #(PERIOD) rst_n = 1;
    #_1SEC $display("%d\n%d",tx_bits_counter,rx_bits_counter);
  end
   
   always@(posedge tx_clk)
    tx_bits_counter = tx_bits_counter + 1;
  
  always@(posedge rx_clk)
    rx_bits_counter = rx_bits_counter + 1;
    
endmodule
