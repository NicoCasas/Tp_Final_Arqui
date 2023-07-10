module register_bank
  #(
    // PARAMETERS
    parameter  NB_DATA = 8,
    parameter  NB_ADDRESS = 5,
    parameter  N_REGISTERS = 32
  )
  (
  // INPUTS
    // Write reg
		input   wire  [NB_DATA    -1 :0]  i_dr_data  ,
		input   wire  [NB_ADDRESS -1 :0]  i_dr_addr  ,
    
    // Read 1 reg
		input   wire  [NB_ADDRESS -1 :0]  i_sr1_addr  ,
    
    // Read 2 reg
		input   wire  [NB_ADDRESS -1 :0]  i_sr2_addr  ,
    
    // Clk
    input                             i_clk      ,

    // Reset
    input                             i_reset    ,

  // OUTPUTS
    // Read 1 reg
		output  wire  [NB_DATA		-1 :0]  o_sr1_data  ,

    // Read 2 reg
		output  wire  [NB_DATA		-1 :0]  o_sr2_data
  )
  
  // INTERNAL REGS
	reg [NB_DATA-1:0]   registers [N_REGISTERS-1:0];
	
  // WRITE REG LOGIC
  always @(posedge i_clk) begin
		registers[i_dr_addr] <= i_dr_data;
	end
  
  // OUTPUT ASSIGN
	assign o_r1_data = registers[i_sr1_addr]; // Considerar hacer toda la logica en sentencia usando '?' (if de los wires)
	assign o_r2_data = registers[i_sr2_addr];
	
endmodule
	
