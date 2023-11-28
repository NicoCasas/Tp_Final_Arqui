`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module alu
#(  
    //PARAMETERS
    parameter                       NB_DATA         = 32              ,
    parameter                       NB_ALU_OP       = 6
    
 )
 (
    //OUTPUTS
    output  wire    signed  [NB_DATA   -1 :0]   o_data                      ,
    
    //INPUTS
    input   wire    signed  [NB_DATA   -1 :0]   i_dato_a                    ,
    input   wire    signed  [NB_DATA   -1 :0]   i_dato_b                    ,   
    input   wire            [NB_ALU_OP -1 :0]   i_op   
 );
 
    //LOCALPARAMS
    localparam  op_addu  = 6'b100001;
    localparam  op_subu  = 6'b100011;
    localparam  op_and   = 6'b100100;
    localparam  op_or    = 6'b100101;
    localparam  op_xor   = 6'b100110;
    localparam  op_sra   = 6'b000011;
    localparam  op_srl   = 6'b000010;
    localparam  op_nor   = 6'b100111;
    localparam  op_slt   = 6'b101010;
    localparam  op_lui   = 6'b001111;   //ver si esta ocupado
    localparam  op_jmp   = 6'b001001;
    localparam  op_sll   = 6'b000000;
    localparam  op_sllv  = 6'b000100;
    localparam  op_srav  = 6'b000111;
    localparam  op_srlv  = 6'b000110;
    
    //INTERNAL REGS AND WIRES
    reg    [NB_DATA-1:0]   resultado;
    
    //COMBINATIONAL LOGIC
    always @(*) begin
        case(i_op)
             op_addu :   resultado =     i_dato_a  +  i_dato_b          ;
             op_subu :   resultado =     i_dato_a  -  i_dato_b          ;
             op_and  :   resultado =     i_dato_a  &  i_dato_b          ;
             op_or   :   resultado =     i_dato_a  |  i_dato_b          ;
             op_xor  :   resultado =     i_dato_a  ^  i_dato_b          ;
             op_sra  :   resultado =     i_dato_b >>> i_dato_a          ;
             op_srav :   resultado =     i_dato_b >>> i_dato_a          ;
             op_srl  :   resultado =     i_dato_b  >> i_dato_a          ;
             op_srlv :   resultado =     i_dato_b  >> i_dato_a          ;
             op_nor  :   resultado =   ~(i_dato_a  |  i_dato_b)         ;
             op_sll  :   resultado =     i_dato_b <<  i_dato_a          ;
             op_sllv :   resultado =     i_dato_b <<  i_dato_a          ;
             
             op_slt  :   resultado =     {{(NB_DATA-1){1'b0}}, i_dato_a<i_dato_b}    ;   
             op_lui  :   resultado =     {i_dato_b[15:0],{16{1'b0}}}     ;
             op_jmp  :   resultado =     i_dato_a + {{NB_DATA-3{1'b0}},{3'b100}};
             
             default :   resultado =     {NB_DATA{1'b0}}                ;
        endcase
    end
    
    //OUTPUT ASSIGN
    assign o_data = resultado;
 
 
endmodule
