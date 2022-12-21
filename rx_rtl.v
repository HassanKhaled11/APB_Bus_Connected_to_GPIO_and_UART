`timescale 1us/1us

module RX(rst_n, clk, rx, rx_out, parity_err);

input rst_n, clk, rx;
output [10:0]rx_out;
output parity_err;
reg store;
wire sipo_en, detect_start, stop_check, parity_en;
wire[7:0] sipo_data_out, parity_out;

SIPO_8BIT sipo_8bit(.sipo_en(sipo_en), .rx(rx), .clk(clk), .rst_n(rst_n), .sipo_data_out(sipo_data_out));
FSM_RX fsm_rx(.sipo_en(sipo_en), .rx(rx), .clk(clk), .rst_n(rst_n));
DETECT_START_BIT detect_start_bit(.clk(clk), .rx(rx), .detect_start(detect_start));
PARITY_CHECK parity_check(.parity_err(parity_err), .parity_en(parity_en), .rx(rx), .rx_data_in(sipo_data_out), .parity_data_out(parity_data_out));

endmodule








module SIPO_8BIT(sipo_en, rx, clk, rst_n, sipo_data_out);
  input sipo_en, rx, clk, rst_n;
  output [7:0] sipo_data_out;
  reg [7:0]shift_reg;
  
  always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
      shift_reg <= 0;
    else if(sipo_en)
      begin
      shift_reg <= (shift_reg >> 1);
      shift_reg[7] <= rx;
      end
    else
      shift_reg <= shift_reg;
  end
  assign sipo_data_out = shift_reg;
endmodule


/*Test bench of SIPO (Serial in parallel out shift register)*/
module TB_SIPO_8BIT();
  reg clk, rst_n, sipo_en, rx;
  SIPO_8BIT sipo_8bit(.sipo_en(sipo_en), .rx(rx), .clk(clk), .rst_n(rst_n));
  
  always #1 clk = ~clk;
  
  initial begin
    clk = 0; sipo_en = 0; rx = 1; rst_n = 0;
    #3 rst_n = 1;
    #2 rx = 0;
    #2 sipo_en = 1; rx = 1; 
    #2 rx = 0;
    #2 rx = 1;
    #2 rx = 0;
    #2 rx = 1;
    #2 rx = 0;
    #2 rx = 1; 
    #2 sipo_en = 0;
  end
endmodule








module FSM_RX(sipo_en, rx, clk, rst_n, detect_start);
  
  input rx, clk, rst_n, detect_start;
  output reg sipo_en;
  reg store;
  
  parameter IDLE           =    3'd0,
            COUNT_16       =    3'd1,
            SHIFT          =    3'd2,
            STORE_IN_FIFO  =    3'd3,
            RX_DONE        =    3'd4;
            
  wire rx_start;
  reg [3:0] bit_count, count_16;
  reg state;
  always@(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    state <= IDLE;
    store <= 0;
    sipo_en <= 0;
  end
  else begin
    case(state)
      IDLE: 
        if(detect_start) 
          state <= COUNT_16;          
      COUNT_16:
        if(count_16 == 4'b1111) begin
            state <= SHIFT;
            count_16 <= 4'b0000;
            sipo_en <= 1'b1;
        end
        else begin
          count_16 <= count_16 + 4'd1;        
          sipo_en <= 1'b0;
        end
      SHIFT:
        if(bit_count >= 4'd11) begin
          
          state <= STORE_IN_FIFO;
          sipo_en <= 1'b0;
          
        end
        else begin
          bit_count <= bit_count + 4'd1;
          state <= COUNT_16;
          sipo_en <= 1'b1;
        end
    
      STORE_IN_FIFO:        
        if(store) begin
         state <= RX_DONE;
         store <= 0;
       end
     else
       store <= 1;     //APB interface should take the data
      
      RX_DONE:
        state <= IDLE;
        
    endcase 
  end 
end
endmodule



module TB_FSM_RX();
  reg rx, clk, rst_n, store, detect_start;
  
  FSM_RX fsm_rx(.rx(rx), .clk(clk), .rst_n(rst_n), .detect_start(detect_start));
  
  always #1 clk = ~clk;
  
  initial begin
    clk <= 0; rst_n <= 0; store <= 0; detect_start <= 0;
    #3 rst_n = 1;
    #2 rx <= 0; detect_start <= 1;
    #18 rx = 1;
    #16 rx = 0;
    #16 rx = 1;
    #16 rx = 0;
    #16 rx = 1;
    #16 rx = 0;
    #16 rx = 1;
    #16 rx = 0;
    #16 rx = 1;    
  end
endmodule




module DETECT_START_BIT(clk, rx, detect_start);
  input clk, rx;
  output reg detect_start;
  
  always@(posedge clk) begin
  if(rx == 1'b0 && detect_start == 1'b0)
   detect_start <= 1'b1;
  else detect_start <= detect_start;
  end
endmodule


module TB_DETECT_START_BIT();
  reg clk, rx;
  wire detect_start;
  DETECT_START_BIT detect_start_bit(.clk(clk), .rx(rx), .detect_start(detect_start));
  always #1 clk = ~clk;
  initial begin
    clk = 0; rx = 1;
    #3 rx = 0;
  end
endmodule


module PARITY_CHECK(parity_err, parity_en, rx, rx_data_in, parity_data_out);
  output reg parity_err;
  output reg[7:0] parity_data_out;
  input[7:0] rx_data_in;
  reg[7:0] rx_data;
  input rx, parity_en;
  
  always@(*) begin
    if(parity_en) begin
      rx_data = rx_data_in;
      if(rx == (^rx_data)) begin
        parity_err = 0;
        parity_data_out = rx_data;
      end
    else begin
      parity_err = 1'b1;
      parity_data_out = 8'b0;
    end
  end
else
  parity_err = 0;
  end
endmodule

