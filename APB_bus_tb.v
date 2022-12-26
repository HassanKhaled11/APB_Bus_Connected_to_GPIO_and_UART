
`timescale  1ns / 1ns


module tb_APB_bus();
  
// APB_bus Parameters
parameter PERIOD        = 100 ;
parameter DATA_WIDTH    = 'd32;
parameter ADDR_WIDTH    = 'd32;
parameter SLAVES_NUM    = 'd2 ;

parameter STROBE_WIDTH  = 'd4 ;

// APB_bus Inputs
reg   [ADDR_WIDTH-1:0]  ADDR_in            = 0 ;
reg   [DATA_WIDTH-1:0]  DATA_in            = 'hFF000F00 ;
reg   [2:0]  PROT_in                       = 0 ;
reg   [SLAVES_NUM-1:0]  SEL_in             = 2'b10 ;
reg   [STROBE_WIDTH-1:0]  STROB_in         = 'd0;
reg   Transfer                             = 1 ;
reg   WRITE_in                             = 1 ;
reg   PCLK                                 = 0 ;
reg   PRESETn                              = 0 ;
reg   [DATA_WIDTH-1:0]  PRDATA             = 'd500 ;
reg   PREADY                               = 1 ;
reg   PSLVERR                              = 0 ;


// APB_bus Outputs
wire  SLVERR_out                           ;
wire  [DATA_WIDTH-1:0]  DATA_out           ;
wire  [ADDR_WIDTH-1:0]  PADDR              ;
wire  [SLAVES_NUM-1:0]  PSEL               ;
wire  PENABLE                              ;
wire  PWRITE                               ;
wire  [DATA_WIDTH-1:0]  PWDATA             ;
wire  [STROBE_WIDTH-1:0]  PSTRB            ;
wire  [2:0]  PPROT                         ;



initial
begin
    forever #(PERIOD/2)  PCLK=~PCLK;
end





initial
begin
    #(PERIOD*2) PRESETn  =  1;
    #(PERIOD*4.5) PREADY =  1;
    //# (PERIOD*4.5) Transfer = 0;
    
end


APB_bus #(
    .DATA_WIDTH   ( DATA_WIDTH   ),
    .ADDR_WIDTH   ( ADDR_WIDTH   ),
    .STROBE_WIDTH ( STROBE_WIDTH ),
    .SLAVES_NUM   ( SLAVES_NUM   ))
 u_APB_bus (
    .ADDR_in                 ( ADDR_in     [ADDR_WIDTH-1:0]   ),
    .DATA_in                 ( DATA_in     [DATA_WIDTH-1:0]   ),
    .PROT_in                 ( PROT_in     [2:0]              ),
    .SEL_in                  ( SEL_in      [SLAVES_NUM-1:0]   ),
    .STROB_in                ( STROB_in    [STROBE_WIDTH-1:0] ),
    .Transfer                ( Transfer                       ),
    .WRITE_in                ( WRITE_in                       ),
    .PCLK                    ( PCLK                           ),
    .PRESETn                 ( PRESETn                        ),
    .PRDATA                  ( PRDATA      [DATA_WIDTH-1:0]   ),
    .PREADY                  ( PREADY                         ),
    .PSLVERR                 ( PSLVERR                        ),
    .SLVERR_out              ( SLVERR_out                     ),
    .DATA_out                ( DATA_out    [DATA_WIDTH-1:0]   ),
    .PADDR                   ( PADDR       [ADDR_WIDTH-1:0]   ),
    .PSEL                    ( PSEL        [SLAVES_NUM-1:0]   ),
    .PENABLE                 ( PENABLE                        ),
    .PWRITE                  ( PWRITE                         ),
    .PWDATA                  ( PWDATA      [DATA_WIDTH-1:0]   ),
    .PSTRB                   ( PSTRB       [STROBE_WIDTH-1:0] ),
    .PPROT                   ( PPROT       [2:0]              )
);


initial
begin

  $monitor(" pwrite = %d , strob = %d ,pwdata = %d , Data_out = %d , penable = %d , pready = %d , ",PWRITE, STROB_in , PWDATA ,DATA_out,PENABLE,PREADY);


end
endmodule
  