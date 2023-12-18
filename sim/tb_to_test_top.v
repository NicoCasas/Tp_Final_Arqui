`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2023 17:42:56
// Module Name: tb_to_test_top
// 
// Dependencies: 
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_to_test_top();

parameter T = 10;

parameter INIT_FILE = "file_to_test_top.mem";
    
parameter NB_DATA = 32;
parameter NB_ADDRESS = 32;

parameter N_P_MEM_ADDR = 128;
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


reg  [NB_TX-1:0]   i_pc_tx_data=0;
reg                i_pc_tx_valid=0;

reg  [ NB_ADDRESS -1:0]    i_pc_mem_addr;
reg                        i_pc_mem_r_en=0;


reg            clk = 1'b1;
reg            reset = 1'b1;

integer i,j;

reg  [31:0] to_send;
reg         halt_flag = 1'b0;

to_test_top#(     
)
uut_to_test_top
(
    .o_pc_rx_o_data     (o_pc_rx_o_data),
    .o_pc_rx_valid      (o_pc_rx_valid),
    
    .o_pc_tx_ready      (o_pc_tx_ready),
    
    .o_pc_p_mem_data    (o_pc_p_mem_data),
    
    
    .i_pc_tx_data   (i_pc_tx_data),
    .i_pc_tx_valid  (i_pc_tx_valid),
    
    .i_pc_mem_addr  (i_pc_mem_addr),
    .i_pc_mem_r_en  (i_pc_mem_r_en),
    
    .i_clk      (clk),
    .i_reset    (reset)
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

    // pasar p_mem
    #(T)
    for(i=0;i<N_P_MEM_ADDR;i=i+1)begin
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
            if(to_send[30]) i = N_P_MEM_ADDR;
            
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
    
   
    
    // ver cómo se mandaron las cosas :)
    
    
end


endmodule
