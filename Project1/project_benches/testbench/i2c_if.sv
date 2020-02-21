interface wb_if #(ADDR_WIDTH,DATA_WIDTH) (input logic clk_i, input rst_i);
//,inout cyc_o, inout stb_o, inour ack_i, inout adr_o, inout we_o);
begin
logic cyc_o, stb_o, ack_i, we_o;
logic [ADDR_WIDTH-1:0] adr_o, adr_i;
logic cyc_i;
logic stb_i, ack_o, adr_i, we_i;
logic [DATA_WIDTH-1 :0] dat_o, dat_i;

task master_monitor(adr_i,dat_i, we_i);
begin

endtask



endinterface
