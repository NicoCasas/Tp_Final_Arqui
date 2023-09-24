`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
// 
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module memory_access
#(
    parameter NB_DATA     = 32,
    parameter NB_DATA_BUS = 32,
    parameter NB_ADDR_REGISTERS = 5,
    parameter N_DATA_MEM_ADDR  = 64,
    parameter NB_ADDR_MEM = $clog2(N_DATA_MEM_ADDR),
    parameter NB_CONTROL_MA     =  5,
    parameter NB_CONTROL_WB     =  2,
    parameter NB_CONTROL_MA_WB    =  NB_CONTROL_MA  + NB_CONTROL_WB  
)
(   
    //OUTPUTS 
    //-> 4 salidas registradas:    ctl bus, r_data, reg_data, rd_num (van a wb)
    //-> 3 salidas no registradas: ex_ctl_rw , ex_rd_num y ex_rd_data. (van a ex, especificamente a la unidad de cortocircuito)
    output  wire    [NB_CONTROL_WB-1:0]     o_control_wb        ,
    
    output  wire    [NB_DATA-1:0]           o_mem_r_data        ,
    output  wire    [NB_DATA-1:0]           o_reg_data          ,
    output  wire    [NB_ADDR_REGISTERS-1:0] o_reg_num           ,
    
    
    output  wire    [NB_ADDR_REGISTERS-1:0] o_ex_rd_num         ,
    output  wire                            o_ex_ctl_reg_write  ,
    output  wire    [NB_DATA-1:0]           o_ex_rd_data        ,
                                                                //agregar rd_num
    input   wire    [NB_DATA-1:0]           i_mem_data          ,
    input   wire    [NB_DATA-1:0]           i_mem_addr          ,
    
    input   wire    [NB_CONTROL_MA_WB-1:0]  i_control_ma_wb     ,
    
    input   wire    [NB_ADDR_REGISTERS-1:0] i_rd_num            ,
    input   wire                            i_clk               ,
    input   wire                            i_reset     
);

// INTERNAL SIGNALS AND REGS
wire        ctl_mem_read;
wire        ctl_mem_write;
wire        ctl_signing;
wire  [1:0] ctl_addressing;

wire    [NB_DATA-1:0]   mem_r_data          ;

reg     [NB_DATA-1:0]           reg_o_mem_r_data   ;
reg     [NB_DATA-1:0]           reg_o_reg_data     ;
reg     [NB_ADDR_REGISTERS-1:0] reg_o_reg_num      ;
reg     [NB_CONTROL_WB -1:0]    reg_o_control_wb   ;



// Asigno las señales de control usando el ctl bus
assign ctl_mem_read   = i_control_ma_wb[NB_CONTROL_MA_WB-1];
assign ctl_mem_write  = i_control_ma_wb[NB_CONTROL_MA_WB-2];
assign ctl_addressing = i_control_ma_wb[NB_CONTROL_MA_WB-3-:2];
assign ctl_signing    = i_control_ma_wb[NB_CONTROL_MA_WB-5];

// Mem instantiation                            //FALTA SIGNING - Ya ta
full_memory#()
data_memory
(
    .o_r_data           (mem_r_data)                    ,
    
    .i_r_addr           (i_mem_addr[NB_ADDR_MEM-1:0])   ,
    .i_r_addressing     (ctl_addressing)                ,
    .i_r_signing        (ctl_signing)                   ,
    .i_r_en             (ctl_mem_read)                  ,
    
    .i_w_data           (i_mem_data)                    ,
    .i_w_addr           (i_mem_addr[NB_ADDR_MEM-1:0])   ,
    .i_w_addressing     (ctl_addressing)                ,
    .i_w_en             (ctl_mem_write)                 ,
    
    .i_clk              (i_clk)
);




// output register
always @(posedge i_clk) begin
    if(i_reset) begin
        //reg_o_mem_r_data   <= {NB_DATA{1'b0}};
        //reg_o_reg_data     <= {NB_DATA{1'b0}};
        //reg_o_reg_num      <= {NB_ADDR_REGISTERS{1'b0}};
        reg_o_control_wb   <= {NB_CONTROL_WB{1'b0}};
    end
    else begin
        reg_o_mem_r_data   <= mem_r_data;
        reg_o_reg_data     <= i_mem_addr;
        reg_o_reg_num      <= i_rd_num  ;
        reg_o_control_wb   <= i_control_ma_wb[NB_CONTROL_WB-1:0];
    end
end

// output assign
assign o_mem_r_data = reg_o_mem_r_data;
assign o_reg_data   = reg_o_reg_data;
assign o_reg_num    = reg_o_reg_num;
assign o_control_wb = reg_o_control_wb;

assign o_ex_rd_num  = i_rd_num;
assign o_ex_rd_data = i_mem_addr;
assign o_ex_ctl_reg_write = i_control_ma_wb[0];    // Esto ver en id


endmodule
