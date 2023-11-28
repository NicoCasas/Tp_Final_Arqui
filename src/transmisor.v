`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module transmisor
#(
    //PARAMETERS
    parameter                       NB_DATA         =   8               ,
    parameter                       NB_STOP         =   2               ,
    parameter                       NB_STOP_TICKS   =   16 * NB_STOP
 )
 (
    //OUTPUTS
    output wire                     o_data                              ,
    output wire                     o_valid                             ,
    //INPUTS
    input  wire                     i_clk                               ,
    input  wire                     i_reset                             ,
    input  wire                     i_tick                              ,
    input  wire                     i_valid                             ,
    input  wire     [NB_DATA-1:0]   i_data                                
  );
  
  //LOCALPARAMS
   localparam  state_1     = 4'b0001           ;
   localparam  state_2     = 4'b0010           ;
   localparam  state_3     = 4'b0100           ;
   localparam  state_4     = 4'b1000           ;
      
  //INTERNAL REGS & WIRES
  reg   [NB_DATA-1:0]   buffer          ;
  reg   [NB_DATA-1:0]   next_buffer     ;
  reg                   reg_data        ;
  reg                   next_reg_data   ;
  reg   [5-1:0]         cnt             ;           ////////////////////VER EL TAMAÑO
  reg   [5-1:0]         next_cnt        ;           
  reg   [3-1:0]         n_bit           ;           ////////////////////IGUAL
  reg   [3-1:0]         next_n_bit      ;
  reg   [4-1:0]         state           ;
  reg   [4-1:0]         next_state      ;
  reg                   aux_valid       ;        
  reg                   aux_valid_reg   ;
  
  //MEMORY
    always @(posedge i_clk) begin
        if(i_reset) begin
            state           <=  state_1         ;
            n_bit           <=  0               ;
            cnt             <=  0               ;
            reg_data        <=  1'b1            ;
            buffer          <=  0               ;
            aux_valid_reg   <=  0               ;
        end
        else begin
            state           <=  next_state     ;
            n_bit           <=  next_n_bit     ;
            cnt             <=  next_cnt       ;
            reg_data        <=  next_reg_data  ;
            buffer          <=  next_buffer    ;
            aux_valid_reg   <= aux_valid       ;
        end
    end 

//NEXT STATE LOGIC
    always @(*) begin
        next_state    = state           ;
        next_n_bit    = n_bit           ;
        next_cnt      = cnt             ;
        next_reg_data = reg_data        ;
        next_buffer   = buffer          ;
        aux_valid     = aux_valid_reg   ;
        case(state)
        
            state_1 : 
            begin
                        aux_valid     = 1'b1;
                        next_reg_data = 1'b1;
                        if(i_valid)begin 
                                aux_valid       = 1'b0      ;       
                                next_cnt        = 0         ;
                                next_state      = state_2   ;
                                next_buffer     = i_data    ;
                        end
            end
                      
            state_2 : 
            begin
                        next_reg_data = 1'b0;
                        if(i_tick) begin
                            if(cnt==15) begin

                                 next_cnt    = 0         ;
                                 next_n_bit  = 0         ;
                                 next_state  = state_3   ;
                            end
                            else next_cnt    = cnt + 1   ;
                        end
            end
                      
            state_3 : begin
                         next_reg_data = buffer[n_bit];
                         if(i_tick) begin
                            if(cnt==15) begin
                                next_cnt        = 0         ;
                                
                                if(n_bit==NB_DATA-1) begin
                                    next_state = state_4    ;
                                end
                                else begin
                                    next_n_bit = n_bit + 1  ;
                                end
                            end    
                            
                            else    next_cnt = cnt + 1'b1   ;

                         end
            end
                      
            state_4 : begin
                        next_reg_data = 1'b1                ;
                        if(i_tick) begin
                            if(cnt==NB_STOP_TICKS-1)begin
                                next_state  = state_1       ;
                            end
                            else next_cnt = cnt + 1'b1      ;
                        end         
            end
            
            default:   next_state=state_1;
        endcase 
    end


  //OUTPUT ASSIGN
  assign o_data  = reg_data         ;
  assign o_valid = aux_valid_reg    ;
    
endmodule
