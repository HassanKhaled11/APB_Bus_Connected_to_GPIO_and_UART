`timescale  1ns / 1ns

module tb_top_module;

// top_module Parameters
parameter PERIOD        =  2       ;
parameter DATA_WIDTH    = 'd32     ;
parameter ADDR_WIDTH    = 'd32     ;
parameter STROBE_WIDTH  = 'd4      ;
parameter SLAVES_NUM    = 2        ;
parameter CLOCK_RATE    = 100000000;
parameter BAUD_RATE     = 9600     ;

// top_module Inputs
reg   CLK                                  = 0 ;
reg   RST                                  = 0 ;
reg   [ADDR_WIDTH-1:0]  top_ADDR_in        = 32'd15 ;
reg   [DATA_WIDTH-1:0]  top_DATA_in        = 15 ;
reg   [2:0]  top_PROT_in                   = 0 ;
reg   [SLAVES_NUM-1:0]  top_SEL_in         = 2'b10 ;
reg   [STROBE_WIDTH-1:0]  top_STROB_in     = 0 ;
reg   top_Transfer                         = 1 ;
reg   top_WRITE_in                         = 0 ;
reg   top_UART_rx                          = 1 ;


// top_module Outputs
wire  top_SLVERR_out                       ;
wire  [DATA_WIDTH-1:0]  top_DATA_out       ;
wire  top_UART_tx                          ;


initial
begin
    forever #(PERIOD/2)  CLK=~CLK;
end


initial
begin
    #3 RST  <=  1;
   //  #(PERIOD*2) RST  =  1;
end


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
    .top_UART_tx             ( top_UART_tx                        )
);

initial
begin

    $monitor("CLK=%d , reset = %d , select = %d , pwrite = %d , transfer = %d , top_UART_rx = %d , top_data_out = %d " , CLK , RST , top_SEL_in , top_WRITE_in , top_Transfer ,top_UART_rx , top_DATA_out  );
end


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
  /*------------------------------------------------*/
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
/*------------------------------------------------*/
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
/*------------------------------------------------*/
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


endmodule