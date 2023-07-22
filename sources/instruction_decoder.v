`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2023 18:24:28
// Design Name: 
// Module Name: instruction_decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instruction_decoder
#(
    //PARAMETERS
    parameter NB_DATA_REGISTERS = 32,
    parameter NB_INSTRUCTIONS   = 32,
    parameter N_REGISTERS       = 32,
    parameter NB_ADDR_REGISTERS =  5,
    parameter NB_DATA           = 32,
    parameter NB_CONTROL_EX     =  6,
    parameter NB_CONTROL_MA     =  4,
    parameter NB_CONTROL_WB     =  4,
    parameter NB_CONTROL_BUS    = (NB_CONTROL_EX+NB_CONTROL_MA+NB_CONTROL_WB),
    parameter NB_ALU_OP         =  2,
    parameter NB_OPCODE         =  6,
    parameter NB_FUNC           =  6
)(
    //OUTPUTS
    output  wire [NB_DATA_REGISTERS-1:0]    o_bus_a ,
    output  wire [NB_DATA_REGISTERS-1:0]    o_bus_b ,

    output  wire [NB_ADDR_REGISTERS-1:0]    o_rs    ,
    output  wire [NB_ADDR_REGISTERS-1:0]    o_rt    ,
    output  wire [NB_ADDR_REGISTERS-1:0]    o_rd    ,
    
    output  wire [NB_DATA          -1:0]    o_ext_literal,

    output  wire [NB_CONTROL_BUS-1 : 0]     o_control_bus,
    output  wire [NB_ALU_OP-1      : 0]     o_alu_op,

    //INPUTS
    input   wire [NB_INSTRUCTIONS  -1:0]    i_instruction   ,
    input   wire [NB_DATA_REGISTERS-1:0]    i_w_reg_data    ,
    input   wire [NB_ADDR_REGISTERS-1:0]    i_w_reg_addr    ,
    input   wire                            i_clk           ,
    input   wire                            i_reset           
);
// LOCALPARAMS
localparam  pos_EX_CONTROL = NB_CONTROL_BUS;
localparam  pos_MA_CONTROL = NB_CONTROL_BUS - NB_CONTROL_EX;
localparam  pos_WB_CONTROL = NB_CONTROL_WB;

//opcodes
localparam addi_OPCODE	= 6'b001000;
localparam andi_OPCODE	= 6'b001100;
localparam xori_OPCODE  = 6'b001110;
localparam ori_OPCODE	= 6'b001101;
localparam lui_OPCODE   = 6'b001111;

localparam special_OPCODE = 6'b000000;

localparam jr_FUNC = 6'b001000;

// INTERNAL REGS AND WIRES 
wire [NB_OPCODE-1:0] opcode;
wire [NB_FUNC-1  :0] func;

reg  [NB_ALU_OP-1:0]         reg_alu_op  ;
reg  [NB_ALU_OP-1:0]         alu_op      ;

reg  [NB_CONTROL_BUS-1:0]    control_bus ; 

wire [NB_CONTROL_EX-1:0]    control_ex;
wire [NB_CONTROL_MA-1:0]    control_ma;
wire [NB_CONTROL_WB-1:0]    control_wb;

wire [NB_DATA-1:0] bus_A;
wire [NB_DATA-1:0] bus_B;

reg  [NB_DATA-1:0] reg_bus_A;
reg  [NB_DATA-1:0] reg_bus_B;

assign opcode = i_instruction[NB_INSTRUCTIONS:-NB_OPCODE];
assign func = i_instruction[NB_FUNC-1:0];

// REGISTER BANK
register_bank#()
register_bank_u(
    .o_sr1_data(bus_A),
    .o_sr2_data(bus_B),
    
    .i_sr1_addr(i_instruction[25-21]),
    .i_sr2_addr(i_instruction[20-16]),
    
    .i_dr_data(i_w_reg_data),
    .i_dr_addr(i_w_reg_addr),
    
    .i_clk(i_clk)
);

//Registar la salida de alu_op
always @(posedge i_clk) begin
    reg_alu_op <= alu_op;
end

// Logica para determinar alu_op
always @(*) begin
    case(opcode) 
        special_OPCODE  : alu_op = func;
        addi_OPCODE     : alu_op = 6'b100001;
        andi_OPCODE     : alu_op = 6'b100100;
        xori_OPCODE     : alu_op = 6'b100110;
        ori_OPCODE      : alu_op = 6'b100101;
        lui_OPCODE      : alu_op = 6'bxxxxxx;
        
        
        
    endcase
end

// Registrar la salida del bus de control
always @(posedge i_clk) begin
    control_bus[pos_EX_CONTROL:-NB_CONTROL_EX] <= control_ex;
    control_bus[pos_MA_CONTROL:-NB_CONTROL_MA] <= control_ma;
    control_bus[pos_WB_CONTROL:0]              <= control_wb;
end

// MEMORY ACCESS CONTROL LOGIC
wire        mem_read ;
wire        mem_write;
wire [2:0]  adressing;
wire        signing;

assign control_ma = {mem_read,mem_write,adressing,signing};

assign mem_read  = (opcode[NB_OPCODE-1:-3]==3'b100) ? 1'b1 : 1'b0;  //Si es load, vale 1. 0 caso contrario
assign mem_write = (opcode[NB_OPCODE-1:-3]==3'b101) ? 1'b1 : 1'b0;  //Si es write, vale 1. 0 caso contrario

assign adressing = opcode[1:0];
assign signing   = opcode[2];

// WRITE BACK CONTROL LOGIC
reg ctl_reg_write;
wire ctl_mem_to_reg;

assign control_wb = {ctl_reg_write,ctl_mem_to_reg};

//ctl_mem_to_reg
assign ctl_mem_to_reg = (opcode==special_OPCODE) ? 1'b0 : 1'b1; // 0 si tipo r, 1 caso contrario.

//ctl_reg_write
always @(*) begin
    if(opcode == special_OPCODE) begin
        if(func==jr_FUNC)                   ctl_reg_write = 1'b0;   // jr es tipo r pero no escribe
        else                                ctl_reg_write = 1'b1;
    end
    else if(opcode[NB_OPCODE-1:-3]==3'b100) ctl_reg_write = 1'b1;
    else                                    ctl_reg_write = 1'b0;
end



endmodule
