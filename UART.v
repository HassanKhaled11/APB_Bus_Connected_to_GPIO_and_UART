module Uart#(
    parameter CLOCK_RATE = 100000000, // board internal clock
    parameter BAUD_RATE = 9600
)(
    input wire clk,
    input wire[31:0] pAdd,      //Is not used
    input wire[31:0] pwData,
    input wire rst_n,
    input wire pwr,
    input wire[1:0] psel,       //If psel == 2'b10 then UART is choose
    input wire pen,
    input wire[31:0] prdata,
    input wire pready,
    input wire rxd,
    output reg txd
);
wire txStart, rxStart, rxDone, txDone, tx_data_out, busy;
wire [7:0] txData, rxData;


// remaining busy, err, parity_err, parity_en
Receiver rxInst (.clk(clk), .rxStart(pen), .done(rxDone), .out(rxData), .in(rxd)); 

//remaining busy
/*transmitter txInst (.tx_clk(clk), .rst_n(rst_n), .tx_start(txStart), .tx_enable(pen), .tx_data_in(txData),
                   .done(txDone), .busy(busy), .tx_data_out(tx_data_out));*/

APB_interface apb_interface(.pAdd(pAdd), .pwData(pwData), .psel(psel), .pen(pen), .pwr(pwr), .rst_n(rst_n),
                            .clk(clk), .prdata(prdata), .pready(pready), .txStart(txStart), .txData(txData),
                            .rxData(rxData), .txDone(txDone), .rxDone(rxDone), .rxStart(rxStart));
endmodule