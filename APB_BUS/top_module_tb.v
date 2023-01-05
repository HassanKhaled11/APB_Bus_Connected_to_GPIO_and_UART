`timescale  1ns / 1ns

module tb_top_module;

// top_module Parameters
parameter PERIOD        = 2     ;
parameter DATA_WIDTH    = 'd32     ;
parameter ADDR_WIDTH    = 'd32     ;
parameter STROBE_WIDTH  = 'd4      ;
parameter SLAVES_NUM    = 2        ;
parameter CLOCK_RATE    = 100000000;
parameter BAUD_RATE     = 9600     ;



// top_module Inputs

reg   CLK                                  = 0 ;
reg   RST                                  = 0 ;
reg   [ADDR_WIDTH-1:0]  top_ADDR_in        = 0 ;
reg   [DATA_WIDTH-1:0]  top_DATA_in        = 0 ;
reg   [2:0]  top_PROT_in                   = 0 ;
reg   [SLAVES_NUM-1:0]  top_SEL_in         = 2'b01 ;
reg   [STROBE_WIDTH-1:0]  top_STROB_in     = 0 ;
reg   top_Transfer                         = 1 ;
reg   top_WRITE_in                         = 1 ;
reg   top_UART_rx                          = 0;


// top_module Outputs
wire  top_SLVERR_out                           ;
wire  [DATA_WIDTH-1:0]  top_DATA_out           ;
wire  top_UART_tx                              ;
wire  [7:0] PINS                               ;

initial
begin
    forever #(PERIOD/2)  CLK=~CLK              ;
end

/*
top_module #(
    .DATA_WIDTH   ( DATA_WIDTH   ),
    .ADDR_WIDTH   ( ADDR_WIDTH   ),
    .STROBE_WIDTH ( STROBE_WIDTH ),
    .SLAVES_NUM   ( SLAVES_NUM   ),
    .CLOCK_RATE   ( CLOCK_RATE   ),
    .BAUD_RATE    ( BAUD_RATE    ))
 u_top_module (
    .CLK                     ( CLK                                ),
    .RST                     ( RST                                ),
    .top_ADDR_in             ( top_ADDR_in     [ADDR_WIDTH-1:0]   ),
    .top_DATA_in             ( top_DATA_in     [DATA_WIDTH-1:0]   ),
    .top_PROT_in             ( top_PROT_in     [2:0]              ),
    .top_SEL_in              ( top_SEL_in      [SLAVES_NUM-1:0]   ),
    .top_STROB_in            ( top_STROB_in    [STROBE_WIDTH-1:0] ),
    .top_Transfer            ( top_Transfer                       ),
    .top_WRITE_in            ( top_WRITE_in                       ),
    .top_UART_rx             ( top_UART_rx                        ),
    
    .top_SLVERR_out          ( top_SLVERR_out                     ),
    .top_DATA_out            ( top_DATA_out    [DATA_WIDTH-1:0]   ),
    .top_UART_tx             ( top_UART_tx                        ),
    .GPIO_PINS               ( PINS            [7:0]              )
);

*/


initial
begin
     #3  RST= 1;
end


initial
begin
    #(PERIOD*2) RST  =  1;
    //TESTING GPIO
    
    // TEST CASE 1 => writing on DIR Reg (0000 1111) 0 for input and 1 for output
    top_ADDR_in = 2'b10;
    top_DATA_in = 15;
    #(PERIOD*6); // wait 6 clock cycles to see the changes affecting PINS, Should be (0000 0000)
    
    // TEST CASE 2 => writing on PORT Reg (0111) 
    top_ADDR_in = 2'b11;
    top_DATA_in = 7;
    #(PERIOD*6); // wait 6 clock cycles to see the changes affecting PINS, Should be (0000 0111)

    force PINS [7:4] = 4'b1101;  // Input DATA TO GPIO, PINS Should be(1101 0111)
    #(PERIOD*2);
    
    // TEST CASE 3 => reading from DIR Reg (Pin Direction)
    top_WRITE_in =  0;
    top_ADDR_in = 2'b10;
    #(PERIOD*6); // wait 6 clock cycles to see the changes affecting top_DATA_out, Should be (0000 1111)
    
    // TEST CASE 4 => reading from PORT Reg (Output Pins)
    top_WRITE_in =  0;
    top_ADDR_in = 2'b11;
    #(PERIOD*6); // wait 6 clock cycles to see the changes affecting top_DATA_out, Should be (xxxx 0111)
    
    
    // TEST CASE 5 => reading from PINS (All Pins)
    top_WRITE_in =  0;
    top_ADDR_in = 2'b00;
    #(PERIOD*6); // wait 6 clock cycles to see the changes affecting top_DATA_out, Should be (1101 0111)
    
end



initial
begin

 //   $monitor("CLK=%d , ready = %d , select = %d ,top_data_in = %d , pins = %d",CLK , ready , top_SEL_in , top_DATA_in , PINS  );
end

/*
initial begin
  
  #32 top_UART_rx <= 0;   //Start bit
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;    //Parity bit (no error)
  #32 top_UART_rx = 1;    //Stop bit (no error)
  /////////////////////////////////////////////////////////
  #36 top_UART_rx = 0;   //Start bit
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;    //Parity bit (no error)
  #32 top_UART_rx = 1;    //Stop bit (no error)
//////////////////////////////////////////////////////////
  #40 top_UART_rx = 0;   //Start bit
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;    //Parity bit (no error)
  #32 top_UART_rx = 1;    //Stop bit (no error)
///////////////////////////////////////////////////////
  #44 top_UART_rx = 0;   //Start bit
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;   
  #32 top_UART_rx = 1;
  #32 top_UART_rx = 0;    //Parity bit (no error)
  #32 top_UART_rx = 1;    //Stop bit (no error)

end

*/


endmodule