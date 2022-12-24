module top_module #( parameter DATA_WIDTH = 'd32, parameter ADDR_WIDTH = 'd32, parameter STROBE_WIDTH = 'd4, parameter SLAVES_NUM = 2 ,  parameter CLOCK_RATE = 100000000 ,
    parameter BAUD_RATE = 9600)
  (
  
  //--------------- INPUTS -----------------------
  input CLK                                    ,
  input RST                                    ,
  input wire [ADDR_WIDTH-1:0]   top_ADDR_in    ,
  input wire [DATA_WIDTH-1:0]   top_DATA_in    ,
  input wire [2:0]              top_PROT_in    ,
  input wire [SLAVES_NUM-1:0]   top_SEL_in     ,
  input wire [STROBE_WIDTH-1:0] top_STROB_in   ,
  input wire                    top_Transfer   ,     
  input wire                    top_WRITE_in   ,
  input wire                    top_UART_rx    ,
 
  //-----------------OUTPUTS------------------------
  
  output reg                    top_SLVERR_out ,
  output reg [DATA_WIDTH-1:0]   top_DATA_out   ,
  output wire                   top_UART_tx    
  
  );


  
  wire [DATA_WIDTH-1:0]   data_read;
  wire                    ready;
  wire                    slave_error;
  wire [ADDR_WIDTH-1:0]   address;
  wire [SLAVES_NUM-1:0]   select;
  wire                    enable;
  wire                    write_flag;
  wire [DATA_WIDTH-1:0]   data_write;
  wire [STROBE_WIDTH-1:0] strobe;
  wire [2:0]              protection;
  
  
  
   
   
  
  
  APB_bus #(.DATA_WIDTH(DATA_WIDTH),
  .ADDR_WIDTH(ADDR_WIDTH),
  .STROBE_WIDTH(STROBE_WIDTH),
  .SLAVES_NUM(SLAVES_NUM))
  APB_bus_1(CLK ,
   RST ,
   top_ADDR_in,
   top_DATA_in,
   top_PROT_in,
   top_SEL_in,
   top_STROB_in,
   top_Transfer,
   top_WRITE_in,
   data_read,
   ready,
   slave_error,
   top_SLVERR_out,
   top_DATA_out,
   address,
   select,
   enable,
   write_flag,
   data_write,
   strobe,
   protection); // coninue.....
  
  
  
  
   Uart#(
  
     CLOCK_RATE,
     BAUD_RATE 
     
    ) UART_1 (
    
    CLK,
    address,      //Is not used
    data_write,
    RST,
    write_flag,
    select,       //If psel == 2'b10 then UART is choose
    enable,
    data_read,
    ready,
    top_UART_rx,
    top_UART_tx);
  
  
  
  
endmodule