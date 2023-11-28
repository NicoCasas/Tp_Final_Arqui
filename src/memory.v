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
    parameter NB_DATA       =   32  ,
    parameter N_ADDRESS     =   32  ,
    parameter INIT_FILE     =  "",// "file_to_test_if.mem"  ,
    parameter COL_WIDTH     =    8  ,
    parameter NB_ADDRESS    =  $clog2(N_ADDRESS)    

)(
    //OUTPUTS    
    output  wire    [NB_DATA-1:0]       o_r_data    ,

    output  wire    [NB_DATA-1:0]       o_d_r_data  ,
    
    //INPUTS
    input   wire                        i_en        ,
    input   wire                        i_r_en      ,
    input   wire    [NB_ADDRESS-1:0]    i_addr      ,
    input   wire    [NB_DATA-1:0]       i_w_data    ,
    input   wire    [3:0]               i_w_en      ,

    input   wire                        i_d_en      ,
    input   wire    [NB_ADDRESS-1:0]    i_d_addr    ,

    //clk
    input   wire                        i_clk       
    
   );
   
    reg [NB_DATA-1:0] mem [0:N_ADDRESS-1];
    //reg [NB_ADDRESS-1:0] addr;
    reg [NB_DATA-1:0] reg_o_r_data;
    reg [NB_DATA-1:0] reg_o_d_r_data;
   
    always @(negedge i_clk) begin
        if(i_en) begin
            if(i_w_en[0])begin
                mem[i_addr][7:0] <= i_w_data[7:0];
            end
            if(i_w_en[1])begin
                mem[i_addr][15:8] <= i_w_data[15:8];
            end
            if(i_w_en[2])begin
                mem[i_addr][23:16] <= i_w_data[23:16];
            end
            if(i_w_en[3])begin
                mem[i_addr][31:24] <= i_w_data[31:24];
            end
            
            //addr <= i_addr;
            if(i_r_en) reg_o_r_data <= mem[i_addr];
            else       reg_o_r_data <= {NB_DATA{1'b0}};
        end
        
    end
   
   always @(negedge i_clk) begin
        if(i_d_en) reg_o_d_r_data <= mem[i_d_addr]; 
   end
   
    initial if (INIT_FILE) begin
        $readmemb(INIT_FILE,mem); 
    end

   
   //output assign
   assign o_r_data = reg_o_r_data;
   
   assign o_d_r_data = reg_o_d_r_data;
   
endmodule
