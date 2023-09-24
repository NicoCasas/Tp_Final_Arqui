`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 19.09.2023 19:21:18
// 
// Dependencies: 
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_execution();

// params
parameter NB_DATA    = 32;
parameter N_ADDRESS  = 64;
parameter NB_ADDRESS = 32;
parameter T = (41.67 * 2);

parameter NB_CONTROL_EX     =  5;
parameter NB_CONTROL_MA     =  5;
parameter NB_CONTROL_WB     =  2;
parameter NB_CONTROL_BUS    = (NB_CONTROL_EX+NB_CONTROL_MA+NB_CONTROL_WB);
parameter NB_CONTROL_MA_WB  = NB_CONTROL_MA+NB_CONTROL_WB;
parameter NB_ALU_OP         =  6;


parameter NB_REGISTERS = 32;
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
wire [NB_DATA_REGISTERS-1:0]    id_ex_bus_a;
wire [NB_DATA_REGISTERS-1:0]    id_ex_bus_b;

wire [NB_ADDR_REGISTERS-1:0]    id_ex_rs_num;
wire [NB_ADDR_REGISTERS-1:0]    id_ex_rt_num;
wire [NB_ADDR_REGISTERS-1:0]    id_ex_rd_num;
    
wire [NB_DATA          -1:0]    id_ex_ext_literal   ;
wire [NB_DATA          -1:0]    id_ex_ext_sa        ;
wire [NB_DATA          -1:0]    id_ex_pc_delay_slot ;

wire [NB_CONTROL_BUS-1 : 0]     id_ex_control_bus   ;
wire [NB_ALU_OP     -1 : 0]     id_ex_alu_op        ;
    
// Referido a un stall
wire                            o_if_stall          ;
    
    // Referido a un branch
wire [NB_ADDRESS-1:0]           o_if_branch_addr    ;
wire                            o_if_branch         ;
    
//INPUTS        
//from execution
reg [NB_ADDR_REGISTERS-1:0]    ex_id_rt = 0             ;
reg                            ex_id_ctl_mem_read = 0   ;  
    
//from write_back
reg [NB_DATA_REGISTERS-1:0]    wb_id_reg_data = 0       ;
reg [NB_ADDR_REGISTERS-1:0]    wb_id_reg_addr = 0       ;
reg                            wb_id_reg_en   = 0       ;


//execution
//OUTPUTS
wire    [NB_CONTROL_MA_WB-1:0]   o_control_ma_wb;
    
wire    [NB_DATA-1:0]            o_result          ;        
wire    [NB_DATA-1:0]            o_w_data_mem      ;
    
wire    [NB_ADDR_REGISTERS-1:0]  o_rd_num          ;//rt o rd
    
wire    [NB_ADDR_REGISTERS-1:0]  o_id_rd_num       ;
wire                             o_id_ctl_mem_read ;
    
//INPUTS   
    
//del cortocircuito de ma
reg    [NB_DATA-1:0]            ma_rd_data=0;
reg    [NB_ADDR_REGISTERS-1:0]  ma_rd_num =0;
reg                             ma_ctl_wr =0;
    
//del cortocircuito de wb
reg    [NB_DATA-1:0]            wb_rd_data=0;
reg    [NB_ADDR_REGISTERS-1:0]  wb_rd_num =0;
reg                             wb_ctl_wr =0;

// Module instantiation

// if instantiation
instruction_fetch
#(
    //.N_ADDRESS(N_ADDRESS)//,
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

//wire [31:0] ext_pc;
//assign ext_pc = {{(32-NB_ADDRESS),{1'b0}},next_pc};

// id instantiation
instruction_decoder
#(
    //.N_ADDRESS(N_ADDRESS)
)
uut_instruction_decoder
(
    //OUTPUTS
    .o_bus_a(id_ex_bus_a) ,
    .o_bus_b(id_ex_bus_b) ,

    .o_rs_num(id_ex_rs_num),
    .o_rt_num(id_ex_rt_num),
    .o_rd_num(id_ex_rd_num),
    
    .o_ext_literal  (id_ex_ext_literal)   ,
    .o_ext_sa       (id_ex_ext_sa)        ,
    .o_pc_delay_slot(id_ex_pc_delay_slot) ,

    .o_control_bus(id_ex_control_bus)     ,
    .o_alu_op     (id_ex_alu_op)          ,
    
    // Referido a un stall
    .o_if_stall   (o_if_stall)      ,
    
    // Referido a un branch
    .o_if_branch_addr (o_if_branch_addr) ,
    .o_if_branch      (o_if_branch) ,
    
    //INPUTS
    
    //from instruction_fetch
    .i_instruction    (instruction) ,
    .i_pc             (next_pc) ,
    
    //from execution
    .i_ex_rt            (ex_id_rt) ,
    .i_ex_ctl_mem_read  (ex_id_ctl_mem_read) ,  
    
    //from write_back
    .i_wb_reg_data      (wb_id_reg_data) ,
    .i_wb_reg_addr      (wb_id_reg_addr) ,
    .i_wb_reg_en        (wb_id_reg_en)   ,
    
    .i_clk              (clk) ,
    .i_reset            (reset)
);

//ex
execution
#(
)
uut_exectution
(
  //OUTPUTS
    .o_control_ma_wb    (o_control_ma_wb)  ,
    
    .o_result           (o_result)             ,        
    .o_w_data_mem       (o_w_data_mem)         ,
    
    .o_rd_num           (o_rd_num)          ,//rt o rd
    
    .o_id_rd_num        (o_id_rd_num)       ,
    .o_id_ctl_mem_read  (o_id_ctl_mem_read) ,
    
 //INPUTS   
    // de control
    .i_control_bus(id_ex_control_bus),
    
    // de la etapa de ID
    .i_bus_a            (id_ex_bus_a) ,
    .i_bus_b            (id_ex_bus_b) ,
    
    .i_ext_literal      (id_ex_ext_literal),
    .i_ext_sa           (id_ex_ext_sa),
    .i_pc_delay_slot    (id_ex_pc_delay_slot),
    
    .i_alu_op(id_ex_alu_op),
    
    .i_id_rs_num(id_ex_rs_num),
    .i_id_rt_num(id_ex_rt_num),
    .i_id_rd_num(id_ex_rd_num),
    
    //del cortocircuito de ma
    .i_ma_rd_data(ma_rd_data),
    .i_ma_rd_num (ma_rd_num ),
    .i_ma_ctl_wr (ma_ctl_wr ),
    
    //del cortocircuito de wb
    .i_wb_rd_data(wb_rd_data),
    .i_wb_rd_num (wb_rd_num ),
    .i_wb_ctl_wr (wb_ctl_wr ),
    
    .i_reset(reset),
    .i_clk(clk)
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
        wb_id_reg_addr = i;
        wb_id_reg_data = i + 64;
        wb_id_reg_en = 1'b1; 
    end
    
    #T
    wb_id_reg_en = 1'b0;
    stall = 1'b0;
    
    #(40*T)
    $finish;
    
    
end

endmodule
