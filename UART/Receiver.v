

/*
 * 8-bit UART Receiver.
 * Able to receive 8 bits of serial data, one start bit, one stop bit.
 * When receive is complete {done} is driven high for one clock cycle.
 * Output data should be taken away by a few clocks or can be lost.
 * When receive is in progress {busy} is driven high.
 * Clock should be decreased to baud rate.
 */
module Receiver (
    input  wire       clk,            // baud rate
    input  wire       rxStart,        //Start receiving 
    input  wire       rx_en,             // Enable the receiver module
    input  wire       in,             // rx
    input  wire       rst_n,          //reset the module
    output reg  [7:0] out,            // received data
    output reg        done,           // end on transaction
    output reg        busy,           // transaction is in process
    output wire       err             // error in data
);


    // states of state machine
    localparam [2:0] RESET         =      3'b000,
                     IDLE          =      3'b001,
                     DATA_BITS     =      3'b010,
                     PARITY        =      3'b011,
                     STOP_BIT      =      3'b100;
    

    reg [2:0] state = RESET;
    reg [2:0] bitIdx = 3'b0; // for 8-bit data
    reg [1:0] inputSw = 2'b0; // shift reg for input signal state
    reg [3:0] clockCount = 4'b0; // count clocks for 16x oversample
    reg [7:0] receivedData = 8'b0; // temporary storage for input data
    reg errorCheck_en = 0;


    /*Inistance from Parity checker module*/
    ERROR_CHECK error_check(.errorCheck_en(errorCheck_en), .rx(in), .rx_data_in(receivedData),
                              .err(err), .state(state));                             


    always @(posedge clk or ~rst_n) begin
      if(rx_en) begin
        inputSw = { inputSw[0], in };
         if (!rxStart) begin
             state <= RESET;
         end

        case (state)
            RESET: begin
                out <= 0;
                done <= 0;
                busy <= 0;
                bitIdx <= 0;
                clockCount <= 0;
                receivedData <= 0;
                
                if (rxStart) begin
                    state <= IDLE;
                end
            end

            IDLE: begin
                done <= 1'b0;
                if (&clockCount) begin
                    state <= DATA_BITS;
                    out <= 8'b0;
                    bitIdx <= 3'b0;
                    clockCount <= 4'b0;
                    receivedData <= 8'b0;
                    busy <= 1'b1;                    

                end else if (!(&inputSw) || |clockCount) begin
                    // Check bit to make sure it's still low
                    if (&inputSw) begin
                        state <= RESET;
                    end begin
                    errorCheck_en <= 0;
                    clockCount <= clockCount + 4'b1;
                    end
                end
            end

            // Wait 8 full cycles to receive serial data
            DATA_BITS: begin
                if (&clockCount) begin // save one bit of received data
                    clockCount <= 4'b0;
                    // TODO: check the most popular value
                    receivedData[bitIdx] <= inputSw[0];
                    if (&bitIdx) begin
                        bitIdx <= 3'b0;
                        state <= PARITY;
                    end else begin
                        bitIdx <= bitIdx + 3'b1;
                    end
                end else begin
                    clockCount <= clockCount + 4'b1;
                end
            end
  

            PARITY: begin
              if(&clockCount) begin                
                clockCount <= 0;              
                if(~err) begin   
                  errorCheck_en <= 0;               
                  state <= STOP_BIT;
                end
                else  
                /*There is parity err*/                                   
                  state <= RESET;    
              end
            else begin
              clockCount <= clockCount + 4'b1;
              if(clockCount >= 4'b1101) errorCheck_en <= 1;
            end
          end
            

            /*
            * Baud clock may not be running at exactly the same rate as the
            * transmitter. Next start bit is allowed on at least half of stop bit.
            */
            STOP_BIT: begin
                if (&clockCount || (clockCount >= 4'h8 && !(|inputSw/*Next start bit came*/))) begin   
                    state <= IDLE;
                    done <= 1'b1;
                    busy <= 1'b0;
                    out <= receivedData;
                    clockCount <= 4'b0;
                end
                else begin                               
                  clockCount <= clockCount + 1;
                  // Check bit to make sure it's still high
                  if (!(|inputSw)) begin
                    //Stop bit error
                    errorCheck_en <= 1;                    
                    state <= RESET;     
                  end
                end
            end
            default: state <= IDLE;
        endcase
      end
    end
endmodule



module ERROR_CHECK(err, errorCheck_en, rx, rx_data_in, state);
  input wire[7:0] rx_data_in;
  input wire rx, errorCheck_en;
  input wire[2:0] state;
  output reg err;

  
  // states of state machine
  localparam [2:0]  RESET         =      3'b000,
                    IDLE          =      3'b001,
                    DATA_BITS     =      3'b010,
                    PARITY        =      3'b011,
                    STOP_BIT      =      3'b100; 

  always@(errorCheck_en) begin    
    if(errorCheck_en) begin
      if(state == STOP_BIT || state == RESET) begin
        err <= 1;
      end
      else if (state == PARITY)begin
        if(rx == (^rx_data_in)) begin   //Even Parity check
          err <= 0;
        end
        else begin
          err <= 1;
        end
      end
      else
        err <= err;
    end
    else
      err <= 0;
  end
endmodule


