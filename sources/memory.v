module memory
  #(
  // PARAMETERS
    parameter NB_DATA = 32,
    parameter N_ADDRESS = 64,
		parameter NB_ADDRESS = $clog2(N_ADDRESS) // No me acuerdo si habia que sumar o restar 1
    
  )
  (
  // INPUTS
    // Read
    input    wire  [ NB_ADDRESS-1:0]    i_r_addr,
    input    wire                       i_r_en  ,

    // Write
    input    wire  [ NB_DATA-1 : 0 ]    i_w_data,
    input    wire  [ NB_ADDRESS-1:0]    i_w_addr,
    input    wire                       i_w_en  ,

    // Clock
    input    wire  [ NB_DATA-1:0 ]      i_clk,

  // OUTPUTS
    // Read
    output   wire  [NB_DATA-1 : 0]      o_r_data
  )

  // INTERNAL REGS
	reg  [NB_DATA-1:0]  mem [N_ADDRESS-1:0] ;
  reg  [NB_DATA-1:0]  reg_o_r_data ;

  // WRITE LOGIC  (sync)
  always @(posedge i_clk) begin
    if(i_w_en) begin
      mem[i_w_addr] <= i_w_data;
    end
  end

  // READ LOGIC (async)
  always @(*) begin
    if(i_r_en) begin
      reg_o_r_data = mem[i_r_add];
    end
  end

  // OUTPUT ASSIGN
  assign o_r_data = reg_o_r_data; 
  
endmodule

  
