`timescale 1ns/1ns


module tb_receiver();
  reg clk, rxStart, in, rst_n, rx_en;
  wire done, busy, err;
  wire [7:0]out;
  
  Receiver receiver(.clk(clk), .rxStart(rxStart), .in(in), .out(out), 
                    .busy(busy), .err(err), .done(done), .rx_en(rx_en), .rst_n(rst_n));
  
  always #1 clk = ~clk;
  
  initial begin
    clk <= 0; rxStart <= 1; in <= 0; rst_n <= 1; rx_en <= 1;
    #3 in = 0; 
    #2 rxStart = 1;
    #32 in = 1;
    #32 in = 1;
    #32 in = 1;
    #32 in = 1; 
    #32 in = 1;
    #32 in = 0;
    #32 in = 1;
    #32 in = 1;
    #32 in = 1;   // Parity bit (no parity error)
    #32 in = 1;   //stop bit Done                 
  end
endmodule


