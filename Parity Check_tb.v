`timescale 1ns/1ns

module tb_parity();
  reg rx, parity_en;
  reg[7:0] rx_data_in;
  PARITY_CHECK parity_check(.parity_en(parity_en), .rx(rx), .rx_data_in(rx_data_in));
  initial begin
    parity_en = 1; rx = 1; rx_data_in = 8'b11110000;
    #2  rx_data_in = 8'b11110000;
    #2  parity_en = 0;
    #2  parity_en = 1; rx_data_in = 8'b1110000;
  end
endmodule