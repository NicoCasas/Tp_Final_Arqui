`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
//////////////////////////////////////////////////////////////////////////////////


module memory_bram_32
  #(
  // PARAMETERS
    parameter NB_DATA_BUS   = 32                ,
    parameter N_ADDRESS     = 16                 ,  // VER CONSIDERANDO QUE USO TODOS MENOS 2 PARA DIRECCIONAR LA MEMORIA
	parameter NB_ADDRESS    = $clog2(N_ADDRESS)    // No me acuerdo si habia que sumar o restar 1
    
  )
  (
  // INPUTS
    // Read
    input    wire  [ NB_ADDRESS-1:0]    i_r_addr,
    input    wire                       i_r_en  ,

    // Read
    input    wire  [ NB_ADDRESS-1:0]    i_r2_addr,
    input    wire                       i_r2_en  ,

    // Write
    input    wire  [NB_DATA_BUS-1 :0]   i_w_data,
    input    wire  [NB_ADDRESS -1 :0]   i_w_addr,
    input    wire                       i_w_en  ,

    // Clock
    input    wire                       i_clk,

  // OUTPUTS
    // Read
    output   wire   [NB_DATA_BUS-1 : 0]      o_r_data   ,
    output   wire   [NB_DATA_BUS-1 : 0]      o_r2_data
  );

  // INTERNAL REGS
	reg  [NB_DATA_BUS-1:0]  mem [0:N_ADDRESS-1] ;

    reg  [NB_DATA_BUS-1:0]  reg_o_r_data        ;
    reg  [NB_DATA_BUS-1:0]  reg_o_r2_data       ;

  // READ 2 LOGIC (async)
  // Lectura de los datos de lo que quiero escribir, para completar posteriormente con i_w_data al momento de escribir
  // Variable de interes: reg_r2_data
  always @(posedge i_clk) begin
    if(i_r2_en) begin
           reg_o_r2_data <= mem[i_r2_addr[NB_ADDRESS-1:0]];
    end
  end    

  //WRITE SYNC
  always @(negedge i_clk) begin
    if(i_w_en) begin
        mem[i_w_addr[NB_ADDRESS-1:0]] <= i_w_data;
    end
  end
  
  ///////////////////////////// READ //////////////////////////////
  // READ LOGIC (sync)
  always @(negedge i_clk) begin
    if(i_r_en) begin
        reg_o_r_data <= mem [i_r_addr[NB_ADDRESS-1:0]];
    end
  end

  // OUTPUT ASSIGN
  assign o_r_data  = reg_o_r_data; 
  assign o_r2_data = reg_o_r2_data;
  
endmodule
