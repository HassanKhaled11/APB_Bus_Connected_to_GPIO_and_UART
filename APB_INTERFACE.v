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
                          
                          
    parameter [2:0] IDLE = 3'b000, START = 3'b001, READ = 3'b010, WRITE = 3'b011, READY = 3'b100, ERROR = 3'b101;
    reg[2:0] state, next_state;
    
    assign clk = PCLK;
    assign rst_n = PRESETn;
    assign BUSW = PWRITE;
    assign REGSEL = PADDR[1:0];
    
    
    always@(posedge PCLK, negedge PRESETn) begin
      if(!PRESETn) state <= IDLE;
      else begin
        state <= next_state; 
      end
    end
    

    always @(PSEL, state) begin
      case(state)
        IDLE:  begin
                if(PSEL == 2'b01) begin
                  PREADY <= 0;
                  PSLVERR <= 0;
                  next_state <= START;
                end
                else next_state <= IDLE;
               end
        
        START: begin
                if(PWRITE) BUSWDATA <= PWDATA[7:0];
                  else PRDATA[7:0] <= BUSRDATA;
                next_state <= READY;
               end
              

        READY: begin     
                PREADY <= 1;
                next_state <= IDLE;
               end

        ERROR: begin
                PSLVERR <= 1;
                next_state <= IDLE;
               end
        default: next_state <= IDLE;
      endcase
    end        
endmodule
  