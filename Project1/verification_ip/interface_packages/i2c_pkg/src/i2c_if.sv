//typedef enum logic {WRITE = 1'b0, READ = 1'b1} i2c_op_t;
interface i2c_if#(int I2C_ADDR_WIDTH = 7,
		 int I2C_DATA_WIDTH = 8,
		 int I2C_SLAVE = 1)
		(
		inout  [I2C_SLAVE -1 :0] scl_i2c,
		inout triand [I2C_SLAVE -1 :0] sda_i2c);
		
		// System Signals 
	//	input logic clk_i2c,
	//	input wire rst_i2c,
		//I2C Input Signals
		//input wire scl_i,
		//input wire sda_i,
	//	output reg scl_i2c,
	//	output reg sda_i2c,
typedef enum logic {WRITE = 1'b0, READ = 1'b1} i2c_op_t;
		 reg ack_i2c;
		bit [I2C_DATA_WIDTH-1:0] read_data;
		 i2c_op_t op;
		reg [I2C_DATA_WIDTH-1 :0] write_data;
		 bit [I2C_ADDR_WIDTH-1:0] addr;
		bit [I2C_DATA_WIDTH-1:0] data;
		bit [I2C_DATA_WIDTH-1:0] dat;
reg start_flag, stop_flag;;
reg ack_flag, read_flag;;
//triand scl_i2c, sda_i2c;
assign sda_i2c = (!ack_flag) ? 1'bZ: 1'b0;

initial
begin
start_flag = 1'b0; stop_flag = 1'b0;		
ack_flag = 1'b0;
read_flag = 1'b0;
end
		
		
task start_condition();

//while (scl_i2c == 1'b1)
 @(negedge sda_i2c);
if(scl_i2c == 1'b1)
begin
start_flag = 1'b1;
stop_flag = 1'b0;
$display($time, " ######## START CONDITION ##############");
end
endtask

task read_slave_addr ();
begin
if(start_flag == 1'b1)
begin
//integer i;
 for (int i = 6 ; i >= 0 ; i--)
	begin
//$display ("For loop");
	//$display ("SDA Line is %b",sda_i2c);
	@(posedge scl_i2c );
	addr[i] = sda_i2c; // Collect 7 bit data
	end
@(posedge scl_i2c);
op = i2c_op_t'(sda_i2c);
//$display ("Read/Write is %b", op);
$display ($time, " SLAVE ADDRESS READ %x",addr);
$display ("Read/Write is %b", op);
end
end
endtask

task send_ack ();
//@(posedge scl_i2c);
//if(scl_i2c == 1'b1)
//ack_flag = 1'b1;
$display ("Ack\n");
$display ($time, " SDA Value for Ack %d",sda_i2c);
//if(ack_flag == 1'b1)
@(negedge scl_i2c);
ack_flag = 1'b1;
//ack_flag <= 1'b0;
//read_flag = 1'b1;
$display ($time, " SDA Value for Ack %d",sda_i2c);
endtask

task read_data_byte();
//(output reg [I2C_DATA_WIDTH -1 :0] write_data);
begin
$display ("Write data sda is %b",sda_i2c);
$display ("DATA READ FUNCT In I2C");
//forever 
//begin
if(op == WRITE)
//forever 
begin
@(posedge scl_i2c);
	if((start_flag == 1'b1) && (stop_flag == 1'b0))
	begin
	//data = {data,sda_i2c};
	for (int i = I2C_DATA_WIDTH-1 ; i >= 0 ; i--)
	begin
	@(posedge scl_i2c);
	$display ("Read Data is %b", sda_i2c);
	//data = {data,sda_i2c};
	write_data[i] = sda_i2c;
	end
	//write_data = {write_data,data};
$display ($time, " Data Read is %x",write_data);

	end
end
end
//end
endtask

task stop_condition();
$display ("Stop called");
//@(posedge sda_i2c);
@(posedge scl_i2c);
if(start_flag == 1'b1)
begin
	if (scl_i2c == 1'b1)
	begin
	@(posedge sda_i2c);
	stop_flag = 1'b1;
	$display ("############# STOP CONDITION ###############");
	end
start_flag = 1'b0;
end
endtask

task wait_for_i2c_transfer ( output i2c_op_t op, output bit[I2C_DATA_WIDTH-1:0] write_data );
begin
//read_data_byte();

if(op == WRITE)
read_data_byte();
end
//else if(op == READ)
//provide_read_data();


// Wait for start Condition
//while (scl_i2c == 1'b1) @(negedge sda_i2c);


// Read SLave Address
 /*for (int i = I2C_ADDR_WIDTH-1 ; i <= 0 ;i--)
	addr[i] = scl_i2c; // Collect 7 bit data
	op = i2c_op_t'(scl_i2c);
	//we_i2c  = scl; // R/W signal 0 means Write and 1 means Read
ack_i2c = scl_i2c;

//@(posedge clk_i);
//@(posedge scl);
for(int i = I2C_DATA_WIDTH-1 ; i<= 0; i--)
	begin
	@(posedge scl_i2c);
	write_data = sda_i2c;
	end

// Acknowledge that data byte is received
 //sda_i2c = 1'b0;

while (scl_i2c == 1'b1) @(posedge scl_i2c);*/
endtask

task provide_read_data ( input bit [I2C_DATA_WIDTH-1:0] read_data );
endtask
task monitor ( output bit [I2C_ADDR_WIDTH-1:0] addr, output bit [I2C_DATA_WIDTH-1:0] data);
begin
 //i2c_bus.start_condition();
//while (start_flag == 1'b1)
//begin
start_condition();

$display ("####Start flag is %d", start_flag);
 read_slave_addr();
 send_ack();
//end

 //i2c_bus.read_data_byte(dat_wr_o_i2c);
//for (int i =0 ; i < 20 ; i++)
//begin
//while (stop_flag == 1'b0)
//begin
/*if(op == WRITE)
begin
//forever
//begin
@(negedge scl_i2c);
@(posedge scl_i2c);
@(sda_i2c or negedge scl_i2c);

if(!scl_i2c)
begin
$display ("For Loop");
dat = {dat,sda_i2c};
for (int i = I2C_DATA_WIDTH-1 ; i >=0 ; i++)
	begin
	@(posedge scl_i2c);
	dat = {dat,sda_i2c};
	$display ("Write data");
	end
	write_data = {write_data,dat};
$display ($time, " Data Read is %x",write_data);

	@(negedge scl_i2c);
	end
*/
  // i2c_bus.
read_data_byte();
 //i2c_bus.
send_ack();
//end
//$display ("DATA READ FUNCT In I2C");
// i2c_bus.send_ack(); end
//i2c_bus.
stop_condition();
//end
//end
//end
end
endtask
//initial forever i2c_bus.start_condition();
//initial forever i2c_bus.stop_condition();
endinterface
