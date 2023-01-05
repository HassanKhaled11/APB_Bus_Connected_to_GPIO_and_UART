module GPIO_APB(
                  input wire PCLK,
                  input wire [31:0] PADDR,
                  input wire [31:0] PWDATA,
                  input wire PRESETn,
                  input wire PWRITE,
                  input wire [1:0] PSEL,
                  input wire [2:0] PPROT,
                  output wire [31:0] PRDATA,
                  output wire PREADY,
                  output wire PSLVERR,
                  inout wire [7:0] PINS
                );
  
  //Intermediate Wires               
  wire [7:0] BUSWDATA;
  wire BUSW;
  wire [1:0] REGSEL;
  wire [7:0] BUSRDATA;
  wire clk;
  wire rst_n;
  
  APB_INTERFACE interface( PCLK,
                           PADDR,
                           PWDATA,
                           PRESETn,
                           PWRITE,
                           PSEL,
                           PPROT,
                           PRDATA,
                           PREADY,
                           PSLVERR,
                           REGSEL,
                           BUSRDATA,
                           clk,
                           rst_n,
                           BUSW,
                           BUSWDATA);
                           

  GPIO gpio(.clk(clk),
            .rst_n(rst_n),
            .BUSW(BUSW),
            .BUSWDATA(BUSWDATA),
            .BUSRDATA(BUSRDATA),
            .REGSEL(REGSEL),
            .pins(PINS)
            );
  
  
  
endmodule