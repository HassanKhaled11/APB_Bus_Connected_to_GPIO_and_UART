`timescale  1ns / 1ns

module tb_GPIO_APB;

// GPIO_APB Parameters
parameter PERIOD  = 50;


// GPIO_APB Inputs
reg   PCLK                                 = 0 ;
reg   [31:0]  PADDR                        = 0 ;
reg   [31:0]  PWDATA                       = 0 ;
reg   PRESETn                              = 0 ;
reg   PWRITE                               = 1 ;
reg   [1:0]  PSEL                          = 2'b01 ;
reg   [2:0]  PPROT                         = 0 ;

// GPIO_APB Outputs
wire  [31:0]  PRDATA                       ;
wire  PREADY                               ;
wire  PSLVERR                              ;

// GPIO_APB Bidirs
wire  [7:0]  PINS                          ;


initial
begin
    forever #(PERIOD/2)  PCLK=~PCLK;
end

initial
begin
    #(PERIOD*2) PRESETn  =  1;
    
    // TEST CASE 1 => writing on DIR Reg (0000 1111) 0 for input and 1 for output
    PADDR = 2'b10;
    PWDATA = 15;
    #(PERIOD*6); // wait 6 clock cycles to see the changes affecting PINS, Should be (XXXX 0000)
    
    // TEST CASE 2 => writing on PORT Reg (1011 0111) 
    PADDR = 2'b11;
    PWDATA = 7;
    #(PERIOD*6); // wait 6 clock cycles to see the changes affecting PINS, Should be (XXXX 0111)

    
    // TEST CASE 3 => reading from DIR Reg (Pin Direction)
    PWRITE =  0;
    PADDR = 2'b10;
    #(PERIOD*6); // wait 6 clock cycles to see the changes affecting top_DATA_out, Should be (0000 1111)

end

GPIO_APB  u_GPIO_APB (
    .PCLK                    ( PCLK            ),
    .PADDR                   ( PADDR    [31:0] ),
    .PWDATA                  ( PWDATA   [31:0] ),
    .PRESETn                 ( PRESETn         ),
    .PWRITE                  ( PWRITE          ),
    .PSEL                    ( PSEL     [1:0]  ),
    .PPROT                   ( PPROT    [2:0]  ),

    .PRDATA                  ( PRDATA   [31:0] ),
    .PREADY                  ( PREADY          ),
    .PSLVERR                 ( PSLVERR         ),

    .PINS                    ( PINS     [7:0]  )
);



endmodule