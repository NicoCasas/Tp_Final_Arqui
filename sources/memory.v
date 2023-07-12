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
		input		 wire	 [ 1 : 0 ]						i_r_addressing,

    // Write
    input    wire  [ NB_DATA-1 : 0 ]    i_w_data,
    input    wire  [ NB_ADDRESS-1:0]    i_w_addr,
    input    wire                       i_w_en  ,
		input		 wire	 [ 1 : 0 ]						i_w_addressing,

    // Clock
    input    wire  [ NB_DATA-1:0 ]      i_clk,

  // OUTPUTS
    // Read
    output   wire  [NB_DATA-1 : 0]      o_r_data
  )

	// LOCALPARAMS
	localparam word_ADDRESSING = 2'b00;
	localparam half_ADDRESSING = 2'b01;
	localparam byte_ADDRESSING = 2'b11;
	
  // INTERNAL REGS
	reg  [7:0]  mem [N_ADDRESS-1:0] ;
	reg  [7:0]  reg_o_r_data ;

  // WRITE LOGIC  (sync)
  always @(posedge i_clk) begin
    if(i_w_en) begin
			case (i_w_addressing)
				
				word_ADDRESSING: begin
					if (i_w_addr[1:0] == 2'b00) begin
						mem[i_w_addr	  ] <= i_w_data[7:0];
						mem[i_w_addr + 1] <= i_w_data[15:8];
						mem[i_w_addr + 2] <= i_w_data[23:16];
						mem[i_w_addr + 3] <= i_w_data[31:24];
					end
				end
				
				half_ADDRESSING: begin
					if (i_w_addr[0] == 1'b0) begin
						mem[i_w_addr	  ] <= i_w_data[7:0];
						mem[i_w_addr + 1] <= i_w_data[15:8];
					end
				end

				byte_ADDRESSING: begin
					mem[ i_w_addr	  ] <= i_w_data[7:0];
				end
				
				default begin
					mem[ i_w_addr		] <= mem[i_w_addr];
				end
				
			endcase
		end
  end

  // READ LOGIC (async)
  always @(*) begin
    if(i_r_en) begin
			case (i_r_addressing)
				
				word_ADDRESSING: begin
					if(i_r_add[1:0]==2b'00) begin
						reg_o_r_data = {mem[i_r_addr+3],mem[i_r_addr+2],mem[i_r_addr+1],mem[i_r_addr]};
					end
				end
				
				half_ADDRESSING: begin
					if(i_r_add[0]==1'b0) begin
						reg_o_r_data = {{8{1'b0}},{8{1'b0}},mem[i_r_addr+1],mem[i_r_addr]};
					end
				end
				
				byte_ADDRESSING: begin
					reg_o_r_data = {{8{1'b0}},{8{1'b0}},{8{1'b0},mem[i_r_addr]};
				end
				
				default:
			  	reg_o_r_data = {32,{1'bx}};
				end
													
			endcase
    end
  end

  // OUTPUT ASSIGN
  assign o_r_data = reg_o_r_data; 
  
endmodule

  
