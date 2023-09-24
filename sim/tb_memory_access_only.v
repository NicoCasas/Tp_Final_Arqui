`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2023 00:35:23
// Design Name: 
// Module Name: tb_memory_access_only
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


module tb_memory_access_only();
    parameter T = 41.67 * 2;

    parameter NB_DATA = 32;
    parameter N_ADDRESS = 64;
    parameter NB_ADDR_REGISTERS = 5;
    parameter N_ADDR_BUS  = 64;
    parameter NB_ADDR_MEM = $clog2(N_ADDR_BUS);
    parameter NB_CONTROL_MA     =  5;
    parameter NB_CONTROL_WB     =  2;
    parameter NB_CONTROL_BUS    =  NB_CONTROL_MA  + NB_CONTROL_WB;  
    
   
    wire    [NB_DATA-1:0]           o_control_wb    ;
    
    wire    [NB_DATA-1:0]           o_mem_r_data    ;
    wire    [NB_DATA-1:0]           o_reg_data      ;
    wire    [NB_DATA-1:0]           o_reg_num       ;
    
    wire    [NB_DATA-1:0]           o_id_rd_num     ;
    wire    [NB_DATA-1:0]           o_id_ctl_rw     ;
                                                                //agregar rd_num
    reg    [NB_DATA-1:0]           mem_data      ;
    reg    [NB_DATA-1:0]           mem_addr      ;
    
    reg    [NB_CONTROL_BUS-1:0]    control_ma_wb ;
    
    reg                            rd_num        ;
    reg                            clk  =0       ;
    reg                            reset=1       ;


    //module instantiation
    memory_access #()
    uut_memory_access
    (   
        //OUTPUTS 
        //-> 4 salidas registradas:    ctl bus, r_data, reg_data, rd_num (van a wb)
        //-> 2 salidas no registradas: id_ctl_rw , id_rd_num. (van a id, especificamente a la unidad de cortocircuito)
        .o_control_wb(o_control_wb)    ,
        
        .o_mem_r_data(o_mem_r_data)    ,
        .o_reg_data(o_reg_data)        ,
        .o_reg_num(o_reg_num)          ,
        
        .o_id_rd_num(o_id_rd_num)     ,
        .o_id_ctl_rw(o_id_ctl_rw)     ,
                                                                    //agregar rd_num
        .i_mem_data(mem_data)      ,
        .i_mem_addr(mem_addr)      ,
        
        .i_control_ma_wb(control_ma_wb) ,
        
        .i_rd_num(rd_num)        ,
        .i_clk(clk)           ,
        .i_reset(reset)     
    );
    
    // clk
    always begin
        #41.67
        clk = ~clk;
    end

    // simulation
    initial begin
        
        
    
        #(5*T)
        $finish;
    end

endmodule
