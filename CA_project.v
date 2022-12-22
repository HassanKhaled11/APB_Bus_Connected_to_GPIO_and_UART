
module APB_bus #( parameter DATA_WIDTH = 'd32, parameter ADDR_WIDTH = 'd32, parameter STROBE_WIDTH = 'd4, parameter SLAVES_NUM = 2)
  (
  
  //--------------- INPUTS -----------------------
  
  input wire [ADDR_WIDTH-1:0]   ADDR_in    ,
  input wire [DATA_WIDTH-1:0]   DATA_in    ,
  input wire [2:0]              PROT_in    ,
  input wire [SLAVES_NUM-1:0]   SEL_in     ,
  input wire [STROBE_WIDTH-1:0] STROB_in   ,
  input wire                    Transfer   ,     
  input wire                    WRITE_in   ,
  input                         PCLK       ,
  input                         PRESETn    , 
  input wire [DATA_WIDTH-1:0]   PRDATA     ,
  input wire                    PREADY     ,
  input wire                    PSLVERR    ,
  
  //-----------------OUTPUTS------------------------
  
  output reg                    SLVERR_out ,
  output reg [DATA_WIDTH-1:0]   DATA_out   ,
  output reg [ADDR_WIDTH-1:0]   PADDR      ,
  output reg [SLAVES_NUM-1:0]   PSEL       ,
  output reg                    PENABLE    ,
  output reg                    PWRITE     ,
  output reg [DATA_WIDTH-1:0]   PWDATA     ,
  output reg [STROBE_WIDTH-1:0] PSTRB      ,
  output reg [2:0]              PPROT      
  );
  
  
  reg [1:0]  state , nextstate ;
  
  localparam IDLE   = 2'b00    ,
             SETUP  = 2'b01    ,
             ACCESS = 2'b10    ;
             
             
             
  always @(posedge PCLK , negedge PRESETn)
  begin
    
    if(!PRESETn)
      begin
      state <= IDLE;
      end
    
    else   
      state <= nextstate;
  end
  
  
  
  
  always @(*)
  begin
    
    case(state)
               IDLE: begin
                   if(Transfer)begin
                   nextstate <= SETUP;
                   end
                   else begin   
                   nextstate <= IDLE;
                   end
               end
                   
                   
               SETUP: begin
                   nextstate <= ACCESS;
               end      
                
                
               ACCESS: begin
                  if(!PSLVERR && Transfer) begin
                    if(PREADY)begin
                    nextstate <= SETUP;
                    end
                    else begin
                    nextstate <= ACCESS;
                    end
                  end
                                 
                  else 
                    nextstate <= IDLE;                             // the slave is ready aand there is not transfer
               end     
                
                
               default: nextstate <= IDLE;
  endcase                      
  end               
    
    
    
    
  always @(posedge PCLK , negedge PRESETn)
  begin
    if(!PRESETn) begin
      PSEL <= 0;
    end
    
    else if(nextstate == IDLE) begin
      PSEL <= 0;
    end
    
    
    else begin
    PSEL <= SEL_in;
    end
     
  end
  
  

    
  always @(posedge PCLK or negedge PRESETn) 
  begin
    if(!PRESETn)begin
      
      PENABLE     <= 1'b0;
      PADDR       <=  'b0;
      PWDATA      <=  'b0;
      PWRITE      <= 1'b0;
      PSTRB       <=  'b0;
      PPROT       <= 3'b0;
      SLVERR_out  <= 1'b0;
      DATA_out    <=  'b0;
      
    end
    
    else if(nextstate == SETUP)begin
     
      PENABLE  <= 1'b0;
      PADDR    <= ADDR_in;
      PWRITE    = WRITE_in;
      PPROT    <= PROT_in;
      
      if(PWRITE)begin
        PWDATA  <= DATA_in;
        PSTRB   <= STROB_in;
      end
      
      else
        PSTRB <= 'b0;
  end
    
  else if(nextstate == ACCESS)begin
      
      PENABLE   <= 1'b1     ;

      if(PREADY)begin
          SLVERR_out <= PSLVERR;
       
        if(!PWRITE)begin
          DATA_out <= PRDATA ;
        end
       end
  end
      
  
  else PENABLE <= 1'b0 ;
     
 end
endmodule                

