`timescale 1ns/1ns

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

module tb_transmitter_WithBauudClock();
  reg clk;
  wire        tx_clk;         // baud rate
  reg        rst_n;         //reset
  reg        tx_start;     // start of transaction
  reg        tx_enable;
  reg [7:0]  tx_data_in;   // data to transmit
  wire       tx_data_out;  // out of mux
  wire       done;         // end on transaction
  wire       busy;          // transaction is in process
    
  localparam  CLOCK_RATE = 10000000;              //Need configuration
  localparam  BAUD_RATE = 9600;                   //Need configuration
  
  localparam  PERIOD = (1000000000/CLOCK_RATE);
  localparam  _1SEC = 1000000000;
  
  baud_clock_generator#(.CLOCK_RATE(CLOCK_RATE),.BAUD_RATE(BAUD_RATE)) b1(.clk(clk),.rst_n(rst_n),.tx_clk(tx_clk));
  
  always #(PERIOD/2) clk = ~clk;
  
  initial begin
    clk = 0;rst_n = 0;tx_start <= 0;tx_enable <= 0;tx_data_in <= 8'h00;
    #(3*PERIOD) rst_n = 1;
    #(PERIOD) tx_enable <= 1; tx_start  <= 1;tx_data_in = 8'b01111010;
  end
   
   
  transmitter t1(.tx_clk(tx_clk),.rst_n(rst_n),.tx_start(tx_start),.tx_enable(tx_enable),.tx_data_in(tx_data_in),
                  .tx_data_out(tx_data_out),.done(done),.busy(busy));
endmodule


module tb_transmitter_withSystemClock();
    reg        tx_clk;         // baud rate
    reg        rst_n;         //reset
    reg        tx_start;     // start of transaction
    reg        tx_enable;
    reg [7:0]  tx_data_in;   // data to transmit
    wire       tx_data_out;  // out of mux
    wire       done;         // end on transaction
    wire       busy;          // transaction is in process
   transmitter t1(.tx_clk(tx_clk),.rst_n(rst_n),.tx_start(tx_start),.tx_enable(tx_enable),.tx_data_in(tx_data_in),
                  .tx_data_out(tx_data_out),.done(done),.busy(busy));
   
   always #1 tx_clk = ~tx_clk;
  
  
  initial begin
    tx_clk <= 0;rst_n <= 0;tx_start <= 0;tx_enable <= 0;tx_data_in <= 8'h00;
    #3  rst_n <= 1;
    #2  tx_enable <= 1; tx_start  <= 1;
    #2  tx_data_in = 8'b10101010;
  end
endmodule