`timescale 1us/1us

//Module Piso implementation 
module piso(input wire clk,input wire rst_n,input wire load,input wire[7:0]data_in,output reg data_out,output wire data_sent);
  reg[7:0] data_reg;
  reg[2:0] count;
  
  always @(posedge clk or negedge rst_n)  begin
    if(!rst_n) begin
      data_reg <= 8'h00; //Reset data register
      count    <= 3'b000; 
 
   end 
    else begin
      //if load signal is set then load the parallel data inside the register and reset serial data out
      if(load)
      {data_reg,data_out} <= {data_in,1'b0};
    // if load is 0 then shift the data register by 1 bit right and out the right significant inside register to the serial out
      else begin
        {data_reg,data_out} <= {1'b0,data_reg};
        count = count + 1'b1;
      end
    end
  end
  
  assign data_sent = (count == 3'b100)?1'b1:1'b0; 
 
  
endmodule

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
module mux_tx(input wire data_bit,input wire parity_bit,input wire[2:0] select,output reg mux_out);
  reg start_bit = 1'b0;
  reg stop_bit  = 1'b1;

  always@(select or data_bit) begin
    case(select)
      3'b001:   mux_out = start_bit;
      3'b010:   mux_out = data_bit;
      3'b011:   mux_out = parity_bit;
      3'b011:   mux_out = stop_bit;
      3'b100:   mux_out = stop_bit;
      default: mux_out = stop_bit;
    endcase
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

//Finite State Machine Module
module fsm_tx(
    input wire tx_clk,
    input wire rst_n,
    input wire tx_start,
    input wire tx_enable,
    input wire data_sent,
    output reg select,
    output reg load,
    output reg parity_enable,
    output reg done,
    output reg busy
);
  localparam[2:0] IDLE        = 3'b000,
                  START_BIT   = 3'b001,
                  DATA_BIT    = 3'b010,
                  PARITY_BIT  = 3'b011,
                  STOP_BIT    = 3'b100;
 
  
 
  reg [2:0] state;
  reg [2:0] next_state;
    
    always @(posedge tx_clk) begin
      if(~rst_n)
        state = IDLE;
      else
        state = next_state;
    end
    
    always @(state) begin
      case(state)
            IDLE       : begin
                if (tx_start & tx_enable)
                    next_state   <= START_BIT;
            end
            START_BIT    : begin
                state   <= DATA_BIT;
            end
            DATA_BIT     : begin // Wait 8 clock cycles for data bits to be sent
                if (data_sent)
                    next_state   <= PARITY_BIT;
                else
                    next_state   <= DATA_BIT;
            end
            PARITY_BIT   : begin // Send out parity bit (even parity)
                next_state   <= STOP_BIT;
            end
            STOP_BIT     : begin // Send out Stop bit (high)
                next_state   <= IDLE;
            end
            default      : begin
                next_state   <= IDLE;
            end
        endcase
    end
    
    always @(state) begin
        case (state)
            IDLE            : begin
                select        <= 2'bxx;
                load          <= 1'b1;
                parity_enable <= 1'b0;
                done          <= 1'b0;
                busy          <= 1'b0;
            end
            START_BIT  : begin
                select        <= 2'b00;
                load          <= 1'b1;
                parity_enable <= 1'b1;
                done          <= 1'b0;
                busy          <= 1'b1;
            end
            DATA_BIT  : begin // Wait 8 clock cycles for data bits to be sent
                select        <= 2'b01;
                load          <= 1'b0;
                parity_enable <= 1'b1;
                done          <= 1'b0;
                busy          <= 1'b1;
            end
            PARITY_BIT   : begin // Send out parity bit (even parity)
                select        <= 2'b10;
                load          <= 1'b0;
                parity_enable <= 1'b1;
                done          <= 1'b0;
                busy          <= 1'b1;
            end
            STOP_BIT   : begin // Send out Stop bit (high)
                select        <= 2'b11;
                load          <= 1'b1;
                parity_enable <= 1'b0;
                done          <= 1'b1;
                busy          <= 1'b1;
            end
            default     : begin
                state   <= IDLE;
            end
        endcase
    end
endmodule

module transmitter(
    input  wire       tx_clk,         // baud rate
    input  wire       rst_n,         //reset
    input  wire       tx_start,     // start of transaction
    input  wire       tx_enable,
    input  wire [7:0] tx_data_in,   // data to transmit
    output reg        tx_data_out,  // out of mux
    output reg        done,         // end on transaction
    output reg        busy          // transaction is in process
);
   wire data_sent,load,parity_enable,parity_bit;
   wire data_bit; //Data bit without start or stop bit to be input for mux
   wire[2:0] select;
   
  fsm_tx t1(
  .tx_clk(tx_clk),
  .rst_n(rst_n),
  .tx_start(tx_start),
  .tx_enable(tx_enable),
  .data_sent(data_sent),
  .select(select),
  .load(load),
  .parity_enable(parity_enable),
  .done(done),
  .busy(busy)
 );
 piso t2(.clk(clk),.reset(reset),.load(load),.data_in(tx_data_in),.data_out(data_bit),.data_sent(data_sent));
 parity_generator t3(.parity_enable(parity_enable),.data(tx_data_in),.parity(parity_bit));
 mux_tx t4(.data_bit(data_bit),.parity_bit(parity_bit),.select(select),.mux_out(tx_data_out));
    
    
endmodule