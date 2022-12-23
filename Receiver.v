/*
 * 8-bit UART Receiver.
 * Able to receive 8 bits of serial data, one start bit, one stop bit.
 * When receive is complete {done} is driven high for one clock cycle.
 * Output data should be taken away by a few clocks or can be lost.
 * When receive is in progress {busy} is driven high.
 * Clock should be decreased to baud rate.
 */
module Receiver (
    input  wire       clk,  // baud rate
    input  wire       rxStart,
    input  wire       in,   // rx
    input  wire       parity_err,
    output reg        parity_en,
    output reg  [7:0] out,  // received data
    output reg        done, // end on transaction
    output reg        busy, // transaction is in process
    output reg        err   // error while receiving data
);

    // states of state machine
    localparam [2:0] RESET         =      3'b000,
                     IDLE          =      3'b001,
                     DATA_BITS     =      3'b010,
                     PARITY        =      3'b011,
                     STOP_BIT      =      3'b100;
    

    reg [2:0] state;
    reg [2:0] bitIdx = 3'b0; // for 8-bit data
    reg [1:0] inputSw = 2'b0; // shift reg for input signal state
    reg [3:0] clockCount = 4'b0; // count clocks for 16x oversample
    reg [7:0] receivedData = 8'b0; // temporary storage for input data



    always @(posedge clk) begin
        inputSw = { inputSw[0], in };

        if (!rxStart) begin
            state = RESET;
        end

        case (state)
            RESET: begin
                out <= 8'b0;
                err <= 1'b0;
                done <= 1'b0;
                busy <= 1'b0;
                bitIdx <= 3'b0;
                clockCount <= 4'b0;
                receivedData <= 8'b0;
                if (rxStart) begin
                    state <= IDLE;
                end
            end

            IDLE: begin
                done <= 1'b0;
                if (clockCount >= 4'b0111) begin
                    state <= DATA_BITS;
                    out <= 8'b0;
                    bitIdx <= 3'b0;
                    clockCount <= 4'b0;
                    receivedData <= 8'b0;
                    busy <= 1'b1;
                    err <= 1'b0;
                end else if (!(&inputSw) || |clockCount) begin
                    // Check bit to make sure it's still low
                    if (&inputSw) begin
                        err <= 1'b1;
                        state <= RESET;
                    end
                    clockCount <= clockCount + 4'b1;
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
                parity_en <= 1;
                out <= receivedData;  //To send the data to parity checker module
                if(~parity_err)
                  state <= STOP_BIT;
                else
                  state <= RESET;
              end
            else
              clockCount <= clockCount + 4'b1;
            end
            

            /*
            * Baud clock may not be running at exactly the same rate as the
            * transmitter. Next start bit is allowed on at least half of stop bit.
            */
            STOP_BIT: begin
                if (&clockCount || (clockCount >= 4'h8 && !(|inputSw))) begin
                    state <= IDLE;
                    done <= 1'b1;
                    busy <= 1'b0;
                    out <= receivedData;
                    clockCount <= 4'b0;
                end else begin
                    clockCount <= clockCount + 1;
                    // Check bit to make sure it's still high
                    if (!(|inputSw)) begin
                        err <= 1'b1;
                        state <= RESET;
                    end
                end
            end
            default: state <= IDLE;
        endcase
    end
endmodule






module PARITY_CHECK(parity_err, parity_en, rx, rx_data_in, /*parity_data_out*/);
  output reg parity_err;
  //output reg[7:0] parity_data_out;
  input[7:0] rx_data_in;
  reg[7:0] rx_data;
  input wire rx, parity_en;
  
  always@(*) begin
    if(parity_en) begin
      rx_data = rx_data_in;
      if(rx == (^rx_data)) begin
        parity_err = 0;
        //parity_data_out = rx_data;
      end
    else begin
      parity_err = 1'b1;
      //parity_data_out = 8'b0;
    end
  end
else
  parity_err = 0;
  end
endmodule


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



