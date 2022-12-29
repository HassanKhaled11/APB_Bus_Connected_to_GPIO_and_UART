//Module Piso implementation 
module piso(input wire tx_clk,input wire rst_n,input wire load,input wire[7:0]data_in,output reg data_out,output wire data_sent);
  reg[7:0] data_reg;
  reg[3:0] count;
  
  always @(posedge tx_clk or negedge rst_n)  begin
    if(!rst_n) begin
      data_reg <= 8'h00; //Reset data register
      count    <= 4'b0000; 
 
   end 
    else begin
      //if load signal is set then load the parallel data inside the register and reset serial data out
      if(load) begin
      {data_reg,data_out} <= {data_in,1'b0};
      count    <= 4'b0000;
      end
    // if load is 0 then shift the data register by 1 bit right and out the right significant inside register to the serial out
      else begin
        {data_reg,data_out} <= {1'b0,data_reg};
        count <= count + 1'b1;
      end
    end
  end
  
  assign data_sent = (count == 4'b1000)?1'b1:1'b0;
 
  
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

//MUX module which generate bit (start/data/parity/stop) according to section number
module mux_tx(input wire data_bit,input wire parity_bit,input wire[2:0] select,output reg mux_out);

  always@(select or data_bit) begin
    case(select)
      3'b000:   mux_out = 1'b1;
      3'b001:   mux_out = 1'b0;
      3'b010:   mux_out = data_bit;
      3'b011:   mux_out = parity_bit;
      3'b100:   mux_out = 1'b1;
      default:  mux_out =  1'b1;
    endcase
  end
endmodule

//Finite State Machine Module
module fsm_tx(
    input wire tx_clk,
    input wire rst_n,
    input wire tx_start,
    input wire tx_enable,
    input wire data_sent,
    output reg [2:0] select,
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
    
    always @(posedge tx_clk or negedge rst_n) begin
      if(~rst_n) begin
        state <= IDLE;
      end
      else begin
        state <= next_state;
      end
    end
    
    always @(state or tx_start or tx_enable or data_sent) begin
      case(state)
            IDLE       : begin
                if (tx_start  & tx_enable) begin
                    next_state <= START_BIT;
                end 
            end
            START_BIT    : begin
                next_state   <= DATA_BIT;
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
    
    always @(state or tx_start or tx_enable ) begin
        case (state)
            IDLE            : begin
                select        <= 3'b000;
                load          <= 1'b1;
                parity_enable <= 1'b0;
                done          <= 1'b0;
                busy          <= 1'b0;
            end
            START_BIT  : begin
                select        <= 3'b001;
                load          <= 1'b0;
                parity_enable <= 1'b1;
                done          <= 1'b0;
                busy          <= 1'b1;
            end
            DATA_BIT  : begin // Wait 8 clock cycles for data bits to be sent
                select        <= 3'b010;
                load          <= 1'b0;
                parity_enable <= 1'b1;
                done          <= 1'b0;
                busy          <= 1'b1;
            end
            PARITY_BIT   : begin // Send out parity bit (even parity)
                select        <= 3'b011;
                load          <= 1'b1;
                parity_enable <= 1'b1;
                done          <= 1'b0;
                busy          <= 1'b1;
            end
            STOP_BIT   : begin // Send out Stop bit (high)
                select        <= 3'b100;
                load          <= 1'b1;
                parity_enable <= 1'b0;
                done          <= 1'b1;
                busy          <= 1'b0;
            end
            default     : begin
                select        <= 3'b000;
                load          <= 1'b1;
                parity_enable <= 1'b0;
                done          <= 1'b0;
                busy          <= 1'b0;
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
    output wire       tx_data_out,  // out of mux
    output wire        done,         // end on transaction
    output wire        busy          // transaction is in process
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
 piso t2(.tx_clk(tx_clk),.rst_n(rst_n),.load(load),.data_in(tx_data_in),.data_out(data_bit),.data_sent(data_sent));
 parity_generator t3(.parity_enable(parity_enable),.data(tx_data_in),.parity(parity_bit));
 mux_tx t4(.data_bit(data_bit),.parity_bit(parity_bit),.select(select),.mux_out(tx_data_out));
    
endmodule