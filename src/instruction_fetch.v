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
    parameter NB_DATA        =                  32           ,
    parameter NB_ADDRESS     =                  32           ,
    parameter N_MEM_ADDRESS  =                 128           ,
    parameter NB_MEM_ADDRESS =      $clog2(N_MEM_ADDRESS)+2  ,
    parameter INIT_FILE      =                  ""    
)
(
    //OUTPUTS
    output  wire [NB_DATA   -1:0]   o_instruction       ,
    output  wire [NB_ADDRESS-1:0]   o_next_pc_1         , 
        
    //INPUTS
    input   wire                    i_branch            ,
    input   wire [NB_ADDRESS-1:0]   i_branch_addr       ,
    
    input   wire                    i_stall             ,    
    input   wire                    i_halt              ,
    //input   wire                    i_int               , //Esto es pa tirar chiches
    
    input   wire                    i_debug             ,
    input   wire                    i_debug_w_en        ,
    input   wire  [NB_ADDRESS-1:0]  i_debug_w_addr      ,
    input   wire  [NB_DATA   -1:0]  i_debug_w_data      ,
      
    input   wire i_clk                                  ,
    input   wire i_clk_en                               ,
    input   wire i_reset
 
);

//LOCALPARAMS
localparam nop_CODE = 32'h0000_0000;

//program counter
reg  [NB_ADDRESS-1:0]   pc;
reg  [NB_ADDRESS-1:0]   next_pc;
wire [NB_ADDRESS-1:0]   next_pc_1;
wire [NB_ADDRESS-1:0]   next_pc_2;

reg  [NB_ADDRESS-1:0]   reg_o_next_pc_1;

wire branch_en;
wire mem_r_en;

wire halt;

//instruction register
reg  [NB_DATA-1:0]   ir; 
reg  [NB_DATA-1:0]   next_ir;
wire [NB_DATA-1:0]   mem_ir;
    
//instanciacion de la memoria de instrucciones
instr_memory#(
  // PARAMETERS
    .NB_DATA_BUS( NB_DATA   )                ,
    .N_ADDRESS  ( N_MEM_ADDRESS )            ,  
    .INIT_FILE  ( INIT_FILE )
  )
program_memory
  (
  // INPUTS
    // Read
    .i_r_addr(pc[NB_MEM_ADDRESS-1:2])     ,
    .i_r_en(mem_r_en)                     ,

    // Write
    .i_w_addr(i_debug_w_addr[NB_MEM_ADDRESS-3:0]),
    .i_w_en  (i_debug_w_en & i_debug),
    .i_w_data(i_debug_w_data),

    // Clock
    .i_clk(i_clk)                         ,

  // OUTPUTS
    // Read
    .o_r_data(mem_ir)   
  );

//mem_r_en
assign mem_r_en = (pc[1:0]=={2{1'b0}}); //Habilito la lectura en caso de estar alineado el pc

//halt
assign halt = i_halt;// & ~i_int;

//next_pc_1
assign next_pc_1 = pc + {{NB_ADDRESS-3{1'b0}},3'b100};

//next_pc_2
assign next_pc_2 = i_branch_addr;
assign branch_en = i_branch_addr[1:0] == {2{1'b0}};

//next_pc
always @(*) begin
                             next_pc = next_pc_1;
    if(i_branch & branch_en) next_pc = next_pc_2;
    if(i_stall | halt)       next_pc = pc;           // La prioridad la tiene el stall
    
end

//pc logic
always @(posedge i_clk) begin 
    if(i_reset) begin
        pc <= {NB_ADDRESS{1'b0}};
    end
    else if (i_clk_en) begin
        //if(i_branch==0)
        pc <= next_pc;  
    end    
end

//// IR LOGIC
always @(*)begin
    next_ir = mem_ir;
    if(i_stall | halt) next_ir = ir;
end

always @(posedge i_clk) begin
    if(i_reset) begin
        ir <= nop_CODE;
    end
    else if (i_clk_en) begin    
        ir <= next_ir;
    end
end


// OUTPUT REGISTER (next_pc_1)
always @(posedge i_clk) begin
    //if(i_reset)         reg_o_next_pc_1 <= {NB_ADDRESS{1'b0}};
    //else 
    if(i_clk_en)   reg_o_next_pc_1 <= next_pc_1;

end

//OUTPUT ASSIGN
assign o_instruction = ir;
assign o_next_pc_1 = reg_o_next_pc_1;     //registrar

endmodule
