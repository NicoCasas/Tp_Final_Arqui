`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_rom_memory();
    localparam NB_DATA    = 32;
    localparam NB_ADDRESS =  4; 
    parameter INIT_FILE  = "file_to_test_if.mem";
    localparam T = 2*41.67;
    integer i;

    // Internal signals
    wire [NB_DATA-1:0]  r_data;
    
    // Storage elements
    reg                  clk = 0;
    reg                  w_en = 0;
    reg                  r_en = 0;
    
    reg [NB_ADDRESS-1:0] w_addr;
    reg [NB_ADDRESS-1:0] r_addr;
    reg [NB_DATA-1:0]    w_data;
    
    // Clk signal
    always begin
        #41.67
        clk = ~clk;
    end
    
    // Instantiate the uut
rom_memory32 #(
  // PARAMETERS
    .INIT_FILE(INIT_FILE)
  )
  memory_uut
  (
  // INPUTS
    // Read
    .i_r_addr       (r_addr),
    .i_r_en         (r_en)  ,
    
    .i_w_addr       (w_addr),
    .i_w_en         (w_en)  ,
    .i_w_data       (w_data),

    // Clock
    .i_clk          (clk),

  // OUTPUTS
    // Read
    .o_r_data (r_data)   
  );
   
  initial begin
    #41.67
    // Test: read data
    for(i=0;i<16;i=i+1) begin
        #T
        r_addr = i;
        r_en = 1;
        #T
        r_addr = 0;
        r_en = 0;
    end
    
    #T
    $finish;
  end
  
    
    
endmodule
