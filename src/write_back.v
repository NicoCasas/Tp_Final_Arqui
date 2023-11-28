`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2023 18:24:28
// Design Name: 
// Module Name: write_back
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


module write_back
#(
    parameter NB_DATA       = 32,
    parameter N_REGISTERS   = 32,
    parameter NB_ADDR_REGISTERS  = $clog2(N_REGISTERS),
    parameter NB_CONTROL_WB = 2
)(
    output  wire  [NB_DATA-1:0]             o_reg_w_data    ,
    output  wire  [NB_ADDR_REGISTERS-1:0]   o_reg_num       ,
    output  wire                            o_reg_w_en      ,
    
    input   wire   [NB_DATA-1:0]            i_reg_data  ,
    input   wire   [NB_DATA-1:0]            i_mem_data  ,
    
    input   wire   [NB_ADDR_REGISTERS-1:0]  i_reg_num   ,
    
    input   wire   [NB_CONTROL_WB-1:0]      i_control_wb
    
//    input   wire    i_clk   ,
//    input   wire    i_reset
);

//wire not_zero_en;

wire ctl_mem_to_reg;
wire ctl_reg_write;

assign ctl_mem_to_reg = i_control_wb[1];    // Coordinar con id
assign ctl_reg_write  = i_control_wb[0];

//assign not_zero_en = (i_reg_num != {NB_ADDR_REGISTERS{1'b0}});

//output assign
assign o_reg_w_data = (ctl_mem_to_reg) ? i_mem_data : i_reg_data; 
assign o_reg_w_en   = ctl_reg_write; //& not_zero_en;
assign o_reg_num    = i_reg_num;

endmodule
