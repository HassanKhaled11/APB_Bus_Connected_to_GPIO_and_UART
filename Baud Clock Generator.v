`timescale 1ns/1ns

module baud_clock_generator #
(
 parameter CLOCK_RATE = 16000000,
 parameter BAUD_RATE = 9600
)
(
 input  wire clk,
 input  wire rst_n,
 output wire tx_clk,
 output wire rx_clk
);
  //Standard baud rates include 110, 300, 600, 1200, 2400, 4800, 9600, 14400, 19200, 38400, 57600, 115200, 128000 and 256000 bits per second
  localparam BITS = 32;
  reg[BITS-1:0]  tx_final_val = (CLOCK_RATE/(BAUD_RATE))-1;
  reg[BITS-1:0]  rx_final_val = (CLOCK_RATE/(16*BAUD_RATE))-1;
  reg[BITS-1:0]  tx_counter;
  reg[BITS-1:0]  rx_counter;
  
  always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      tx_counter <= 'b0;
      rx_counter <= 'b0;
    end
    else begin
      //For TX CLK
      if(tx_counter == tx_final_val)
        tx_counter = 'b0;
      else
        tx_counter = tx_counter + 1;
        
      //For RX CLK
      if(rx_counter == rx_final_val)
        rx_counter = 'b0;
      else
        rx_counter = rx_counter + 1;
    end
  end
  
  assign tx_clk = (tx_counter == tx_final_val);
  assign rx_clk = (rx_counter == rx_final_val);
    
endmodule

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