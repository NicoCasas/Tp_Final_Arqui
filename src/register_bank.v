module register_bank
  #(
    // PARAMETERS
    parameter  NB_DATA     =  8,
    parameter  NB_ADDRESS  =  5,
    parameter  N_REGISTERS = 32
  )
  (
  // INPUTS
    // Write reg
	input   wire  [NB_DATA    -1 :0]  i_dr_data  ,
	input   wire  [NB_ADDRESS -1 :0]  i_dr_addr  ,
    input   wire                      i_wr_en    ,
    
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
  );
  
  // INTERNAL REGS
	reg [NB_DATA   -1:0]   registers [0:N_REGISTERS-1];
	  
  // WRITE REG LOGIC
  always @(negedge i_clk) begin
    if(i_reset) begin
        registers[0] <= {NB_DATA{1'b0}};    
    end
    else begin
        if (i_wr_en) registers[i_dr_addr] <= i_dr_data;
    end
  end
  
  // OUTPUT ASSIGN
	assign o_sr1_data = registers[i_sr1_addr]; // Considerar hacer toda la logica en sentencia usando '?' (if de los wires)
	assign o_sr2_data = registers[i_sr2_addr];
	
endmodule
	
