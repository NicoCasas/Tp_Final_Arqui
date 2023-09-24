`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2023 16:51:00
// Design Name: 
// Module Name: memory
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


module memory
#(
//PARAMETERS
    parameter NB_DATA       =  32   ,
    parameter NB_ADDRESS    =  4    ,
    parameter N_ADDRESS     =  16
)(
//INPUTS
    //read
    input   wire    [NB_ADDRESS-1:0]    i_r_addr    ,
    //input   wire    [NB_DATA-1:0]       i_data_r    ,
    input   wire                        i_r_en      ,
    
    //write    
    input   wire    [NB_ADDRESS-1:0]    i_w_addr    ,
    input   wire    [NB_DATA-1:0]       i_w_data    ,
    input   wire                        i_w_en      ,

    //clk
    input   wire                        i_clk       ,

    
//OUTPUTS
    //read    
    output  wire    [NB_DATA-1:0]       o_r_data
    
   );
   
    reg [NB_DATA-1:0]   mem [N_ADDRESS-1:0];
    reg [NB_DATA-1:0]   reg_o_r_data;
   
    always @(posedge i_clk) begin
        if(i_r_en)begin
            reg_o_r_data <= mem[i_r_addr];
        end
        if(i_w_en)begin
            mem[i_w_addr] <= i_w_data;
        end
    end
   
    assign o_r_data = reg_o_r_data;  
   
endmodule
