module spi_slave(clk, mosi, miso, sck, ssel, transmit_data, receive_data, receive_ready);
  parameter DATA_LEN = 32;
  
  input clk, sck;
  input ssel; // active low
  input mosi;
  output miso;  // hi imp when ssel is high
  output [DATA_LEN - 1:0] receive_data;
  input [DATA_LEN - 1:0] transmit_data;
  output receive_ready;
  reg [DATA_LEN - 1:0] trx_buffer;

  reg [2:0] sck_sync, ssel_sync;
  reg [1:0] mosi_sync;
  always @(posedge clk) begin
    mosi_sync <= {mosi, mosi_sync[1:1]};
    sck_sync <= {sck, sck_sync[2:1]};
    ssel_sync <= {ssel, ssel_sync[2:1]};
  end

  wire sck_posedge = sck_sync[1:0] == 2'b10;
  wire sck_negedge = sck_sync[1:0] == 2'b01;
  wire ssel_posedge = ssel_sync[1:0] == 2'b10;
  wire ssel_negedge = ssel_sync[1:0] == 2'b01;
  wire ssel_active = ssel_sync[0] == 0;
  reg mosi_mem;
  reg [7:0] bit_count;

  always @(posedge clk) begin
    if (ssel_negedge) begin
      trx_buffer = transmit_data;
	  bit_count = 0;
    end
    else if (sck_posedge) begin
		mosi_mem = mosi_sync;
    end
    else if (sck_negedge) begin
      trx_buffer = {mosi_mem, trx_buffer[DATA_LEN - 1: 1]};
	  bit_count = bit_count + 1;
    end
  end

  assign miso = ssel_active ? trx_buffer[0] : 1'bz;
  assign receive_ready = ssel_active && (bit_count == DATA_LEN);
  assign receive_data = trx_buffer;
endmodule
