`timescale 1ns/1ns

module tb_Uart();

reg clk, rst_n, pwr, pen, pready, rxd;
reg [1:0] psel;
reg [31:0] pwData, pAdd;
wire prdata, txd;

//Test transmitter
Uart uart(.clk(clk), .pwData(pwData), .pAdd(pAdd), .rst_n(rst_n), .pwr(pwr), .psel(psel), .pen(pen),
          .prdata(prdata), .pready(pready), .rxd(rxd), .txd(txd));

always #1 clk = ~clk;

initial begin
  clk <= 0; pwData <= 0; pAdd <= 0; rst_n <= 0; pwr <= 0; psel <= 2'b00; pen <= 0; 
  #3 pAdd <= 32'd15; pwr <= 1; psel <= 2'b10; rst_n = 1; pen <= 1;
  #2 rxd <= 0; 
  #150 rxd = 1;
end
endmodule