`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2023 17:05:54
// 
//////////////////////////////////////////////////////////////////////////////////


module debug_unit
#(
    parameter NB_DATA = 32, 
    parameter NB_ADDRESS = 32,
    
    parameter N_ADDR_P_MEM  = 128,
    parameter NB_ADDR_P_MEM = $clog2(N_ADDR_P_MEM),
    parameter N_ADDR_D_MEM  = 32,
    parameter NB_ADDR_D_MEM = $clog2(N_ADDR_D_MEM),
    
    parameter N_REGISTERS = 32,
    parameter NB_ADDR_REGISTERS = $clog2(N_REGISTERS),

    parameter NB_STATES = 7,
    parameter NB_SD_STATES = 4,

    parameter NB_COUNT = 3,

    parameter STEP_MODE_KEY     = "s",
    parameter CONTINUE_MODE_KEY = "c",
    parameter STEP_KEY          = "s",
    parameter RESTART_KEY       = "r",
    
    parameter NB_RX_DATA        = 8 ,
    parameter NB_TX_DATA        = 8
    
)
(
    output  wire [NB_ADDRESS       -1:0]     o_p_mem_addr,
    output  wire [NB_DATA          -1:0]     o_p_mem_data,
    output  wire                             o_p_mem_w_en,
    
    output  wire [NB_ADDR_REGISTERS-1:0]     o_register_addr,
    output  wire [NB_ADDRESS-1:0]            o_d_mem_addr,
    
    output  wire                            o_clk_en,
    output  wire                            o_debug_flag,
    
    output  wire                            o_tx,
    
    input   wire [NB_DATA-1:0]               i_register_data,
    //input   [NB_P_MEM_ADDR    -1:0]     i_program_memory_data,
    input   wire [NB_DATA          -1:0]     i_d_mem_data,
    
    input   wire [NB_ADDRESS-1:0]            i_if_pc,
    input   wire                             i_if_halt,
    
    input   wire                             i_rx,
    
    input   wire     i_clk,
    input   wire     i_reset
);

localparam initial_STATE            = 7'b0000001; // Llevar el numero de bits con el param NB_STATES
localparam upload_program_STATE     = 7'b0000010;
localparam select_mode_STATE        = 7'b0000100;
localparam step_execution_STATE     = 7'b0001000;
localparam continue_execution_STATE = 7'b0010000;
localparam sending_data_STATE       = 7'b0100000;
localparam idle_STATE               = 7'b1000000;

localparam idle_MODE     = 2'b00;
localparam step_MODE     = 2'b01;
localparam continue_MODE = 2'b10;

// states regs 
reg     [NB_STATES-1:0]     state;
reg     [NB_STATES-1:0]     nxt_state;

// other regs
reg   [1:0]                  mode;
reg   [1:0]                  nxt_mode;

reg                     debug_flag;
reg                     nxt_debug_flag;

reg                     clk_en;
reg                     nxt_clk_en;

reg   [NB_COUNT-1:0]    count;
reg   [NB_COUNT-1:0]    nxt_count;

// Variables referidas a la memoria de programa
reg   [NB_DATA-1:0]     p_mem_data;
reg   [NB_DATA-1:0]     nxt_p_mem_data; 

reg   [NB_ADDR_P_MEM:0] p_mem_addr_iter;        // No -1 porque necesito que sea más grande
reg   [NB_ADDR_P_MEM:0] nxt_p_mem_addr_iter;  


reg   [NB_ADDRESS -1:0] p_mem_addr;

reg                 p_mem_w_en;
reg                 nxt_p_mem_w_en;

//////// SENDING DATA
localparam send_pc_SD_STATE        = 4'b0001;
localparam send_registers_SD_STATE = 4'b0010;
localparam send_mem_SD_STATE       = 4'b0100;
localparam finish_SD_STATE         = 4'b1000;

reg [NB_SD_STATES-1:0] sd_state;
reg [NB_SD_STATES-1:0] nxt_sd_state;


// Variables referidas a los registros
reg [NB_ADDR_REGISTERS-1:0] r_addr_iter;
reg [NB_ADDR_REGISTERS-1:0] nxt_r_addr_iter;
//reg [NB_ADDR_REGISTERS-1:0] sr2_addr;

// Variables referidas a la memoria de datos
reg [NB_ADDR_D_MEM-1:0] d_mem_addr_iter;
reg [NB_ADDR_D_MEM-1:0] nxt_d_mem_addr_iter;
reg [NB_ADDR_D_MEM-1:0] d_mem_addr;

//baudrate
wire                   bd_tick;

//rx
wire                  rx_valid  ;
wire [NB_RX_DATA-1:0] rx_o_data ;
 

//tx
wire                    tx_o_data;                         // LO QUE SALE DE LA FPGA 

wire                    tx_ready;

reg                     tx_valid;
//reg                     nxt_tx_valid;

reg   [NB_DATA-1:0]     tx_data;
//reg   [NB_DATA-1:0]     nxt_tx_data;


// module instantiation
transmisor_32
#()
tx
(
    .o_ready(tx_ready),
    .o_data (tx_o_data),
    
    .i_data (tx_data),
    .i_valid(tx_valid),
    .i_tick (bd_tick),
    
    .i_clk  (i_clk),
    .i_reset(i_reset)

);

baudrate_gen#()
bd_gen
   (
    //OUTPUTS
    .o_tick  (bd_tick)      ,
    //INPUT
    .i_clk   (i_clk)        ,
    .i_reset (i_reset)    
   );

receptor#()
rx
 (
    //OUTPUTS
    .o_data     (rx_o_data)                            ,
    .o_valid    (rx_valid)                            ,
    //INPUTS
    .i_clk      (i_clk)                               ,
    .i_reset    (i_reset)                         ,
    .i_tick     (bd_tick)                         ,
    .i_rx       (i_rx)
  );



// state 
always @(posedge i_clk) begin
    if(i_reset) begin
        state <= initial_STATE;
    end
    else begin
        state   <= nxt_state;
    end
end
    
// register other variables
always @(posedge i_clk) begin
    if(i_reset) begin
        //debug_flag      <= 1'b0;
        clk_en          <= 1'b0;
        p_mem_data      <= {NB_DATA{1'b0}};
        //p_mem_addr_iter <= {NB_ADDR_P_MEM{1'b0}};
        p_mem_addr      <= {NB_DATA{1'b0}};
        p_mem_w_en      <= 1'b0;
    end
    else begin
        //debug_flag      <= nxt_debug_flag;
        clk_en          <= nxt_clk_en;
        count           <= nxt_count;
        p_mem_data      <= nxt_p_mem_data;
        p_mem_addr_iter <= nxt_p_mem_addr_iter;
        p_mem_addr      <= {{(NB_DATA-NB_ADDR_P_MEM-1){1'b0}},p_mem_addr_iter}; 
        p_mem_w_en      <= nxt_p_mem_w_en;
        mode            <= nxt_mode;
    end
end

always @(posedge i_clk) begin
    sd_state        <= nxt_sd_state;
    r_addr_iter     <= nxt_r_addr_iter;
    d_mem_addr_iter <= nxt_d_mem_addr_iter;
    //tx_data         <= nxt_tx_data;
    //tx_valid        <= nxt_tx_valid;
end


reg [2:0] send_data_state;
reg [2:0] nxt_send_data_state;
    
// NEXT STATE LOGIC    
always @(*) begin
    //common
    nxt_count = count;
    nxt_state = state;
    nxt_clk_en = clk_en;
    
    //program memory 
    nxt_p_mem_data  = p_mem_data;
    nxt_p_mem_addr_iter = p_mem_addr_iter;
    nxt_p_mem_w_en = 1'b0;
    
    nxt_mode = mode;
    debug_flag = 1'b0;
    
    //sending
    nxt_sd_state = sd_state;
    nxt_r_addr_iter = r_addr_iter;
    nxt_d_mem_addr_iter = d_mem_addr_iter;
    
    tx_data = {NB_DATA{1'bx}};
    tx_valid = 1'b0;
    
    
    case(state)
        
        initial_STATE: 
        begin
            nxt_count = {NB_COUNT{1'b0}};
            nxt_p_mem_addr_iter = {NB_ADDR_P_MEM{1'b0}};    
            nxt_state = upload_program_STATE;
        end
        
        // UPLOAD_PROGRAM
        upload_program_STATE: 
        begin
            debug_flag = 1'b1;
            if(rx_valid) begin
                nxt_p_mem_data = {p_mem_data[23:0],rx_o_data};            // if lsb. puede que vaya este
                //nxt_p_mem_data = {rx_o_data,p_mem_data[31:8]};              // if msb
                nxt_count = count + {{NB_COUNT-1{1'b0}},1'b1};
                
                if(count=={{NB_COUNT-2{1'b0}},{2'b11}}) begin
                    // Escribir
                    if(p_mem_addr_iter!=N_ADDR_P_MEM) begin
                        nxt_p_mem_w_en = 1'b1;
                        nxt_p_mem_addr_iter = p_mem_addr_iter + {{NB_ADDR_P_MEM{1'b0}},1'b1};
                    end
                    
                    // Reiniciamos contador
                    nxt_count = {NB_COUNT{1'b0}};
                    
                    // Si es halt, cambiamos de estado
                    if(nxt_p_mem_data[NB_DATA-2] == 1'b1)   nxt_state = select_mode_STATE;    
                
                end            
            end
            
        end
        
        // SELECT MODE
        select_mode_STATE: 
        begin
            debug_flag = 1'b1;
            if(rx_valid) begin
                
                if(rx_o_data==STEP_MODE_KEY) 
                begin
                    nxt_state = step_execution_STATE;
                    nxt_mode = step_MODE;
                end
                
                if(rx_o_data==CONTINUE_MODE_KEY)  
                begin 
                    nxt_state = continue_execution_STATE;
                    nxt_mode = continue_MODE;
                    nxt_clk_en = 1'b1;
                end
            
            end
        
        end
        
        // STEP EXECUTION
        step_execution_STATE: 
        begin
            if(rx_o_data==STEP_KEY) nxt_clk_en = 1'b1;
            
            if(clk_en==1'b1) begin
                nxt_clk_en = 1'b0;
                // send variables       VER SI RESETEAR EL CONTADOR HACE FALTA
                //nxt_count = 1'b0;
                nxt_state = sending_data_STATE;
                    
            end
                   
        end
    
        // CONTINUE EXECUTION
        continue_execution_STATE: 
        begin
            if(i_if_halt) begin  
                // 4 ciclos para dejar las instrucciones terminar
                nxt_count = count + {{NB_COUNT-1{1'b0}},1'b1};
                
                if(count == {3'b100}) begin
                    // parar pipeline y enviar 
                    nxt_clk_en = 1'b0;
                    nxt_state = sending_data_STATE;
                end
            end
        end
    
        sending_data_STATE:
        begin
        debug_flag = 1'b1;
        case(sd_state)
           
            send_pc_SD_STATE:
            begin
                if(tx_ready) begin
                    tx_data  = i_if_pc;
                    tx_valid = 1'b1;
                    nxt_sd_state = send_registers_SD_STATE; 
                    nxt_r_addr_iter = {NB_ADDR_REGISTERS{1'b0}};
                end
            end
        
            send_registers_SD_STATE: 
            begin
                if(tx_ready) begin    
                        nxt_r_addr_iter = r_addr_iter + {{NB_ADDR_REGISTERS-1{1'b0}},1'b1};
                        
                        //sr2_addr = r_addr_iter;
                        tx_data  = i_register_data;
                        tx_valid = 1'b1;
                    
                    if (r_addr_iter == N_REGISTERS-1) begin
                        nxt_d_mem_addr_iter = {NB_ADDR_D_MEM{1'b0}};
                        nxt_sd_state = send_mem_SD_STATE;
                        
                    end
                end    
             end
             
            send_mem_SD_STATE: 
            begin
                if(tx_ready) begin    
                        nxt_d_mem_addr_iter = d_mem_addr_iter + {{NB_ADDR_D_MEM-1{1'b0}},1'b1};
                        tx_data  = i_d_mem_data;
                        //d_mem_addr = d_mem_addr_iter;
                        tx_valid = 1'b1;
                        
                    if (d_mem_addr_iter == N_ADDR_D_MEM-1) begin
                        nxt_sd_state = finish_SD_STATE;    
                    end
                    
                    
                end    
             end
             
            finish_SD_STATE:
            begin
                if(tx_ready) begin
                    nxt_sd_state = send_pc_SD_STATE;
                    if(mode == continue_MODE) nxt_state = idle_STATE;
                    if(mode == step_MODE)     nxt_state = step_execution_STATE;
                end
            end
         
            default: nxt_sd_state = send_pc_SD_STATE;
         
        endcase    
        end
    
        // IDLE STATE
        idle_STATE:
        begin
            if(rx_valid) begin
                if(rx_o_data == RESTART_KEY) begin
                    nxt_state = initial_STATE;
                end
            end
        end
    
        // DEFAULT
        default:    nxt_state = initial_STATE;
            
    endcase
    
    
end

//output assign
assign o_debug_flag = debug_flag;    

assign o_p_mem_addr = p_mem_addr;
assign o_p_mem_data = p_mem_data;
assign o_p_mem_w_en = p_mem_w_en;

assign o_register_addr = r_addr_iter;  // Ver de cambiar estar variables por el iterador

assign o_d_mem_addr = {{NB_ADDRESS-NB_ADDR_D_MEM{1'b0}},d_mem_addr_iter};

assign o_clk_en = clk_en;

assign o_tx = tx_o_data;
    
endmodule
