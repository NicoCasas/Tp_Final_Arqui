`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
// 
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_instruction_fetch();

localparam T = 41.67*2;

localparam INIT_FILE = "file_to_test_if.mem";
localparam NB_DATA = 32;
localparam NB_ADDRESS = 6;

//OUTPUTS 
wire [NB_DATA-1:0]      instruction   ;
wire [NB_ADDRESS-1:0]   next_pc       ; 
        
//INPUTS
reg                    branch  = 1'b0;
reg [NB_ADDRESS-1:0]   branch_addr   ;
    
reg                    stall   = 1'b0 ;
    
reg clk  =0;
reg reset=1;

// Module instantiation
instruction_fetch
#(
    .INIT_FILE  (INIT_FILE)
)
uut_instruction_fetch
(
    //OUTPUTS
    .o_instruction  (instruction)   ,
    .o_next_pc_1    (next_pc)       , 
        
    //INPUTS
    .i_branch       (branch)        ,
    .i_branch_addr  (branch_addr)   ,
    
    .i_stall        (stall)         ,
    
    .i_clk          (clk)           ,
    .i_reset        (reset)
 
);

// Clock
always begin
    #(T/2)
    clk = ~clk;
end

// Sim
initial begin
    #((2.5)*T)
    reset = 1'b0;
    #(5*T)
    stall=1'b1;
    #T
    stall = 1'b0;
    
    #(3*T)
    branch = 1'b1;
    branch_addr = 6'b100;
    #T
    branch = 1'b0;
    branch_addr = 6'b000;
    #(3*T)
    $finish;
end

endmodule
