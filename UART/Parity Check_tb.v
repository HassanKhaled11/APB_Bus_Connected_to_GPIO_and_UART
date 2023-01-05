`timescale 1ns/1ns

module tb_parity_check();
  reg rx, errorCheck_en;
  reg[7:0] rx_data_in;
  PARITY_CHECK parity_check(.errorCheck_en(errorCheck_en), .rx(rx), .rx_data_in(rx_data_in));
  initial begin
    errorCheck_en = 0; rx = 0; rx_data_in = 8'b00000000;
    #2  errorCheck_en <= 1; rx <= 1; rx_data_in = 8'b11110000;   //There is parity error    
    #2  errorCheck_en = 0;
    #2  errorCheck_en = 1; rx_data_in = 8'b11000000;             //There is parity error
    #2  errorCheck_en = 0;
    #2  errorCheck_en = 1; rx <= 0; rx_data_in = 8'b11000000;    //There is no parity error
  end
endmodule

