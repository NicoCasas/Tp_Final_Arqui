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
		input   wire  [NB_DATA    -1 :0]  i_w_data  ,
    input   wire  [NB_ADDRESS -1 :0]  i_w_addr  ,
    input   wire                      i_w_en    ,

    // Read 1 reg
    input   wire  [NB_ADDRESS -1 :0]  i_r1_addr  ,
    input   wire                      i_r1_en    ,

    // Read 2 reg
    input   wire  [NB_ADDRESS -1 :0]  i_r2_addr  ,
    input   wire                      i_r2_en    ,

    // Clk
    input                             i_clk      ,

    // Reset
    input                             i_reset    ,

  // OUTPUTS
    // Read 1 reg
		output  wire  [NB_DATA		-1 :0]  o_r1_data  ,

    // Read 2 reg
		output  wire  [NB_DATA		-1 :0]  o_r2_data
  )
  
  // INTERNAL REGS
	reg [NB_DATA-1:0]   registers [N_REGISTERS-1:0];
	reg	[NB_DATA-1:0]		reg_o_r1_data;
	reg	[NB_DATA-1:0]		reg_o_r2_data;
	
  // WRITE REG LOGIC
  always @(posedge i_clk) begin
		if(i_w_en) begin
			registers[i_w_addr] <= i_w_data;
		end
	end
  
	// READ 1 REG LOGIC
	always @(*) begin
		if(i_r1_en) begin
			reg_o_r1_data = registers[i_r1_addr];
		end
	end
	
  // READ 2 REG LOGIC
	always @(*) begin
		if(i_r2_en) begin
			reg_o_r2_data = registers[i_r2_addr];
		end
	end

  // OUTPUT ASSIGN
	assign o_r1_data = reg_o_r1_data; // Considerar hacer toda la logica en sentencia usando '?' (if de los wires)
	assign o_r2_data = reg_o_r2_data;

endmodule
	
