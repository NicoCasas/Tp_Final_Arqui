`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 21:57:05
// Design Name: 
// Module Name: tb_memory_b32
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


module tb_memory_b32();

  localparam PERIOD = 100;
  
  localparam NB_DATA_BUS = 32;
  localparam NB_DATA = 8;
  localparam NB_ADDRESS = 6;

  localparam word_ADDRESSING = 2'b11;
  localparam half_ADDRESSING = 2'b01;
  localparam byte_ADDRESSING = 2'b00;
  
  reg  [NB_DATA_BUS-1:0] w_data;
  reg  [NB_ADDRESS-1 :0] w_addr;
  reg                    w_en;
  reg  [1:0]             w_addressing;
  
  wire [NB_DATA_BUS-1:0] r_data;
  reg  [NB_ADDRESS-1 :0] r_addr;
  reg                    r_en;
  reg  [1:0]             r_addressing;

  reg   clk;

  
  combined_memory #() uut_combined_memory(
    .i_r_addr        (r_addr),
    .i_r_en          (r_en),
    .i_r_addressing  (r_addressing),


    .i_w_addr        (w_addr),
    .i_w_data        (w_data),
    .i_w_en          (w_en),
    .i_w_addressing  (w_addressing),

    .i_clk           (clk),

    .o_r_data        (r_data)

  );

  
  always begin
    #(PERIOD/2)
    clk = ~clk;
  end

  initial begin
    clk = 1'b0;
    #(PERIOD/2)
    w_en = 1'b0;
	r_en = 1'b0;
    w_addr = 0;
    w_data = 0;


    #PERIOD
    w_data = 0;
    
    #(2*PERIOD)
    w_data = 32'h0123abcd;
    w_addressing = word_ADDRESSING;
    w_addr = 6'b000000;
    w_en = 1'b1;

    #(2*PERIOD)
    w_en = 1'b0;
    
    #(2*PERIOD)
    r_addressing = word_ADDRESSING;
    r_addr = 6'b000000;
    r_en = 1'b1;

    #(PERIOD)
    r_en = 1'b0;
    
    #(PERIOD)
    r_addressing = half_ADDRESSING;
    r_addr = 6'b000000;
    r_en = 1'b1;
    
    #(PERIOD)
    r_en = 1'b0;
 
    #(PERIOD)
    r_addressing = byte_ADDRESSING;
    r_addr = 6'b000000;
    r_en = 1'b1;

    #PERIOD
    r_en = 1'b0;

    #(2*PERIOD)
    w_data = 32'h0123abcd;
    w_addressing = half_ADDRESSING;
    w_addr = 6'b000100;
    w_en = 1'b1;

    #(2*PERIOD)
    w_en = 1'b0;
    
    #(2*PERIOD)
    r_addressing = word_ADDRESSING;
    r_addr = 6'b000100;
    r_en = 1'b1;

    #(PERIOD)
    r_en = 1'b0;
    
    #(PERIOD)
    r_addressing = half_ADDRESSING;
    r_addr = 6'b000100;
    r_en = 1'b1;
    
    #(PERIOD)
    r_en = 1'b0;
 
    #(PERIOD)
    r_addressing = byte_ADDRESSING;
    r_addr = 6'b000100;
    r_en = 1'b1;

    #PERIOD
    r_en = 1'b0;
    
    #(2*PERIOD)
    w_data = 32'h0123abcd;
    w_addressing = byte_ADDRESSING;
    w_addr = 6'b001001;
    w_en = 1'b1;

    #(2*PERIOD)
    w_en = 1'b0;
    
    #(2*PERIOD)
    r_addressing = word_ADDRESSING;
    r_addr = 6'b001000;

    r_en = 1'b1;

    #(PERIOD)
    r_en = 1'b0;
    
    #(PERIOD)
    r_addressing = half_ADDRESSING;
    r_addr = 6'b001000;
    r_en = 1'b1;
    
    #(PERIOD)
    r_en = 1'b0;
 
    #(PERIOD)
    r_addressing = byte_ADDRESSING;
    r_addr = 6'b001001;
    r_en = 1'b1;

    #PERIOD
    r_en = 1'b0;
    
    #(5*PERIOD)
    $finish();
    
  end
  
endmodule
