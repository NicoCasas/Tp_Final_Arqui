`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_write_back();

parameter NB_DATA = 16;
parameter NB_CONTROL_WB = 2;
parameter NB_REGISTERS = 5;
parameter T = 2*41.67;


// internal wires
wire [NB_DATA-1:0]      result;
wire [NB_REGISTERS-1:0] o_reg_num;
wire                    o_ctl_rw;

// regs
reg clk = 0;
reg reset = 0;

reg         ctl_m2r;    
reg         ctl_rw;

reg [NB_DATA-1:0] reg_data;
reg [NB_DATA-1:0] mem_data;         
reg [NB_REGISTERS-1:0] reg_num;

wire [NB_CONTROL_WB-1:0] control_wb;

assign control_wb = {ctl_m2r,ctl_rw};

// module instantiation
write_back
#(.NB_DATA(NB_DATA))
uut_write_back
(
    .o_reg_w_data (result)    ,
    .o_reg_num    (o_reg_num) ,
    .o_reg_write  (o_ctl_rw)  ,
    
    .i_reg_data   (reg_data)  ,
    .i_mem_data   (mem_data)  ,
    
    .i_reg_num    (reg_num)   ,
    
    .i_control_wb (control_wb)
    
//    input   wire    i_clk   ,
//    input   wire    i_reset
);

always begin
    #41.67
    clk = ~clk;
end

initial begin
    #(T+41.67)
    reg_data = 16'b01;
    mem_data = 16'b10;
    reg_num  = 5'b100;
    ctl_rw = 1'b0;
    ctl_m2r= 1'b0;

    #T
    ctl_rw  = 1'b1;
    #T
    ctl_m2r = 1'b1;
    #T
    ctl_rw  = 1'b0;
    #T
    ctl_m2r = 1'b0;    
    
    #(5*T)
    $finish;
    
    
    

end


endmodule
