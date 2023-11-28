`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 21:27:02
// Design Name: 
// Module Name: combined_memory
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
//                      Si la entrada o salida empieza con i_d_/o_d_ significa que 
//                      viene por el puerto de debug
//
//////////////////////////////////////////////////////////////////////////////////


module combined_memory
  #(
  // PARAMETERS
    parameter NB_DATA_BUS = 32,
    parameter NB_DATA = 8,
    parameter N_ADDRESS = 128,                // VER CONSIDERANDO QUE USO TODOS MENOS 2 PARA DIRECCIONAR LA MEMORIA
	parameter NB_ADDRESS = $clog2(N_ADDRESS), // No me acuerdo si habia que sumar o restar 1
    
    parameter N_ADDRESS_WORDS = N_ADDRESS/4,
    parameter NB_ADDRESS_WORDS = $clog2(N_ADDRESS_WORDS)
    
  )
  (
  
    // OUTPUTS
    // Read
    output  wire    [NB_DATA_BUS-1 : 0]     o_r_data   ,
    output  wire    [NB_DATA_BUS-1 : 0]     o_d_r_data ,
  
    // INPUTS
    input   wire    [NB_ADDRESS-1:0]        i_addr,
    input	wire	[1:0]			        i_addressing,

    input   wire                            i_d_en       ,
    input   wire    [NB_ADDRESS_WORDS-1:0]  i_d_addr     ,
    
    // Read
    input   wire                       i_r_en  ,
    input   wire                       i_r_signing,
	
    // Write
    input   wire  [NB_DATA_BUS-1 : 0 ] i_w_data,
    input   wire                       i_w_en  ,
	
    // Clock
    input   wire                       i_clk

  
  );

	// LOCALPARAMS
	localparam word_ADDRESSING = 2'b11;
	localparam half_ADDRESSING = 2'b01;
	localparam byte_ADDRESSING = 2'b00;
	
  // INTERNAL REGS
	reg  [NB_DATA_BUS-1:0]  w_data              ;
	wire  [NB_DATA_BUS-1:0] r_data              ;
	
	reg  [NB_DATA_BUS-1:0]  reg_o_r_data        ;

    wire                    en;
    reg      [3:0]          w_en;
    reg                     addressing_en;
  
     
  assign en = (i_r_en | i_w_en) & addressing_en;
 
  // Logica para determinar si la alineacion es correcta 
  always @(*) begin
    case (i_addressing) 
        word_ADDRESSING: addressing_en = (i_addr[1:0]==2'b00);
        half_ADDRESSING: addressing_en = (i_addr[0]  ==1'b0 );
        byte_ADDRESSING: addressing_en = 1'b1;
        default: addressing_en = 1'b0;
    endcase
  end
    
  // Logica para determinar el valor de entrada de escritura a la memoria, junta el valor de i_w_data con lo 
  // que ya se tenia en la ram.
  // Variable de interes: w_data
  always @(*) begin
    w_data = {NB_DATA_BUS{1'bx}};
    
    case (i_addressing)
        word_ADDRESSING: begin
            w_data = i_w_data;
        end
        
        half_ADDRESSING: begin
            case (i_addr[1]) 
                1'b0: w_data[15: 0] = {i_w_data[15:0]};
                1'b1: w_data[31:16] = {i_w_data[15:0]};
            endcase        
        end
        
        byte_ADDRESSING: begin
            case(i_addr[1:0])
                2'b00: w_data[ 7: 0] = {i_w_data[7:0]};
                2'b01: w_data[15: 8] = {i_w_data[7:0]};
                2'b10: w_data[23:16] = {i_w_data[7:0]};
                2'b11: w_data[31:24] = {i_w_data[7:0]};
            endcase
        end
        
    endcase
  end
  
  // w_en
  always @(*) begin
    w_en = {4'b0000};
    if(i_w_en) begin    
        case (i_addressing)
        
            word_ADDRESSING: begin
                w_en = {4'b1111};
            end
            
            half_ADDRESSING: begin
                case (i_addr[1]) 
                    1'b0: w_en = {4'b0011};
                    1'b1: w_en = {4'b1100};
                endcase        
            end
            
            byte_ADDRESSING: begin
                case(i_addr[1:0])
                    2'b00: w_en = {4'b0001};
                    2'b01: w_en = {4'b0010};
                    2'b10: w_en = {4'b0100};
                    2'b11: w_en = {4'b1000};
                endcase
            end
            
        endcase
    end

  end  
  
  ///////////////////////////// READ //////////////////////////////
  
 always @(*) begin
    reg_o_r_data = {NB_DATA_BUS{1'bz}};
        case (i_addressing)
            
            word_ADDRESSING: begin
                reg_o_r_data = {r_data};
            end
            
            half_ADDRESSING: begin
                case (i_addr[1])
                    1'b0: begin
                        if(i_r_signing) reg_o_r_data = {{16{r_data[15]}},r_data[15:0]};
                        else            reg_o_r_data = {{16{1'b0}}      ,r_data[15:0]};
                    end
                    
                    1'b1: begin
                        if(i_r_signing) reg_o_r_data = {{16{r_data[31]}},r_data[31:16]};
                        else            reg_o_r_data = {{16{1'b0}}      ,r_data[31:16]};
                    end
                endcase
            end
            
            byte_ADDRESSING: begin
                case (i_addr[1:0])
                    2'b00: begin
                        if(i_r_signing) reg_o_r_data = {{24{r_data[7]}} ,r_data[7:0]};
                        else            reg_o_r_data = {{24{1'b0}}      ,r_data[7:0]};
                    end
                    2'b01: begin
                        if(i_r_signing) reg_o_r_data = {{24{r_data[15]}},r_data[15:8]};
                        else            reg_o_r_data = {{24{1'b0}}      ,r_data[15:8]};
                    end
                    2'b10: begin
                        if(i_r_signing) reg_o_r_data = {{24{r_data[23]}},r_data[23:16]};
                        else            reg_o_r_data = {{24{1'b0}}      ,r_data[23:16]};
                    end
                    2'b11: begin
                        if(i_r_signing) reg_o_r_data = {{24{r_data[31]}},r_data[31:24]};
                        else            reg_o_r_data = {{24{1'b0}}      ,r_data[31:24]};
                    end
                endcase
            end 
        endcase
        
 end
 
 //Memory declaration
memory
#(
)
data_memory(
    //OUTPUTS    
    .o_r_data   (r_data) ,

    .o_d_r_data (o_d_r_data)    ,
    
    //INPUTS
    .i_en        (en),
    .i_r_en      (i_r_en),
    .i_addr      (i_addr[NB_ADDRESS-1:2]),
    .i_w_data    (w_data),
    .i_w_en      (w_en),

    .i_d_en     (i_d_en),
    .i_d_addr   (i_d_addr),

    //clk
    .i_clk       (i_clk)       
    
   );

  // OUTPUT ASSIGN
  assign o_r_data = reg_o_r_data; 
  
endmodule

