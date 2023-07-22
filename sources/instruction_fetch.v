`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2023 18:24:28
// Design Name: 
// Module Name: instruction_fetch
// Project Name: 
// 
//////////////////////////////////////////////////////////////////////////////////


module instruction_fetch
#(
    parameter NB_DATA = 32   ,
    parameter NB_ADDRESS =  6
)
(
    input   wire i_branch   ,
    input   wire [NB_ADDRESS-1:0]  i_branch_addr,
    input   wire i_clk,
    input   wire i_reset,
    
    output  wire [NB_DATA-1:0]      o_instruction   ,
    output  wire [NB_ADDRESS-1:0]   o_next_pc_1     
);

//LOCALPARAMS
localparam Nop = 32'h00000000;

//program counter
reg  [NB_ADDRESS-1:0]   pc;
wire [NB_ADDRESS-1:0]   next_pc;
wire [NB_ADDRESS-1:0]   next_pc_1;
wire [NB_ADDRESS-1:0]   next_pc_2;


//instruction register
reg [NB_DATA-1:0]   ir; 
    
//instanciacion de la memoria de instrucciones
memory_32#()
program_memory(
    i_r_addr(pc),
    o_r_data(ir)
);

//next_pc_1
assign next_pc_1 = pc + 3'b100;

//next_pc_2
assign next_pc_2 = i_branch_addr;

//next_pc
assign next_pc = (i_branch==1'b0) ? next_pc_1 : next_pc_2;  //TODO: Cuando no actualiza, poner

//pc logic
always @(posedge i_clk) begin
    if(i_reset) begin
        pc <= {NB_ADDRESS{1'b0}};
    end
    else begin
        if(i_branch==0) pc <= next_pc;  // No actualiza si hay branch
    end    
end

//OUTPUT ASSIGN
assign o_instruction = (i_branch==1'b0) ? pc : Nop;
assign o_next_pc_1 = next_pc_1;

endmodule
