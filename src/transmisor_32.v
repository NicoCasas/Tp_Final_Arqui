`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module transmisor_32
#(
    parameter NB_DATA = 32,
    parameter NB_COUNT = 3,
    parameter NB_TX_DATA = 8,
    parameter NB_STATES = 3
)
(
    output  wire                    o_ready,
    output  wire                    o_data ,
    
    input   wire   [NB_DATA-1:0]    i_data,
    input   wire                    i_valid,
    input   wire                    i_tick,
    
    input   wire       i_clk,
    input   wire       i_reset

);

localparam secure_STATE  = 3'b001;
localparam idle_STATE    = 3'b010;
localparam sending_STATE = 3'b100;

// INTERNAL REGS AND WIRES
reg [NB_STATES-1:0] state;
reg [NB_STATES-1:0] nxt_state;

reg [NB_COUNT-1:0]    count;
reg [NB_COUNT-1:0]    nxt_count;

reg [NB_DATA-1:0]   data;
reg [NB_DATA-1:0]   nxt_data;

reg                 tx_valid;
reg                 nxt_tx_valid;

reg [NB_TX_DATA-1:0] tx_data;
reg [NB_TX_DATA-1:0] nxt_tx_data;

reg ready;
reg nxt_ready;

wire tx_ready;

// MODULE INSTANTIATION
transmisor
#(
 )
 uut_transmisor
 (
    //OUTPUTS
    .o_data         (o_data)                    ,
    .o_valid        (tx_ready)                  ,
    //INPUTS
    .i_clk          (i_clk)                     ,
    .i_reset        (i_reset)                   ,
    .i_tick         (i_tick)                    ,
    .i_valid        (tx_valid)                  ,
    .i_data         (tx_data)                       
  );

// MEMORY
always @(posedge i_clk) begin
    if(i_reset) begin
        state   <=  idle_STATE;
        data    <= {NB_DATA{1'b0}};
        tx_valid<= 1'b0;
        ready   <= 1'b1;
    end
    else begin
        state   <= nxt_state;
        data    <= nxt_data;
        count   <= nxt_count;
        tx_valid<= nxt_tx_valid;
        //tx_data <= data[NB_TX_DATA-1:0];
        tx_data <= nxt_tx_data;
        ready   <= nxt_ready;
    end
    
end

// STATES
always @(*) begin
nxt_state = state;
nxt_tx_valid = 1'b0;
nxt_data = data;
nxt_count = count;
nxt_ready = ready;
nxt_tx_data = tx_data;  // ver esto. Hay que no registrar el dato que se va a mandar por uart y sacar condicion de '& tx_valid'
    
    case (state)
    
        secure_STATE:
        begin
            nxt_ready = 1'b1;
            nxt_state = idle_STATE;
        end
        
        idle_STATE:
        begin
            if(i_valid) begin
                nxt_data = i_data;
                nxt_ready = 1'b0;
                nxt_count = {NB_COUNT{1'b0}};
                
                nxt_state = sending_STATE;
            end
        end
        
        sending_STATE:
        begin
            if(tx_ready & ~tx_valid) begin               
                if(count!={3'b100})  begin  
                    nxt_data = {{NB_TX_DATA{1'b0}},data[NB_DATA-1:NB_TX_DATA]};              
                    nxt_tx_data = data[NB_TX_DATA-1:0];
                    nxt_tx_valid = 1'b1;    
                    nxt_count = count + {{NB_COUNT-1{1'b0}},1'b1};
                end       
                else  begin
                    nxt_ready = 1'b1;
                    nxt_state = idle_STATE;
                end
                
             end
        end
        
        default: begin
            nxt_state = secure_STATE;
        end
    endcase
end

assign o_ready = ready;




endmodule
