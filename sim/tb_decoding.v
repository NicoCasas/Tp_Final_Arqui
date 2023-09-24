`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
// 
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_decoding();

// params
parameter NB_DATA    = 32;
parameter N_ADDRESS  = 64;
parameter NB_ADDRESS = 32;
parameter T = (41.67 * 2);

parameter NB_CONTROL_EX     =  5;
parameter NB_CONTROL_MA     =  5;
parameter NB_CONTROL_WB     =  2;
parameter NB_CONTROL_BUS    = (NB_CONTROL_EX+NB_CONTROL_MA+NB_CONTROL_WB);
parameter NB_ALU_OP         =  6;

parameter NB_DATA_REGISTERS = 32;

parameter N_REGISTERS = 32;
parameter NB_ADDR_REGISTERS = $clog2(N_REGISTERS);

parameter NB_INSTRUCTIONS = 32;

parameter INIT_FILE = "file_to_test_id.mem";

// general
reg clk  =0;
reg reset=1;
integer i;

// if
//OUTPUTS 
wire [NB_DATA-1:0]      instruction   ;
wire [NB_ADDRESS-1:0]   next_pc       ; 
        
//INPUTS
reg                    branch       = 1'b0;
reg [NB_ADDRESS-1:0]   branch_addr  = 0 ;
    
reg                    stall        = 1'b1 ;
    

//id
wire [NB_DATA_REGISTERS-1:0]    o_bus_a;
wire [NB_DATA_REGISTERS-1:0]    o_bus_b;

wire [NB_ADDR_REGISTERS-1:0]    o_rs_num;
wire [NB_ADDR_REGISTERS-1:0]    o_rt_num;
wire [NB_ADDR_REGISTERS-1:0]    o_rd_num;
    
wire [NB_DATA          -1:0]    o_ext_literal   ;
wire [NB_DATA          -1:0]    o_ext_sa        ;

wire [NB_CONTROL_BUS-1 : 0]     o_control_bus   ;
wire [NB_ALU_OP     -1 : 0]     o_alu_op        ;
    
// Referido a un stall
wire                            o_if_stall          ;
    
    // Referido a un branch
wire [NB_ADDRESS-1:0]           o_if_branch_addr    ;
wire                            o_if_branch         ;
    
    //INPUTS
        
//from execution
reg [NB_ADDR_REGISTERS-1:0]    ex_rt = 0             ;
reg                            ex_ctl_mem_read = 0   ;  
    
    //from write_back
reg [NB_DATA_REGISTERS-1:0]    wb_reg_data = 0       ;
reg [NB_ADDR_REGISTERS-1:0]    wb_reg_addr = 0       ;
reg                            wb_reg_en  = 0        ;




// Module instantiation

// if instantiation
instruction_fetch
#(
//    .N_ADDRESS(N_ADDRESS)//,
    //.INIT_FILE  (INIT_FILE)
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

wire [31:0] ext_pc;
assign ext_pc = {{(32-NB_ADDRESS),{1'b0}},next_pc};
// id instantiation
instruction_decoder
#(
//    .N_ADDRESS(N_ADDRESS)
)
uut_instruction_decoder
(
    //OUTPUTS
    .o_bus_a(o_bus_a) ,
    .o_bus_b(o_bus_b) ,

    .o_rs_num(o_rs_num),
    .o_rt_num(o_rt_num),
    .o_rd_num(o_rd_num),
    
    .o_ext_literal(o_ext_literal)   ,
    .o_ext_sa     (o_ext_sa)        ,

    .o_control_bus(o_control_bus)   ,
    .o_alu_op     (o_alu_op)        ,
    
    // Referido a un stall
    .o_if_stall   (o_if_stall)      ,
    
    // Referido a un branch
    .o_if_branch_addr (o_if_branch_addr) ,
    .o_if_branch      (o_if_branch) ,
    
    //INPUTS
    
    //from instruction_fetch
    .i_instruction    (instruction) ,
    .i_pc             (ext_pc) ,
    
    //from execution
    .i_ex_rt            (ex_rt) ,
    .i_ex_ctl_mem_read  (ex_ctl_mem_read) ,  
    
    //from write_back
    .i_wb_reg_data      (wb_reg_data) ,
    .i_wb_reg_addr      (wb_reg_addr) ,
    .i_wb_reg_en        (wb_reg_en)   ,
    
    .i_clk              (clk) ,
    .i_reset            (reset)
);


// Clock
always begin
    #(T/2)
    clk = ~clk;
end

// simulation
initial begin
    #(1.5*T)
    reset = 1'b0;
    
    // Cargar los registros
    for(i=1;i<32;i=i+1) begin
        #T
        wb_reg_addr = i;
        wb_reg_data = i + 64;
        wb_reg_en = 1'b1; 
    end
    
    #T
    wb_reg_en = 1'b0;
    stall = 1'b0;
    
    #(40*T)
    $finish;
    
    
end

endmodule
