module APB_interface
(
  input wire [31:0] pAdd,    //Is not used
  input wire [31:0] pwData,      
  input wire [1:0] psel,       //if psel == 10 -> choose UART
  input wire pen,
  input wire pwr,             //if pwr == 1 -> enable TX, else enable RX
  input wire rst_n,         
  input wire clk,  
  input wire [7:0] rxData,
  input wire rxDone,           //Indication that receiver received 8 bits
  input wire txDone,           //Indication that transmitter sent 8 bits
  output reg rxStart,    
  output reg txStart,     
  output reg[7:0] txData,   
  output reg[31:0] prdata,
  output reg pready
);

reg [31:0]fifo;    
reg [1:0]count4;       //Indicates that the TX module has read the four bytes from fifo
reg[2:0] state;
reg[2:0] next_state;

localparam [2:0] IDLE            =       3'b000,
                 FIFO_WRITE      =       3'b001,
                 CHECK_FIFO      =       3'b010,
                 TRANSFER        =       3'b011,
                 RECEIVE         =       3'b100,
                 STORE           =       3'b101,
                 BUS_READ        =       3'b110;




always @(posedge clk or ~rst_n) begin
  if(~rst_n)
    state = IDLE;
  else
    state = next_state;
end


always@(state)begin
  case(state)
    IDLE: begin
      if(psel) begin
        if(pwr) next_state = FIFO_WRITE;
        else    next_state = RECEIVE;
      end
    end

    FIFO_WRITE: 
      next_state = CHECK_FIFO;

    CHECK_FIFO: begin
      if(&count4) begin   //if count4 == 2'b11
        next_state <= IDLE;
        count4 <= 0;
      end
      else 
      next_state = TRANSFER;
    end
      

    TRANSFER: begin
      if(txDone)    //Transmitter sent the data 8 bits 
        next_state = CHECK_FIFO;
    end


    RECEIVE: begin
      if(rxDone)     //Receiver received the data 8 bits
        next_state = STORE;
    end


    STORE: begin
      if(&count4)
        next_state = BUS_READ;
      else
        next_state = RECEIVE;
    end

    BUS_READ: 
      next_state = IDLE;

  endcase
end


always@(state) begin
  case(state)
    IDLE: begin
      txStart <= 0;
      rxStart <= 0;
      txData <= 0;
      prdata <= 0;
      fifo <= 0;
    end

    FIFO_WRITE: begin
      fifo <= pwData;
    end


    CHECK_FIFO: begin
      txStart <= 0;
      txData <= fifo[7:0];
      fifo <= fifo >> 8;
      count4 <= count4 + 2'b01;
    end


    TRANSFER: begin
      txStart <= 1;
    end


    RECEIVE: begin
      rxStart <= 1;
    end


    STORE: begin
      rxStart <= 0;
      fifo[7:0] = rxData;
      fifo <= fifo << 8;
      count4 <= count4 + 2'b01;
    end

    BUS_READ: begin
      prdata <= fifo;
    end
  endcase
end
endmodule