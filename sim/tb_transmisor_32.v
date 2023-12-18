`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2023 02:18:53
// Design Name: 
// Module Name: tb_transmisor_32
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


module tb_transmisor_32();

parameter NB_DATA = 32;
parameter NB_COUNT = 3;
parameter NB_TX_DATA = 8;
parameter NB_STATES = 3;
parameter NB_ADDRESS = 5;
parameter N_REGISTERS = 32;
parameter NB_ADDR_REGISTERS = $clog2(N_REGISTERS);
parameter N_ADDR_MEM = 64;
parameter NB_ADDR_MEM = $clog2(N_ADDR_MEM);


parameter T = 10 * 2;

integer i;

// Variables del tx
wire                    o_ready;
wire                    o_data;

reg   [NB_DATA-1:0]    data;
reg                    valid;
wire                   o_tick;

reg       clk=1'b0;
reg       reset=1'b1;

reg send_flag = 1'b0;

reg [NB_DATA-1:0] pc = 32'h99999999;

// Variables del banco de registro

// OUTPUTS

wire  [NB_DATA		-1 :0]  o_sr1_data ;
wire  [NB_DATA		-1 :0]  o_sr2_data;

//Inputs
reg [NB_DATA    -1 :0]  dr_data  ;
reg [NB_ADDRESS -1 :0]  dr_addr  ;
reg                     wr_en    ;
    
// Read 1 reg
reg  [NB_ADDRESS -1 :0]  sr1_addr  = 0;
    
// Read 2 reg
reg  [NB_ADDRESS -1 :0]  sr2_addr  ;
    
// Variables de la memoria
//OUTPUTS
wire    [NB_DATA-1:0]       mem_data    ;
    
//INPUTS
reg                        mem_en     =1   ;
reg                        mem_r_en   =1 ;
reg    [NB_ADDR_MEM-1:0]   mem_addr      ;

  
memory
#(
    .N_ADDRESS(N_ADDR_MEM),
    .NB_ADDRESS(NB_ADDR_MEM)
)
uut_memory (
    //OUTPUTS    
    .o_r_data(mem_data)    ,
    
    //INPUTS
    .i_en     (mem_en)     ,
    .i_r_en   (mem_r_en)   ,
    .i_addr   (mem_addr)   ,

    //clk
    .i_clk(clk)       
    
);




// transmisor 32    
transmisor_32
#()
uut_transmisor_32
(
    .o_ready(o_ready),
    .o_data (o_data),
    
    .i_data(data),
    .i_valid(valid),
    .i_tick(o_tick),
    
    .i_clk(clk),
    .i_reset(reset)

);

// banco de registros
register_bank#(
    .NB_DATA(NB_DATA)
)
uut_register_bank
  (
  // INPUTS
    // Write reg
	.i_dr_data  (dr_data),
	.i_dr_addr  (dr_addr),
    .i_wr_en    (wr_en),
    

    .i_sr1_addr  (sr1_addr),
	.i_sr2_addr  (sr2_addr),
    

    .i_clk      (clk),
    .i_reset    (reset),

  // OUTPUTS
	.o_sr1_data  (o_sr1_data),
	.o_sr2_data  (o_sr2_data)
  );



baudrate_gen#(
)
uut_baudrate_gen
   (
    //OUTPUTS
    .o_tick      (o_tick),
    //INPUT
    .i_clk       (clk),
    .i_reset     (reset)
);

// clk
always begin
    #(T/2)
    clk = ~clk;
end
// sim

initial begin
    #(2.5*T)
    reset = 1'b0;
    #(2*T)
    // inicio regs
    for(i=0;i<32;i=i+1) begin
        dr_data = 32'h01030700 | i;
        dr_addr = i;
        wr_en = 1'b1;
        #T
        wr_en = 1'b0;
    end
    
    // mando la data
    send_flag = 1'b1;
end



parameter NB_STATE = 4;

localparam send_pc_STATE        = 4'b0001;
localparam send_registers_STATE = 4'b0010;
localparam send_mem_STATE       = 4'b0100;
localparam finish_STATE         = 4'b1000;

reg [NB_STATE-1:0] state = send_pc_STATE;
reg [NB_STATE-1:0] nxt_state;

reg [NB_ADDR_REGISTERS-1:0] r_addr_iter=0;
reg [NB_ADDR_REGISTERS-1:0] nxt_r_addr_iter;

reg [NB_ADDR_MEM-1:0] mem_addr_iter;
reg [NB_ADDR_MEM-1:0] nxt_mem_addr_iter;

reg nxt_valid;
reg [NB_DATA-1:0] nxt_data;


always @(posedge clk) begin
    state           <= nxt_state;
    r_addr_iter     <= nxt_r_addr_iter;
    mem_addr_iter   <= nxt_mem_addr_iter;
    //sr2_addr        <= r_addr_iter;
    //mem_addr        <= mem_addr_iter;
    //data            <= nxt_data;
    //valid           <= nxt_valid;
end


always @(*) begin
    nxt_state = state;
    valid = 1'b0;
    nxt_r_addr_iter = r_addr_iter;
    nxt_mem_addr_iter = mem_addr_iter;
    data = 0;
        
    if(send_flag) begin
    case(state)
       
        send_pc_STATE:
        begin
            if(o_ready) begin
                data  = pc;
                valid = 1'b1;
                nxt_state = send_registers_STATE; 
                nxt_r_addr_iter = {NB_ADDR_REGISTERS{1'b0}};
            end
        end
    
        send_registers_STATE: 
        begin
            if(o_ready) begin    
                    nxt_r_addr_iter = r_addr_iter + {{NB_ADDR_REGISTERS-1{1'b0}},1'b1};
                    
                    sr2_addr = r_addr_iter;
                    data  = o_sr2_data;
                    valid = 1'b1;
                
                if (r_addr_iter == N_REGISTERS-1) begin
                    mem_addr_iter = {NB_ADDR_MEM{1'b0}};
                    nxt_state = send_mem_STATE;
                    
                end
            end    
         end
         
        send_mem_STATE: 
        begin
            if(o_ready) begin    
                    nxt_mem_addr_iter = mem_addr_iter + {{NB_ADDR_MEM-1{1'b0}},1'b1};
                    data  = mem_data;
                    mem_addr = mem_addr_iter;
                    valid = 1'b1;
                    
                if (mem_addr_iter == N_ADDR_MEM-1) begin
                    nxt_state = finish_STATE;    
                end
                
                
            end    
         end
         
        finish_STATE:
        begin
            if(o_ready) begin
                $finish;
            end
        end
     
        default: nxt_state = send_pc_STATE;
     
    endcase
    end
end



endmodule
