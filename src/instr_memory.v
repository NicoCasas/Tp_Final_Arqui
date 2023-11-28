`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.10.2023 13:02:57
// Design Name: 
// Module Name: instr_memory
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


module instr_memory
#(
  // PARAMETERS
    parameter NB_DATA_BUS   = 32                 ,
    parameter N_ADDRESS     = 128                ,  
	parameter NB_ADDRESS    = $clog2(N_ADDRESS)  ,  // No me acuerdo si habia que sumar o restar 1
    parameter INIT_FILE     = ""                    // Completar para sintesis
  )
  (
  // INPUTS
    // Read
    input    wire  [ NB_ADDRESS -1:0]    i_r_addr,
    input    wire                        i_r_en  ,
    
    input    wire  [ NB_ADDRESS -1:0]    i_w_addr,
    input    wire                        i_w_en  ,
    input    wire  [ NB_DATA_BUS-1:0]    i_w_data,

    // Clock
    input    wire                        i_clk,

  // OUTPUTS
    // Read
    output   wire   [NB_DATA_BUS-1 : 0]      o_r_data   
  );

  // INTERNAL REGS
	reg  [NB_DATA_BUS-1:0]  mem [0:N_ADDRESS-1] ;

    reg  [NB_DATA_BUS-1:0]  reg_o_r_data        ;
  
  ///////////////////////////// READ //////////////////////////////
  // READ LOGIC (sync)
  always @(negedge i_clk) begin
    if(i_r_en) begin
        reg_o_r_data <= mem [i_r_addr];
    end
    if(i_w_en) begin
        mem[i_w_addr] <= i_w_data;
    end
  end
  
//  always @(posedge i_clk) begin
//    if(i_w_en) begin
//        mem[i_w_addr] <= i_w_data;
//    end
//  end
  
  
  ///////////////////////////// ROM ///////////////////////////////
  initial if (INIT_FILE) begin
        $readmemb(INIT_FILE,mem); //Poner de donde a donde :D
  end

  // OUTPUT ASSIGN
  assign o_r_data  = reg_o_r_data; 
  
endmodule


