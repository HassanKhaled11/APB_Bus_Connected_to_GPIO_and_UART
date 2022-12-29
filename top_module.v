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
  
  output wire                    top_SLVERR_out ,
  output wire [DATA_WIDTH-1:0]   top_DATA_out   ,      // wire so that the output can'y be controlled from outside source
  output wire                    top_UART_tx    
  
  );


  
  wire [DATA_WIDTH-1:0]   data_read;
  wire                    ready;
  wire                    slave_error;
  wire [ADDR_WIDTH-1:0]   address;
  wire [SLAVES_NUM-1:0]   select;
 // wire                    enable; 
  wire                    write_flag;
  wire [DATA_WIDTH-1:0]   data_write;
  wire [STROBE_WIDTH-1:0] strobe;
  wire [2:0]              protection;
  
   
   
  
  
  APB_bus #(.DATA_WIDTH(DATA_WIDTH),
  .ADDR_WIDTH(ADDR_WIDTH),
  .STROBE_WIDTH(STROBE_WIDTH),
  .SLAVES_NUM(SLAVES_NUM))
  APB_bus_1(.PCLK(CLK) ,
   .PRESETn(RST) ,
   .ADDR_in(top_ADDR_in),
   .DATA_in(top_DATA_in),
   .PROT_in(top_PROT_in),
   .SEL_in(top_SEL_in),
   .STROB_in(top_STROB_in),
   .Transfer(top_Transfer),
   .WRITE_in(top_WRITE_in),
   .PRDATA(data_read),
   .PREADY(ready),
   .PSLVERR(slave_error),
   .SLVERR_out(top_SLVERR_out),
   .DATA_out(top_DATA_out),
   .PADDR(address),
   .PSEL(select),
   .PWRITE(write_flag),
   .PWDATA(data_write),
   .PSTRB(strobe),
   .PPROT(protection)); // coninue.....
  
  
  
  
   Uart#(
  
     CLOCK_RATE,
     BAUD_RATE 
     
    ) UART_1 (
     
    .clk(CLK),
    .pAdd(address),      //Is not used
    .pwData(data_write),
    .rst_n(RST),
    .pwr(write_flag),
    .psel(select),       //If psel == 2'b10 then UART is choose
    .pen(1),  
    .rxd(top_UART_rx),                //delete it 
    .prdata(data_read),
    .pready(ready),
    .txd(top_UART_tx) ,
    .err_out(slave_error));
  
  
endmodule