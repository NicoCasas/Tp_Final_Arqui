`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2023 00:56:14
// Design Name: 
// Module Name: memory_32
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


module memory_32
  #(
  // PARAMETERS
    parameter NB_DATA_BUS = 32,
    parameter NB_DATA = 8,
    parameter N_ADDRESS = 64,                // VER CONSIDERANDO QUE USO TODOS MENOS 2 PARA DIRECCIONAR LA MEMORIA
	parameter NB_ADDRESS = $clog2(N_ADDRESS) // No me acuerdo si habia que sumar o restar 1
    
  )
  (
  // INPUTS
    // Read
    input    wire  [ NB_ADDRESS-1:0]    i_r_addr,
    input    wire                       i_r_en  ,
	input	 wire	 [ 1 : 0 ]			i_r_addressing,

    // Write
    input    wire  [NB_DATA_BUS-1 : 0 ] i_w_data,
    input    wire  [NB_ADDRESS-1:0]     i_w_addr,
    input    wire                       i_w_en  ,
	input	 wire  [1:0]			    i_w_addressing,

    // Clock
    input    wire                       i_clk,

  // OUTPUTS
    // Read
    output   wire  [NB_DATA_BUS-1 : 0]      o_r_data
  );

	// LOCALPARAMS
	localparam word_ADDRESSING = 2'b00;
	localparam half_ADDRESSING = 2'b01;
	localparam byte_ADDRESSING = 2'b11;
	
  // INTERNAL REGS
	reg  [NB_DATA_BUS-1:0]  mem [0:N_ADDRESS-1] ;
	wire [NB_ADDRESS-1:0]   r2_addr             ;
	wire                    r2_en               ;
	reg  [NB_DATA_BUS-1:0]  reg_r2_data         ;
	
	reg  [NB_DATA_BUS-1:0]  w_data              ;
	
	reg  [NB_DATA_BUS-1:0]  r_data              ;
	reg  [NB_DATA_BUS-1:0]  reg_o_r_data        ;


    wire                    w_en;
    reg                     w_addressing_en;
    
    wire                    r_en;
    reg                     r_addressing_en;
    
  assign r2_addr = i_w_addr;
  assign r2_en = w_en;//1'b1;
  
  assign w_en = i_w_en & w_addressing_en;
  
  assign r_en = i_r_en & r_addressing_en;
  // Logica para determinar si la alineacion de la escritura es correcta 
  always @(*) begin
    case (i_w_addressing) 
        word_ADDRESSING: w_addressing_en = (i_w_addr[1:0]==2'b00);
        half_ADDRESSING: w_addressing_en = (i_w_addr[  0]==1'b0 );
        byte_ADDRESSING: w_addressing_en = 1'b1;
        default: w_addressing_en = 1'b0;
    endcase
  end
  
  // READ 2 LOGIC (async)
  // Lectura de los datos de lo que quiero escribir, para completar posteriormente con i_w_data al momento de escribir
  // Variable de interes: reg_r2_data
  always @(posedge i_clk) begin
    if(r2_en) begin
        reg_r2_data = mem[r2_addr[NB_ADDRESS-1:2]];
    end
    //else reg_r2_data = {NB_DATA_BUS{1'bx}};//TODO VER
  end    
  
  // Logica para determinar el valor de entrada de escritura a la memoria, junta el valor de i_w_data con lo 
  // que ya se tenia en la ram.
  // Variable de interes: w_data
  always @(*) begin
    w_data = {NB_DATA_BUS{1'bx}};
    case (i_w_addressing)
        word_ADDRESSING: begin
            if(i_w_addr[1:0]==2'b00) begin
                w_data = i_w_data;
            end
        end
        
        half_ADDRESSING: begin
            if(i_w_addr[0] == 1'b0) begin
                case (i_w_addr[1]) 
                    1'b0: begin
                        w_data = {reg_r2_data[31:16],i_w_data[15:0]};
                    end
                    1'b1: begin
                        w_data = {i_w_data[15:0],reg_r2_data[15:0]};
                    end
                endcase
            end
        end
        
        byte_ADDRESSING: begin
            case(i_w_addr[1:0])
                2'b00: begin
                    w_data = {reg_r2_data[31:8],i_w_data[7:0]};
                end
                2'b01: begin
                    w_data = {reg_r2_data[31:16],i_w_data[7:0],reg_r2_data[7:0]};
                end
                2'b10: begin
                    w_data = {reg_r2_data[31:24],i_w_data[7:0],reg_r2_data[15:0]};
                end
                2'b11: begin
                    w_data = {i_w_data[7:0],reg_r2_data[23:0]};
                end
            endcase
        end
        
    endcase
  end
  
  //WRITE SYNC
  always @(negedge i_clk) begin
    if(i_w_en) begin
        mem[i_w_addr[NB_ADDRESS-1:2]] <= w_data;
    end
  end
  
  ///////////////////////////// READ //////////////////////////////
  
  // Logica para determinar si la alineacion de la lectura es correcta 
  always @(*) begin
    case (i_r_addressing) 
        word_ADDRESSING: r_addressing_en = (i_r_addr[1:0]==2'b00);
        half_ADDRESSING: r_addressing_en = (i_r_addr[  0]==1'b0 );
        byte_ADDRESSING: r_addressing_en = 1'b1;
        default: r_addressing_en = 1'b0;
    endcase
  end

  // READ LOGIC (async)
  always @(negedge i_clk) begin
    if(r_en) begin
        r_data = mem [i_r_addr[NB_ADDRESS-1:2]];
    end
    //else r_data = {NB_DATA_BUS{1'bz}};
  end
 
 always @(*) begin
    reg_o_r_data = {NB_DATA_BUS{1'bz}};
    if (r_en)begin
        case (i_r_addressing)
            word_ADDRESSING: reg_o_r_data = {r_data};
            
            half_ADDRESSING: begin
                case (i_r_addr[1])
                    1'b0: reg_o_r_data = {{16{1'b0}},r_data[15:0]};
                    1'b1: reg_o_r_data = {{16{1'b0}},r_data[31:16]};
                endcase
            end
            
            byte_ADDRESSING: begin
                case (i_r_addr[1:0])
                    2'b00: reg_o_r_data = {{24{1'b0}},r_data[7:0]};
                    2'b01: reg_o_r_data = {{24{1'b0}},r_data[15:8]};
                    2'b10: reg_o_r_data = {{24{1'b0}},r_data[23:16]};
                    2'b11: reg_o_r_data = {{24{1'b0}},r_data[31:24]};
                endcase
            end 
        endcase
    end
        
 end

  // OUTPUT ASSIGN
  assign o_r_data = reg_o_r_data; 
  
endmodule
