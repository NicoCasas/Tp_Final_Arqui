`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.10.2023 19:01:46
// Design Name: 
// Module Name: tb_to_test_du
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


module tb_to_test_du();

parameter T = 10;

parameter INIT_FILE = "file_to_test_du.mem";
    
parameter NB_DATA = 32;
parameter NB_ADDRESS = 32;

parameter N_P_MEM_ADDR = 64;
parameter NB_P_MEM_ADDR = $clog2(N_P_MEM_ADDR);

parameter N_D_MEM_ADDR = 64;
parameter NB_D_MEM_ADDR = $clog2(N_D_MEM_ADDR);

parameter NB_ADDR_REGISTERS = 5;

parameter NB_TX             = 8;
parameter NB_RX             = 8;

// outputs
wire [NB_TX-1:0] o_pc_rx_o_data;
wire             o_pc_rx_valid;

wire             o_pc_tx_ready;

wire  [NB_DATA-1:0]          o_pc_p_mem_data;
wire  [NB_DATA-1:0]          o_fpga_p_mem_data;

//inputs 
//reg            i_tx;
//reg            i_tx_valid=0;

reg [NB_DATA-1:0]  i_rb_dr_data  = 0;
reg [4:0]          i_rb_dr_addr  = 0;
reg                i_rb_dr_wr_en = 0;

reg  [NB_ADDRESS-1:0]   i_if_pc     =32'h9999_9999;    
reg                     i_if_halt   =0;

reg  [NB_TX-1:0]   i_pc_tx_data=0;
reg                i_pc_tx_valid=0;

reg  [ NB_ADDRESS -1:0]    i_pc_mem_addr;
reg                        i_pc_mem_r_en=0;

reg  [ NB_ADDRESS -1:0]    i_fpga_mem_addr;
reg                        i_fpga_mem_r_en=0;


reg            clk = 1'b1;
reg            reset = 1'b1;

integer i,j;

reg  [31:0] to_send;
reg         halt_flag = 1'b0;


to_test_du#(
    .NB_DATA(NB_DATA)
)
uut
(
    .o_pc_rx_o_data(o_pc_rx_o_data),
    .o_pc_rx_valid(o_pc_rx_valid),
    
    .o_pc_tx_ready(o_pc_tx_ready),
    
    .o_pc_p_mem_data(o_pc_p_mem_data),
    .o_fpga_p_mem_data(o_fpga_p_mem_data),
    
    //.i_tx (i_tx),
    //.i_tx_valid (i_tx_valid),
    
    .i_rb_dr_data  (i_rb_dr_data),
	.i_rb_dr_addr  (i_rb_dr_addr),
    .i_rb_dr_wr_en (i_rb_dr_wr_en),

    .i_if_pc     (i_if_pc),    
    .i_if_halt   (i_if_halt),
    
    .i_pc_tx_data(i_pc_tx_data),
    .i_pc_tx_valid(i_pc_tx_valid),
    
    .i_pc_mem_addr(i_pc_mem_addr),
    .i_pc_mem_r_en  (i_pc_mem_r_en),

    .i_fpga_mem_addr(i_fpga_mem_addr),
    .i_fpga_mem_r_en(i_fpga_mem_r_en)  ,

    
    .i_clk(clk),
    .i_reset(reset)
);

//clk
always begin
    #(T/2)
    clk = ~clk;
end

//sim
initial begin
    // sacar reset
    #(2*T)
    reset = 0;
    // cargar regs
    #(10*T)
    i_rb_dr_wr_en = 1'b1;
    for(i=0;i<32;i=i+1) begin
        #T
        i_rb_dr_data = i + 64;
        i_rb_dr_addr = i;
    end
    #T
    i_rb_dr_wr_en = 1'b0;
    
    // pasar p_mem
    #(T)
    for(i=0;i<32;i=i+1)begin
        #T
        i_pc_mem_addr = i;//{i,{2{1'b0}}};
        i_pc_mem_r_en = 1'b1;
        #T
        to_send = o_pc_p_mem_data;
        i_pc_mem_r_en = 1'b0; 
        
        for(j=0;j<4;j=j+1) begin
            while(~o_pc_tx_ready) begin
                #T
                halt_flag = 1'b0;
            end
             // si es un halt
            if(to_send[30]) i = 32;
            
            i_pc_tx_data = to_send[7:0];
            i_pc_tx_valid = 1'b1;
            #(2*T)
            to_send = {{8{1'b0}},to_send[31:8]};
            i_pc_tx_valid = 1'b0;
            
        end        
        
        //if(halt_flag) i = 32;
    end

//    // STEP    
//    // cambiar a modo step
//    while(~o_pc_tx_ready) begin
//        #T
//        halt_flag = 1'b0;
//    end
//    i_pc_tx_data = "s";
//    i_pc_tx_valid = 1'b1;
//    #T
//    i_pc_tx_valid = 1'b0;    
    
//    // darle step
//    while(~o_pc_tx_ready) begin
//        #T
//        halt_flag = 1'b0;
//    end
//    i_pc_tx_data = "\n";
//    i_pc_tx_valid = 1'b1;
//    #T
//    i_pc_tx_valid = 1'b0;  
//    // ver cómo se mandaron las cosas :)
    
    // CONTINUE
    // cambiar a modo continue
    while(~o_pc_tx_ready) begin
        #T
        halt_flag = 1'b0;
    end
    i_pc_tx_data = "c";
    i_pc_tx_valid = 1'b1;
    #T
    i_pc_tx_valid = 1'b0;    
    
    //Esperar y dar halt
     while(~o_pc_tx_ready) begin
        #T
        halt_flag = 1'b0;
    end
    #(10*T)
    i_if_halt = 1'b1;
    
    // ver cómo se mandaron las cosas :)
    
    
end


endmodule
