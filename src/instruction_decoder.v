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
    parameter NB_CONTROL_EX     =  5,
    parameter NB_CONTROL_MA     =  5,
    parameter NB_CONTROL_WB     =  2,
    parameter NB_CONTROL_BUS    = (NB_CONTROL_EX+NB_CONTROL_MA+NB_CONTROL_WB),
    parameter NB_ALU_OP         =  6,
    parameter NB_OPCODE         =  6,
    parameter NB_FUNC           =  6,
    
    //parameter N_ADDRESS  = 16,
    parameter NB_ADDRESS = 32
)(
    //OUTPUTS
    output  wire [NB_DATA_REGISTERS-1:0]    o_bus_a ,
    output  wire [NB_DATA_REGISTERS-1:0]    o_bus_b ,

    output  wire [NB_ADDR_REGISTERS-1:0]    o_rs_num,
    output  wire [NB_ADDR_REGISTERS-1:0]    o_rt_num,
    output  wire [NB_ADDR_REGISTERS-1:0]    o_rd_num,
    
    output  wire [NB_DATA          -1:0]    o_ext_literal   ,
    output  wire [NB_DATA          -1:0]    o_ext_sa        ,

    output  wire [NB_DATA          -1:0]    o_pc_delay_slot ,

    output  wire [NB_CONTROL_BUS-1 : 0]     o_control_bus   ,
    output  wire [NB_ALU_OP-1      : 0]     o_alu_op        ,
    
    // Referido a un stall
    output  wire                            o_if_stall          ,
    
    // Referido a un branch
    output  wire [NB_ADDRESS-1:0]           o_if_branch_addr    ,
    output  wire                            o_if_branch         ,
    
    //INPUTS
    
    //from instruction_fetch
    input   wire [NB_INSTRUCTIONS  -1:0]    i_instruction       ,
    input   wire [NB_ADDRESS       -1:0]    i_pc                ,
    
    //from execution
    input   wire [NB_ADDR_REGISTERS-1:0]    i_ex_rt             ,
    input   wire                            i_ex_ctl_mem_read   ,  
    
    //from write_back
    input   wire [NB_DATA_REGISTERS-1:0]    i_wb_reg_data       ,
    input   wire [NB_ADDR_REGISTERS-1:0]    i_wb_reg_addr       ,
    input   wire                            i_wb_reg_en         ,
    
    input   wire                            i_clk               ,
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
localparam slti_OPCODE  = 6'b001010;
localparam ori_OPCODE	= 6'b001101;
localparam lui_OPCODE   = 6'b001111;
localparam jal_OPCODE   = 6'b000011;
 
 
localparam special_OPCODE = 6'b000000;

localparam jr_FUNC = 6'b001000;

// INTERNAL REGS AND WIRES 
wire [NB_OPCODE-1:0] opcode;
wire [NB_FUNC-1  :0] func;

reg  [NB_ALU_OP-1:0]         reg_o_alu_op  ;
reg  [NB_ALU_OP-1:0]         alu_op      ;

reg  [NB_CONTROL_BUS-1:0]    control_bus ; 

wire [NB_CONTROL_EX-1:0]    control_ex;
wire [NB_CONTROL_MA-1:0]    control_ma;
wire [NB_CONTROL_WB-1:0]    control_wb;

reg                         id_stall    ; 

reg [NB_DATA_REGISTERS-1:0] reg_o_rs_num;
reg [NB_DATA_REGISTERS-1:0] reg_o_rt_num;
reg [NB_DATA_REGISTERS-1:0] reg_o_rd_num;

wire [NB_DATA_REGISTERS-1:0] bus_a;
wire [NB_DATA_REGISTERS-1:0] bus_b;

reg  [NB_DATA_REGISTERS-1:0] reg_o_bus_a;
reg  [NB_DATA_REGISTERS-1:0] reg_o_bus_b;

wire [NB_DATA_REGISTERS-1:0]  ext_literal;
wire [NB_DATA_REGISTERS-1:0]  ext_sa;

reg  [NB_DATA_REGISTERS-1:0] reg_o_ext_literal;
reg  [NB_DATA_REGISTERS-1:0] reg_o_ext_sa;

assign opcode = i_instruction[NB_INSTRUCTIONS-1-:NB_OPCODE];
assign func = i_instruction[NB_FUNC-1:0];

// Registrar los n�meros de los registros
always @(posedge i_clk) begin
    reg_o_rs_num <= i_instruction[25:21];
    reg_o_rt_num <= i_instruction[20:16];
    reg_o_rd_num <= i_instruction[15:11];
end

// Asignar a las salidas
assign o_rs_num = reg_o_rs_num;
assign o_rt_num = reg_o_rt_num;
assign o_rd_num = reg_o_rd_num;

// Registrar la salida de los buses operando de la alu
always @(posedge i_clk) begin
    reg_o_bus_a <= bus_a;
    reg_o_bus_b <= bus_b;
end

// REGISTER BANK
register_bank#(
    .NB_DATA(NB_DATA_REGISTERS)
)
register_bank_u(
    .o_sr1_data(bus_a),
    .o_sr2_data(bus_b),
    
    .i_sr1_addr(i_instruction[25:21]),
    .i_sr2_addr(i_instruction[20:16]),
    
    .i_dr_data(i_wb_reg_data),
    .i_dr_addr(i_wb_reg_addr),
    .i_wr_en  (i_wb_reg_en  ),
    
    .i_reset(i_reset)        ,
    .i_clk(i_clk)
);

// Asignacion de la salida
assign o_bus_a = reg_o_bus_a;
assign o_bus_b = reg_o_bus_b;

// Registrar salidas extendidas
always @(posedge i_clk) begin
    reg_o_ext_literal <= ext_literal;
    reg_o_ext_sa      <= ext_sa;
end

// L�gica
assign ext_literal = {{16{i_instruction[15]}},{i_instruction[15:0]}};
assign ext_sa      = {{27{1'b0}},{i_instruction[10:6]}};

// Asignaci�n de las salidas
assign o_ext_literal = reg_o_ext_literal;
assign o_ext_sa      = reg_o_ext_sa;    

// Registar la salida de alu_op
always @(posedge i_clk) begin
    reg_o_alu_op <= alu_op;
end

// Logica para determinar alu_op
always @(*) begin
    case(opcode) 
        special_OPCODE  : alu_op = func;
        addi_OPCODE     : alu_op = 6'b100001;
        andi_OPCODE     : alu_op = 6'b100100;
        xori_OPCODE     : alu_op = 6'b100110;
        ori_OPCODE      : alu_op = 6'b100101;
        lui_OPCODE      : alu_op = 6'b001111;
        slti_OPCODE     : alu_op = 6'b101010;
        jal_OPCODE      : alu_op = 6'b001001;
        
        default         : alu_op = 6'b100001;       // Ver si hay forma mas eficiente de hacer esto. Considerar que 1'b1 empieza ld y st y es siempre suma
        
    endcase
end

// Asignar la salida
assign o_alu_op = reg_o_alu_op;


/////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// CONTROL ////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

// Registrar la salida del bus de control
always @(posedge i_clk) begin
    if(i_reset) begin
        control_bus <= {NB_CONTROL_BUS{1'b0}};
    end
    else begin
        if(id_stall) begin 
            control_bus <= {NB_CONTROL_BUS{1'b0}};
        end
        else begin
            control_bus[pos_EX_CONTROL-1-:NB_CONTROL_EX] <= control_ex;
            control_bus[pos_MA_CONTROL-1-:NB_CONTROL_MA] <= control_ma;
            control_bus[pos_WB_CONTROL-1:0]              <= control_wb;
        end
    end
end

assign o_control_bus = control_bus;

// EXECUTION CONTROL LOGIC
//ver si poner lo de alu_op ac� o por separado
wire ctl_reg_dest;
wire ctl_mux_rt_imm;
wire ctl_mux_rs_sa;

wire ctl_mux_use_pc;
wire ctl_reg_dest_31;
wire jal;

//wire ctl_mux_rs_or_sa_jmp;
//wire ctl_mux_sa_jmp;

//assign control_ex = {ctl_reg_dest,ctl_mux_rs_sa,ctl_mux_rt_imm};

assign control_ex = {ctl_reg_dest,ctl_mux_rs_sa,ctl_mux_rt_imm,ctl_mux_use_pc,ctl_reg_dest_31};

assign ctl_reg_dest    = (opcode == 6'b000000) ? 1'b1 : 1'b0; 
assign ctl_mux_rt_imm  = (opcode[NB_OPCODE-1-:2] == 2'b10 || opcode[NB_OPCODE-1-:3] == 3'b001) ? 1'b0 : 1'b1;
assign ctl_mux_rs_sa   = (ctl_reg_dest && func[5] == 1'b0 && func[3:2] == 2'b00) ? 1'b0 : 1'b1;
assign ctl_mux_use_pc  = (jal || (ctl_reg_dest && func[3:0] == 4'b1001)) ? 1'b1 : 1'b0; // Si es jal o jalr
assign ctl_reg_dest_31 = (jal);

assign jal = (opcode == 6'b000011);

// MEMORY ACCESS CONTROL LOGIC
wire        ctl_mem_read ;
wire        ctl_mem_write;
wire [1:0]  ctl_adressing;
wire        ctl_signing  ;

assign control_ma = {ctl_mem_read,ctl_mem_write,ctl_adressing,ctl_signing};

assign ctl_mem_read  = (opcode[NB_OPCODE-1-:3]==3'b100) ? 1'b1 : 1'b0;  //Si es load, vale 1. 0 caso contrario
assign ctl_mem_write = (opcode[NB_OPCODE-1-:3]==3'b101) ? 1'b1 : 1'b0;  //Si es store, vale 1. 0 caso contrario

assign ctl_adressing = opcode[1:0];
assign ctl_signing   = ~opcode[2];

// WRITE BACK CONTROL LOGIC
reg ctl_reg_write;
wire ctl_mem_to_reg;

assign control_wb = {ctl_mem_to_reg,ctl_reg_write};

//ctl_mem_to_reg
assign ctl_mem_to_reg = opcode[NB_OPCODE-1]; // Pone el mux en memoria de ser ld o st. st no hay drama porque no escribe

//ctl_reg_write
always @(*) begin
    ctl_reg_write = 1'b0;

    // si es tipo r
    if(opcode == special_OPCODE) begin
        if(func!=jr_FUNC)                   ctl_reg_write = 1'b1;   // jr es tipo r pero no escribe
    end

    // si es tipo load
    if(opcode[NB_OPCODE-1-:3]==3'b100)      ctl_reg_write = 1'b1;
    
    // si es aritmetica pero no empieza en 000
    if(opcode[NB_OPCODE-1-:3]==3'b001)      ctl_reg_write = 1'b1;

    if(jal)                                 ctl_reg_write = 1'b1;
    
end


///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// JUMP LOGIC ///////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////

reg  [NB_DATA-1:0]  jump_addr;

wire [NB_DATA-1:0]  shifted_ext_literal;

wire     branch;
wire     rs_eq_rt;
wire     eq_condition;
wire     branch_condition;

wire     cond_jump;
reg      incond_jump;

reg  [NB_ADDRESS-1:0]    reg_o_pc_delay_slot;

// Logica para determinar la condicion de salto
assign shifted_ext_literal = {ext_literal[NB_DATA-3:0],2'b0};

// Logica para calcular la direccion de salto
always @(*)begin
    jump_addr = bus_a; // si es jr o jalr                                                            
    //if (opcode[NB_OPCODE:1]==5'b00010) jump_addr = i_pc + shifted_ext_literal;     // si beq o bneq                     
    if (opcode[2]==1'b1) jump_addr = i_pc + shifted_ext_literal;     // si beq o bneq                     
    if (opcode[1]==1'b1) jump_addr = {i_pc[NB_INSTRUCTIONS-1:28],i_instruction[25:0],2'b0}; //si es j o jal
    //if (opcode[NB_OPCODE:1]==5'b00001) jump_addr = {i_pc[NB_INSTRUCTIONS:28],i_instruction[25:0],2'b0}; //si es j o jal
end

// Logica para determinar si se trata de un salto incondicional
always @(*)begin
    case (opcode[NB_OPCODE-1:1])
        5'b00001: incond_jump = 1'b1;
        5'b00000: incond_jump = func[3] & (!func[1]);       //func[3]==1 y func[1]==0 son bits que valen eso solo en saltos
        default : incond_jump = 1'b0;
    endcase
end

// Logica para determinar si se trata de un salto condicional (beq o bneq)
assign cond_jump = (opcode[NB_OPCODE-1:1] == 5'b00010);

// Logica para determinar la condicion del salto
assign rs_eq_rt = (bus_a==bus_b);
assign eq_condition = ~opcode[0];   // Que sea 1 si es beq y 0 si beqn

//assign eq_condition = (opcode[NB_OPCODE-1:2] == 4'b0001) ? opcode[0] : 1'b0;
assign branch_condition = ~(eq_condition ^ rs_eq_rt);

// Logica para determinar si el salto se toma
assign branch = incond_jump | (cond_jump & branch_condition);

// Asignaci�n de las salidas
assign o_if_branch      = branch;
assign o_if_branch_addr = jump_addr;


// Respecto a escribir el retorno
always @(posedge i_clk) begin
    reg_o_pc_delay_slot <= i_pc;
end

assign o_pc_delay_slot = reg_o_pc_delay_slot;

///////////////////////////////////////////////////////////////////////////////////
///////////////////DETECTOR DE RIESGOS (HAZARD DETECTION UNIT)/////////////////////
///////////////////////////////////////////////////////////////////////////////////

always @(*) begin
    id_stall = 1'b0;
    if(i_ex_ctl_mem_read) begin
        if(i_ex_rt == i_instruction[25:21] || i_ex_rt == i_instruction[20:16]) begin
            id_stall = 1'b1;
        end
    end
end

//Asignar salida
assign o_if_stall = id_stall;



endmodule
