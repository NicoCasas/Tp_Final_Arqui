module tb_memory();

  localparam T = 100;
  
  localparam NB_DATA_BUS = 24;
  localparam NB_DATA = 8;
  localparam NB_ADDRESS = 6;

  localparam word_ADDRESSING = 2'b00;
  localparam half_ADDRESSING = 2'b01;
  localparam byte_ADDRESSING = 2'b11;
  
  reg  [NB_DATA_BUS-1:0] w_data;
  reg  [NB_ADDRESS-1 :0] w_addr;
  reg                    w_en;
  reg  [1:0]             w_addressing;
  
  wire [NB_DATA_BUS-1:0] r_data;
  reg  [NB_ADDRESS-1 :0] r_addr;
  reg                    r_en;
  reg  [1:0]             r_addressing;

  wire   clk;

  memory #() memory_uut(
    i_r_addr        (r_addr),
    i_r_en          (r_en),
    i_r_addressing  (r_addressing),


    i_w_addr        (w_addr),
    i_w_data        (w_data),
    i_w_en          (w_en),
    i_w_addressing  (w_addressing),

    i_clk           (clk),

    o_r_data        (r_data)

  );

  
  always begin
    #(T/2)
    clk = ~clk;
  end

  initial begin
    #10
    w_en = 1'b0;
    w_addr = 0;
    w_data = 0;

    #90
    w_data = 0;
    
    #(2*T)
    w_data = 32'h0123abcd;
    w_addressing = 2'b00;
    w_addr = 6'b000000;
    w_en = 1'b1;

    #(T)
    w_en = 1'b0;
    
    #(2*T)
    r_addressing = 2'b00;
    r_addr = 6'b000000;
    r_en = 1'b1;

    #(2*T)
    r_en = 1'b0;
    
    #(2*T)
    r_addressing = 2'b11;
    r_addr = 6'b000000;
    r_en = 1'b1;
    
    #(2*T)
    r_en = 1'b0;
 
    #(2*T)
    r_addressing = 2'b10;
    r_addr = 6'b000000;
    r_en = 1'b1;


    #(5*T)
    $finish();
    
  end


  
endmodule
