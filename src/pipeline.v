`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2023 19:35:05
// 
//////////////////////////////////////////////////////////////////////////////////


module pipeline #(
    // params
    parameter NB_DATA    = 32   ,
    parameter N_ADDRESS  = 64   ,
    parameter NB_ADDRESS = 32   ,
    
    parameter NB_CONTROL_EX     =  5,
    parameter NB_CONTROL_MA     =  5,
    parameter NB_CONTROL_WB     =  2,
    parameter NB_CONTROL_BUS    = (NB_CONTROL_EX+NB_CONTROL_MA+NB_CONTROL_WB),
    parameter NB_CONTROL_MA_WB  = NB_CONTROL_MA+NB_CONTROL_WB,
    parameter NB_ALU_OP         =  6,
    
    
    parameter NB_DATA_REGISTERS = 32,
    
    parameter N_REGISTERS = 32,
    parameter NB_ADDR_REGISTERS = $clog2(N_REGISTERS),
    
    parameter NB_INSTRUCTIONS = 32,    
    parameter INIT_FILE = "file_to_test_jumps.mem"//"file_to_test_pipeline_1.mem"

)
(
    output  wire [31:0] o_wb_reg_w_data         ,
    //output  wire        o_clk                   ,
    //output  wire        o_locked                ,
    
    output  wire [NB_ADDRESS-1:0]   o_if_pc        ,
    output  wire                    o_if_halt      ,
    
    output  wire [NB_DATA-1:0]      o_debug_reg_data            ,
    output  wire [NB_DATA-1:0]      o_debug_d_mem_data          ,
    
    input   wire                    i_debug                     ,
    
    input   wire                    i_debug_p_mem_w_en          ,
    input   wire [NB_ADDRESS-1:0]   i_debug_p_mem_w_addr        ,
    input   wire [NB_DATA   -1:0]   i_debug_p_mem_w_data        ,
    
    input   wire [NB_ADDRESS-1:0]           i_debug_d_mem_addr          ,
    input   wire [NB_ADDR_REGISTERS-1:0]    i_debug_reg_addr            ,
    
    input   wire i_clk                          ,
    input   wire i_clk_en                       ,
    //input   wire i_clk_reset          //          ,
    input   wire i_reset                        
);

///////////////////////////// IF ////////////////////////////
//OUTPUTS 
wire [NB_DATA-1:0]     if_instruction   ;
wire [NB_ADDRESS-1:0]  if_next_pc       ; 
        
//INPUTS
reg                    reg_branch       = 1'b0;
reg [NB_ADDRESS-1:0]   reg_branch_addr  = {32{1'b0}} ;
    
reg                    reg_stall        = 1'b0 ;
    
wire clk_en = i_clk_en;
assign clk = i_clk;
////////////////////////// ID ////////////////////////////

wire [NB_DATA_REGISTERS-1:0]    id_bus_a;
wire [NB_DATA_REGISTERS-1:0]    id_bus_b;

wire [NB_ADDR_REGISTERS-1:0]    id_rs_num;
wire [NB_ADDR_REGISTERS-1:0]    id_rt_num;
wire [NB_ADDR_REGISTERS-1:0]    id_rd_num;
    
wire [NB_DATA          -1:0]    id_ext_literal   ;
wire [NB_DATA          -1:0]    id_ext_sa        ;
wire [NB_DATA          -1:0]    id_pc_delay_slot ;

wire [NB_CONTROL_BUS-1 : 0]     id_control_bus   ;
wire [NB_ALU_OP     -1 : 0]     id_alu_op        ;
    
// Referido a un stall
wire                            id_if_stall          ;
wire                            id_if_halt           ;
    
// Referido a un branch
wire [NB_ADDRESS-1:0]           id_if_branch_addr    ;
wire                            id_if_branch         ;
    
//INPUTS        
//from execution (hazard detection)
reg [NB_ADDR_REGISTERS-1:0]    reg_ex_rd_num        = {5{1'b0}}     ;
reg                            reg_ex_ctl_mem_read  = 1'b0   ;  
    
//from write_back
reg [NB_DATA_REGISTERS-1:0]    wb_reg_data = {32{1'b0}}     ;
reg [NB_ADDR_REGISTERS-1:0]    wb_reg_addr = {5{1'b0}}      ;
reg                            wb_reg_en   = 1'b0           ;


/////////////////////////////// EX ////////////////////////////
//OUTPUTS
wire    [NB_CONTROL_MA_WB-1:0]   ex_control_ma_wb;
    
wire    [NB_DATA-1:0]            ex_result          ;        
wire    [NB_DATA-1:0]            ex_w_data_mem      ;
    
wire    [NB_ADDR_REGISTERS-1:0]  ex_rd_num          ;//rt o rd
    
wire    [NB_ADDR_REGISTERS-1:0]  ex_id_rd_num       ;
wire                             ex_id_ctl_mem_read ;

wire                             ex_id_ctl_reg_write;
wire    [NB_DATA-1:0]            ex_id_alu_result   ;
    
    
//INPUTS   
    
//del cortocircuito de ma
reg    [NB_DATA-1:0]            reg_ma_rd_data=0;
reg    [NB_ADDR_REGISTERS-1:0]  reg_ma_rd_num =0;
reg                             reg_ma_ctl_wr =0;
    
//del cortocircuito de wb
reg    [NB_DATA-1:0]            reg_wb_rd_data=0;
reg    [NB_ADDR_REGISTERS-1:0]  reg_wb_rd_num =0;
reg                             reg_wb_ctl_wr =0;

/////////////////////////////// MA ////////////////////////////
wire    [NB_CONTROL_WB-1:0]     ma_control_wb       ;
    
wire    [NB_DATA-1:0]           ma_mem_r_data       ;
wire    [NB_DATA-1:0]           ma_reg_data         ;
wire    [NB_ADDR_REGISTERS-1:0] ma_reg_num          ;

wire    [NB_ADDR_REGISTERS-1:0] ma_ex_rd_num        ;
wire    [NB_DATA-1:0]           ma_ex_rd_data;
wire                            ma_ex_ctl_reg_write ;
wire                            ma_id_ctl_mem_read  ;

/////////////////////////////// WB ////////////////////////////
wire    [NB_DATA-1:0]           wb_reg_w_data       ;
wire    [NB_ADDR_REGISTERS-1:0] wb_reg_num          ;
wire                            wb_reg_w_en         ;

//////////////////////////////////////////////////////////////////////
////////////////////////// Module instantiation //////////////////////
//////////////////////////////////////////////////////////////////////
    
// if instantiation
instruction_fetch
#(
    //.N_ADDRESS(N_ADDRESS)//,
    .INIT_FILE  (INIT_FILE)
)
uut_instruction_fetch
(
    //OUTPUTS
    .o_instruction  (if_instruction)   ,
    .o_next_pc_1    (if_next_pc)       , 
        
    //INPUTS
    .i_branch       (id_if_branch)        ,   //reg_branch
    .i_branch_addr  (id_if_branch_addr)   , //reg_branch_addr
    
    .i_stall        (id_if_stall)       ,
    .i_halt         (id_if_halt)        ,
    
    .i_debug             (i_debug),
    .i_debug_w_en        (i_debug_p_mem_w_en),
    .i_debug_w_addr      (i_debug_p_mem_w_addr),
    .i_debug_w_data      (i_debug_p_mem_w_data),
    
    
    .i_clk          (clk)           ,
    .i_clk_en       (clk_en)        ,
    .i_reset        (i_reset)
 
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
    .o_bus_a(id_bus_a) ,
    .o_bus_b(id_bus_b) ,

    .o_rs_num(id_rs_num),
    .o_rt_num(id_rt_num),
    .o_rd_num(id_rd_num),
    
    .o_ext_literal  (id_ext_literal)   ,
    .o_ext_sa       (id_ext_sa)        ,
    .o_pc_delay_slot(id_pc_delay_slot) ,

    .o_control_bus  (id_control_bus)     ,
    .o_alu_op       (id_alu_op)          ,
    
    // Referido a un stall
    .o_if_stall     (id_if_stall)      ,
    
    //Referido a un halt
    .o_if_halt      (id_if_halt)       ,
    
    // Referido a un branch
    .o_if_branch_addr (id_if_branch_addr) ,
    .o_if_branch      (id_if_branch) ,
    
    // debug
    .o_debug_reg_data   (o_debug_reg_data),
    
    
    //INPUTS
    
    //from instruction_fetch
    .i_instruction    (if_instruction) ,
    .i_pc             (if_next_pc)     ,
    
    //from execution
    .i_ex_rd_num        (ex_id_rd_num)         ,    // conecte esto 
    .i_ex_ctl_mem_read  (ex_id_ctl_mem_read)   ,    // y esto -> No debería modificar nada
    
    .i_ex_rd_data       (ex_id_alu_result)      ,
    .i_ex_ctl_reg_write (ex_id_ctl_reg_write)   ,
    
    //from ma
    .i_ma_rd_num        (ma_ex_rd_num )         ,
    .i_ma_rd_data       (ma_ex_rd_data)         ,
    .i_ma_ctl_reg_write (ma_ex_ctl_reg_write )  ,
    .i_ma_ctl_mem_read  (ma_id_ctl_mem_read  )  ,
    
    //from write_back
    .i_wb_reg_data      (wb_reg_w_data)         ,
    .i_wb_reg_addr      (wb_reg_num)            ,
    .i_wb_reg_en        (wb_reg_w_en)           ,
    
    //debug
    .i_debug            (i_debug) ,
    .i_debug_reg_addr   (i_debug_reg_addr)      ,
    
    .i_clk              (clk)                   ,
    .i_clk_en           (clk_en)                ,
    .i_reset            (i_reset)
);

// ex instantiation
execution
#(
)
uut_exectution
(
  //OUTPUTS
    .o_control_ma_wb    (ex_control_ma_wb)   ,
    
    .o_result           (ex_result)          ,        
    .o_w_data_mem       (ex_w_data_mem)      ,
    
    .o_rd_num           (ex_rd_num)          ,//rt o rd
    
    .o_id_rd_num        (ex_id_rd_num)       ,
    .o_id_ctl_mem_read  (ex_id_ctl_mem_read) ,
    
    .o_id_ctl_reg_write (ex_id_ctl_reg_write),
    .o_id_alu_result    (ex_id_alu_result)   ,
    
    
 //INPUTS   
    // de control
    .i_control_bus      (id_control_bus),
    
    // de la etapa de ID
    .i_bus_a            (id_bus_a) ,
    .i_bus_b            (id_bus_b) ,
    
    .i_ext_literal      (id_ext_literal),
    .i_ext_sa           (id_ext_sa),
    .i_pc_delay_slot    (id_pc_delay_slot),
    
    .i_alu_op           (id_alu_op),
    
    .i_id_rs_num        (id_rs_num),
    .i_id_rt_num        (id_rt_num),
    .i_id_rd_num        (id_rd_num),
    
    //del cortocircuito de ma
    .i_ma_rd_data(ma_ex_rd_data),
    .i_ma_rd_num (ma_ex_rd_num ),
    .i_ma_ctl_rw (ma_ex_ctl_reg_write ),
    
    //del cortocircuito de wb
    .i_wb_rd_data(wb_reg_w_data),
    .i_wb_rd_num (wb_reg_num   ),
    .i_wb_ctl_rw (wb_reg_w_en  ),
    
    .i_reset(i_reset),
    .i_clk_en       (clk_en)        ,
    .i_clk(clk)
);

// ma instantiation
memory_access
#(
)
uut_memory_access
(   
    //OUTPUTS 
    //-> 4 salidas registradas:    ctl bus, r_data, reg_data, rd_num (van a wb)
    //-> 2 salidas no registradas: id_ctl_rw , id_rd_num. (van a id, especificamente a la unidad de cortocircuito)
    .o_control_wb       (ma_control_wb)     ,
    
    .o_mem_r_data       (ma_mem_r_data)     ,
    .o_reg_data         (ma_reg_data)       ,
    .o_reg_num          (ma_reg_num)        ,
    
    .o_ex_rd_num        (ma_ex_rd_num)      ,
    .o_ex_rd_data       (ma_ex_rd_data)     ,
    .o_ex_ctl_reg_write (ma_ex_ctl_reg_write)       ,
    .o_id_ctl_mem_read  (ma_id_ctl_mem_read)        ,
    
    .o_debug_mem_r_data (o_debug_d_mem_data) ,
    
    //INPUTS                                                            //agregar rd_num
    .i_mem_data         (ex_w_data_mem)     ,
    .i_mem_addr         (ex_result)         ,
    
    .i_control_ma_wb    (ex_control_ma_wb)  ,
    
    .i_rd_num           (ex_rd_num)         ,
    
    .i_debug            (i_debug)              ,
    .i_debug_mem_addr   (i_debug_d_mem_addr),
    
    .i_clk              (clk)               ,
    .i_clk_en           (clk_en)            ,
    .i_reset            (i_reset)     
);

// wb instantiation
write_back
#(
)
uut_write_back
(
    .o_reg_w_data(wb_reg_w_data )    ,
    .o_reg_num   (wb_reg_num    )    ,
    .o_reg_w_en  (wb_reg_w_en   )    ,
    
    .i_reg_data  (ma_reg_data)      ,
    .i_mem_data  (ma_mem_r_data)      ,
    
    .i_reg_num   (ma_reg_num)       ,
    
    .i_control_wb(ma_control_wb)
);

assign o_wb_reg_w_data = wb_reg_w_data;
assign o_if_halt = id_if_halt;
assign o_if_pc   = if_next_pc;



endmodule
