`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_pipeline();

parameter NB_DATA = 32;
parameter T = 10;//4*41.67;
parameter T_PIPELINE = 2*T;

reg clk = 1;
reg clk_reset = 1;
reg reset = 1;

wire [NB_DATA-1:0]  o_data_reg;
wire                o_clk;
wire                o_locked;

pipeline #(
)
uut_pipeline
(
    .o_wb_reg_w_data(o_data_reg)            ,
    .o_clk(o_clk)                           ,
    .o_locked(o_locked)                     ,
    
    .i_clk(clk)                             ,
    //.i_reset(reset)                         ,
    .i_clk_reset(clk_reset)             
);


// Clock
always begin
    #(T/2)
    clk = ~clk;
end

initial begin
    #(3*T_PIPELINE)
    clk_reset = 0;
    //#(10*T_PIPELINE)
    //reset = 0;
    #(120*T_PIPELINE)
    $finish; 
end

endmodule
