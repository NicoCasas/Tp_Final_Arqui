`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2023 14:23:41
// 
// Dependencies: 
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module execution
#(
    parameter NB_DATA   = 32,
    parameter NB_ALU_OP = 6,
    parameter NB_ADDR_REGISTERS = 5,
    parameter NB_CONTROL_EX = 5,
    parameter NB_CONTROL_MA = 5,
    parameter NB_CONTROL_WB = 2,
    parameter NB_CONTROL_MA_WB = NB_CONTROL_MA + NB_CONTROL_WB,
    parameter NB_CONTROL_BUS = NB_CONTROL_MA + NB_CONTROL_WB + NB_CONTROL_EX
)
(
  //OUTPUTS
    output  wire    [NB_CONTROL_MA_WB-1:0]  o_control_ma_wb   ,
    
    output  wire    [NB_DATA-1:0]           o_result          ,        
    output  wire    [NB_DATA-1:0]           o_w_data_mem      ,
    
    output  wire    [NB_ADDR_REGISTERS-1:0] o_rd_num          ,//rt o rd
    
    //salidas no registradas (hazard detection en id)
    output  wire    [NB_ADDR_REGISTERS-1:0] o_id_rd_num       ,
    output  wire                            o_id_ctl_mem_read ,
    
    //salidas no registradas (cortocircuito en id)
    output  wire                            o_id_ctl_reg_write,
    output  wire    [NB_DATA-1:0]           o_id_alu_result   ,
    
 //INPUTS   
    // de control
    input   wire    [NB_CONTROL_BUS-1:0]    i_control_bus,
    
    // de la etapa de ID
    input   wire    [NB_DATA-1:0]       i_bus_a ,
    input   wire    [NB_DATA-1:0]       i_bus_b ,
    input   wire    [NB_DATA-1:0]       i_ext_literal,
    input   wire    [NB_DATA-1:0]       i_ext_sa,
    input   wire    [NB_DATA-1:0]       i_pc_delay_slot,
    
    input   wire    [NB_ALU_OP-1:0]       i_alu_op,
    
    input   wire    [NB_ADDR_REGISTERS-1:0]  i_id_rs_num,
    input   wire    [NB_ADDR_REGISTERS-1:0]  i_id_rt_num,
    input   wire    [NB_ADDR_REGISTERS-1:0]  i_id_rd_num,
    
    //del cortocircuito de ma
    input   wire    [NB_DATA-1:0]           i_ma_rd_data,
    input   wire    [NB_ADDR_REGISTERS-1:0] i_ma_rd_num ,
    input   wire                            i_ma_ctl_rw ,
    
    //del cortocircuito de wb
    input   wire    [NB_DATA-1:0]           i_wb_rd_data,
    input   wire    [NB_ADDR_REGISTERS-1:0] i_wb_rd_num ,
    input   wire                            i_wb_ctl_rw ,
    
    input   wire    i_reset     ,
    input   wire    i_clk       ,
    input   wire    i_clk_en    
);

//LOCALPARAMS
localparam ctl_reg_dest_POS     = NB_CONTROL_BUS-1;
localparam ctl_mux_rs_sa_POS    = NB_CONTROL_BUS-2;
localparam ctl_mux_rt_imm_POS   = NB_CONTROL_BUS-3;                         //TODO DEFINIR EN ID
localparam ctl_mux_use_pc_POS   = NB_CONTROL_BUS-4;
localparam ctl_reg_dest_31_POS  = NB_CONTROL_BUS-5;

//INTERNAL REGS AND WIRES
//operandos de la alu 
wire [NB_DATA-1:0]   alu_data_a;
wire [NB_DATA-1:0]   alu_data_b;
wire [NB_DATA-1:0]   alu_result;
//wire [NB_ALU_OP-1:0] alu_op;

//salida de los mux del cortocircuito
reg  [NB_DATA-1:0]   ex_rs_data;
reg  [NB_DATA-1:0]   ex_rt_data;

//salida del mux de reg dest -> Considera rd o rt y después considera si era jal
wire [NB_ADDR_REGISTERS-1:0]   ex_rd_num;

//salida del mux de rd or rt
wire [NB_ADDR_REGISTERS-1:0]   rd_or_rt_num;

// Señales De Control
// señales de control de los muxes de cortocircuito
wire                 ctl_mux_rs_sa ;
wire                 ctl_mux_rt_imm;
wire                 ctl_mux_use_pc;

// señales para determinar sobre qué registro escribir
wire                 ctl_reg_dest;
wire                 ctl_reg_dest_31;

// Registros auxiliares para registrar salidas
reg    [NB_CONTROL_MA_WB-1:0]   reg_o_control_ma_wb          ;
reg    [NB_DATA-1:0]            reg_o_result                 ;

reg    [NB_DATA-1:0]            reg_o_w_data_mem             ;
reg    [NB_ADDR_REGISTERS-1:0]  reg_o_rd_num                 ;//rt o rd

// Registro destino
assign ctl_reg_dest    = i_control_bus[ctl_reg_dest_POS];
assign ctl_reg_dest_31 = i_control_bus[ctl_reg_dest_31_POS];

assign ex_rd_num        = (ctl_reg_dest_31) ? 5'b11111 : rd_or_rt_num;
assign rd_or_rt_num     = (ctl_reg_dest)    ? i_id_rd_num : i_id_rt_num;

// Asignacion de las señales de control de los muxes de cortocircuito
assign ctl_mux_use_pc = i_control_bus[ctl_mux_use_pc_POS];
assign ctl_mux_rs_sa  = i_control_bus[ctl_mux_rs_sa_POS ];
assign ctl_mux_rt_imm = i_control_bus[ctl_mux_rt_imm_POS];


// Muxes previos a la alu
assign alu_data_a = (ctl_mux_use_pc) ? i_pc_delay_slot : (ctl_mux_rs_sa) ? ex_rs_data : i_ext_sa;
assign alu_data_b = (ctl_mux_rt_imm) ? ex_rt_data : i_ext_literal;

// Alu
alu #()
alu_u(
    .o_data     (alu_result)    ,
    
    .i_dato_a   (alu_data_a)    ,
    .i_dato_b   (alu_data_b)    ,
    .i_op       (i_alu_op)
);

// Unidad de cortocircuito
// ex_rs_data
always @(*) begin
    if      ((i_id_rs_num == i_ma_rd_num) && i_ma_ctl_rw)    ex_rs_data = i_ma_rd_data;
    else if ((i_id_rs_num == i_wb_rd_num) && i_wb_ctl_rw)    ex_rs_data = i_wb_rd_data;         
    else                                                     ex_rs_data = i_bus_a; 
end

// ex_rt_data
always @(*) begin
    if      ((i_id_rt_num == i_ma_rd_num) && i_ma_ctl_rw)    ex_rt_data = i_ma_rd_data;
    else if ((i_id_rt_num == i_wb_rd_num) && i_wb_ctl_rw)    ex_rt_data = i_wb_rd_data;         
    else                                                     ex_rt_data = i_bus_b; 
end

// ctl_rw
wire rd_not_zero;
wire ex_ctl_rw;

assign rd_not_zero = (ex_rd_num != {NB_ADDR_REGISTERS{1'b0}}); 
assign ex_ctl_rw = i_control_bus[0] & rd_not_zero;

// OUTPUT REGISTER
// o_control_ma_wb
always @(posedge i_clk) begin
    if(i_reset) reg_o_control_ma_wb <= {NB_CONTROL_MA_WB{1'b0}};
    else if(i_clk_en) begin  
                reg_o_control_ma_wb[NB_CONTROL_MA_WB-1:1] <= i_control_bus[NB_CONTROL_MA_WB-1:1];
                reg_o_control_ma_wb[0] <= ex_ctl_rw;
    end
end

// o_result
always @(posedge i_clk) begin
    if      (i_reset)       reg_o_result <= {NB_DATA{1'b0}};
    else if (i_clk_en)      reg_o_result <= alu_result;
end

// o_write_data_mem
always @(posedge i_clk) begin
    if      (i_reset)       reg_o_w_data_mem <= {NB_DATA{1'b0}};
    else if (i_clk_en)      reg_o_w_data_mem <= ex_rt_data;
end

// o_rd_num
always @(posedge i_clk) begin
    if      (i_reset)       reg_o_rd_num <= {NB_ADDR_REGISTERS{1'b0}};
    else if (i_clk_en)      reg_o_rd_num <= ex_rd_num;
end


//OUTPUT ASSIGN
assign o_control_ma_wb  = reg_o_control_ma_wb;
assign o_result         = reg_o_result;
assign o_w_data_mem     = reg_o_w_data_mem;
assign o_rd_num         = reg_o_rd_num;

assign o_id_rd_num        = ex_rd_num;
assign o_id_ctl_mem_read  = i_control_bus[NB_CONTROL_MA_WB-1]; 

assign o_id_ctl_reg_write = ex_ctl_rw;
assign o_id_alu_result    = alu_result;

endmodule
