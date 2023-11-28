`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2023 23:40:25
// Design Name: 
// Module Name: top
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


module top
#(
    INIT_P_MEM_FILE     = "file_to_test_pipeline_1.mem",
    NB_DATA             = 32,
    NB_ADDRESS          = 32,
    NB_ADDR_REGISTERS   =  5//,
//NB_ADDR_D_MEM       = 64
)
(
    output      wire o_tx,
    
    input       wire i_rx,
    input       wire i_clk,
    input       wire i_reset
);

// salidas del pipeline
wire [31:0] pl_wb_reg_w_data         ;

wire [NB_DATA-1:0]      pl_debug_reg_data            ;
wire [NB_DATA-1:0]      pl_debug_d_mem_data          ;

wire [NB_ADDRESS-1:0]   pl_if_pc        ;
wire                    pl_if_halt      ; 

// salidas de la debug unit
wire                              du_o_tx;

wire  [NB_ADDRESS       -1:0]     du_p_mem_addr;
wire  [NB_DATA          -1:0]     du_p_mem_data;
wire                              du_p_mem_w_en;
    
wire  [NB_ADDR_REGISTERS-1:0]     du_register_addr;
wire  [NB_ADDRESS-1:0]            du_d_mem_addr;
    
wire                              du_clk_en;
wire                              du_debug_flag;

wire clk;

assign o_clk = clk;
assign o_locked = locked;

assign reset = (~locked) | i_reset;


// module instantiation

// clk
clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk(clk),              // output clk
    // Status and control signals
    .reset(i_reset),        // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .i_clk(i_clk));

// pipeline
pipeline #(
    .INIT_FILE(INIT_P_MEM_FILE)
)
u_pipeline
(
    // outputs
    .o_wb_reg_w_data            (pl_wb_reg_w_data),
    
    .o_if_pc                    (pl_if_pc),
    .o_if_halt                  (pl_if_halt),
    
    .o_debug_reg_data           (pl_debug_reg_data),
    .o_debug_d_mem_data         (pl_debug_d_mem_data),
    
    // inputs
    .i_debug                    (du_debug_flag),
    
    .i_debug_p_mem_w_en         (du_p_mem_w_en),
    .i_debug_p_mem_w_addr       (du_p_mem_addr),
    .i_debug_p_mem_w_data       (du_p_mem_data),
    
    .i_debug_d_mem_addr         (du_d_mem_addr),
    .i_debug_reg_addr           (du_register_addr),
    
    .i_clk                      (clk)   ,
    .i_clk_en                   (du_clk_en),                //Esto no está haciendo efecto (puente en pipeline)
    //.i_clk_reset          //          ,
    .i_reset                    (reset)    
);

// debug unit
debug_unit
#()
u_debug_unit
(
    .o_p_mem_addr       (du_p_mem_addr),
    .o_p_mem_data       (du_p_mem_data),
    .o_p_mem_w_en       (du_p_mem_w_en),
    
    .o_register_addr    (du_register_addr),
    .o_d_mem_addr       (du_d_mem_addr),
    
    .o_clk_en           (du_clk_en),
    .o_debug_flag       (du_debug_flag),
    
    .o_tx               (du_o_tx),
    
    .i_register_data    (pl_debug_reg_data),
    //input   [NB_P_MEM_ADDR    -1:0]     i_program_memory_data,
    .i_d_mem_data       (pl_debug_d_mem_data),
    
    .i_if_pc            (pl_if_pc),
    .i_if_halt          (pl_if_halt),
    
    .i_rx               (i_rx),
    
    .i_clk              (clk),
    .i_reset            (reset)
);

assign o_tx = du_o_tx;

endmodule
