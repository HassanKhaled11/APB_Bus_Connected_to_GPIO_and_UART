`timescale 1ns/1ns


module tb_receiver();
  reg clk, en, in;
  wire parity_en;
  wire parity_err;
  wire done, busy, err;
  wire [7:0]out;
  Uart8Receiver uart8receiver(.parity_en(parity_en), .clk(clk), .en(en), .in(in), .parity_err(parity_err), .out(out), .busy(busy), .err(err), .done(done));
  PARITY_CHECK parity_check(.parity_en(parity_en), .rx(in), .rx_data_in(out), .parity_err(parity_err));
  always #1 clk = ~clk;
  
  initial begin
    clk <= 0; en <= 1; in <= 0;
    #3 in = 0; 
    #2 en = 1;
    #32 in = 1;
    #32 in = 0;
    #32 in = 1;
    #32 in = 0; 
    #32 in = 1;
    #32 in = 0;
    #32 in = 1;
    #32 in = 1;
    #32 in = 0;   // Parity bit (Parity error)
    #32 in = 1;   //stop bit                   
  end
endmodule

