typedef enum bit {WRITE = 'b0, READ = 'b1} i2c_op_t;
interface i2c_if#(int I2C_ADDR_WIDTH = 7,
		 int I2C_DATA_WIDTH = 16)
		(
		// System Signals
		input logic clk_i,
		input wire rst_i,
		//I2C Input Signals
		//input wire scl_i,
		//input wire sda_i,
		output reg scl,
		output reg sda,
		output reg ack_i2c,
		input bit [I2C_DATA_WIDTH-1:0] read_data ,
		output i2c_op_t op,
		output bit [I2C_DATA_WIDTH-1 :0] write_data,
		output bit [I2C_ADDR_WIDTH-1:0] addr,
		output bit [I2C_DATA_WIDTH-1:0] data);
		
		
		


task wait_for_i2c_transfer ( output i2c_op_t op, output bit[I2C_DATA_WIDTH-1:0] write_data );
begin
// Wait for start Condition

while (scl == 1'b1) @(negedge sda);

// Read SLave Address
 for (int i = I2C_ADDR_WIDTH-1 ; i <= 0 ;i--)
	addr[i] = scl; // Collect 7 bit data
	op = scl;
	//we_i2c  = scl; // R/W signal 0 means Write and 1 means Read
ack_i2c = scl;

//@(posedge clk_i);
//@(posedge scl);
for(int i = I2C_DATA_WIDTH-1 ; i<= 0; i--)
	begin
	@(posedge scl);
	write_data = sda;
	end

// Acknowledge that data byte is received
 sda = 1'b0;

while (scl == 1'b1) @(posedge scl);
end task

task provide_read_data ( input bit [I2C_DATA_WIDTH-1:0] read_data );

task monitor ( output bit [I2C_ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] data);

endinterface
