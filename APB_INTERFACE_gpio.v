module APB_INTERFACE(     input PCLK, 
                          input [31:0] PADDR,
                          input [31:0] PWDATA,
                          input PRESETn,
                          input PWRITE,
                          input [1:0] PSEL,
                          input [2:0] PPROT,
                          output reg [31:0] PRDATA,
                          output reg PREADY,
                          output reg PSLVERR,
                          output [1:0] REGSEL,
                          input [7:0] BUSRDATA,
                          output clk,
                          output rst_n,
                          output BUSW,
                          output reg [7:0] BUSWDATA);
                          
                          
    parameter [1:0] SELECT = 3'b00, READY = 3'b10, ERROR = 3'b11;
    reg[1:0] state, next_state;
    
    assign clk = PCLK;
    assign rst_n = PRESETn;
    assign BUSW = PWRITE;
    assign REGSEL = PADDR[1:0];
    
    
    always@(posedge PCLK, negedge PRESETn) 
    begin
      if(!PRESETn) state <= SELECT;
      else begin
        state <= next_state; 
      end
    end
    

    always @(PSEL, state) begin
      case(state)
        SELECT:  begin
                if(PSEL == 2'b01) begin
                  PREADY <= 0;
                  PSLVERR <= 0;
                  next_state <= READY;
                  if(PWRITE) BUSWDATA <= PWDATA[7:0];
                  else PRDATA[7:0] <= BUSRDATA;
                end
                else next_state <= SELECT;
               end
              

        READY: begin     
                PREADY <= 1;
                next_state <= SELECT;
               end

        ERROR: begin
                PSLVERR <= 1;
                next_state <= SELECT;
               end
        default: next_state <= SELECT;
      endcase
    end        
endmodule
  