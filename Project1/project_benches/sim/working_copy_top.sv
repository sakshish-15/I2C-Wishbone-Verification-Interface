`timescale 1ns / 10ps

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_SLAVES = 1;

bit  clk = 1'b0;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_SLAVES-1:0] scl;
tri  [NUM_I2C_SLAVES-1:0] sda;

reg [WB_DATA_WIDTH-1:0] local_rd_data;
reg [WB_DATA_WIDTH-1:0] monitor_data;
reg [WB_ADDR_WIDTH-1:0] monitor_adr;
reg monitor_we;


//always #10 clk = ~clk;
// ****************************************************************************
// Clock generator
always begin:clk_gen
 #5 clk = ~clk;
end:clk_gen
// ****************************************************************************
// Reset generator
initial
rst_gen:begin
#113 rst = 0;
end

// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript
initial
begin: wb_monitoring
wb_bus.master_monitor(monitor_adr,monitor_data,monitor_we);
$monitor($time, " Data Read from Wishbone %x at Address %d with Write ENable %b", monitor_data,monitor_adr,monitor_we);
// Display to print observed transfers in Transcript
end:wb_monitoring

// ****************************************************************************
// Define the flow of the simulation
initial
begin: test_flow

//CSR 0x00 R/W 
//DPR 0x01 R/W 
//CMDR 0x02 R/W
//FSMR 0x03
#1100

//0.Writebyte“1xxxxxxx”totheCSRregister.
wb_bus.master_write(8'h00, 8'b11xxxxxx);

//1. Write byte 0x05 totheDPR.ThisistheIDofdesiredI2Cbus
wb_bus.master_write(8'h01, 8'h05);


//2. Writebyte“xxxxx110”totheCMDR.ThisisSetBuscommand.
wb_bus.master_write(8'h02, 8'bxxxxx110);


//3. WaitforinterruptoruntilDONbitofCMDRreads'1'
//wait((irq == 1'b1) || (local_rd_data[7] == 1'b1));
wait (irq) @(posedge clk);
wb_bus.master_read(8'h02,local_rd_data);




//4.Writebyte“xxxxx100”totheCMDR.ThisisStartcommand.
wb_bus.master_write(8'h02, 8'bxxxxx100);

//5.WaitforinterruptoruntilDONbitofCMDRreads'1'.
//wait((irq == 1'b1) || (local_rd_data[7] == 1'b1));
wait (irq) @(posedge clk);
wb_bus.master_read(8'h02,local_rd_data);


//6.Writebyte0x44totheDPR.Thisistheslaveaddress0x22shifted1bittotheleft+ rightmost bit = '0', which means writing.
wb_bus.master_write(8'h01, 8'h44);

//7.Writebyte“xxxxx001”totheCMDR.ThisisWritecommand.
wb_bus.master_write(8'h02, 8'bxxxxx001);

//8. Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
//is '1', then slave doesn't respond.
//wait((irq) ||  (local_rd_data[7] == 1'b1));
wait (irq) @(posedge clk);
wb_bus.master_read(8'h02,local_rd_data);


//9. Writebyte0x78totheDPR.Thisisthebytetobewritten.
wb_bus.master_write(8'h01, 8'h78);

//10. Write byte “xxxxx001” to the CMDR. This is Write command.
wb_bus.master_write(8'h02, 8'bxxxxx001);


//11. Wait for interrupt or until DON bit of CMDR reads '1'.
//wait((irq) || (local_rd_data[7] == 1'b1));
wait (irq) @(posedge clk);
wb_bus.master_read(8'h02,local_rd_data);



//12. Write byte “xxxxx101” to the CMDR. This is Stop command.
wb_bus.master_write(8'h02, 8'bxxxxx101);

//13. Wait for interrupt or until DON bit of CMDR reads '1'.
//wait((irq) || (local_rd_data[7] == 1'b1));
wait(irq) @(posedge clk);
wb_bus.master_read(8'h02,local_rd_data);

#100 $finish();
end:test_flow


// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_SLAVES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );


endmodule
