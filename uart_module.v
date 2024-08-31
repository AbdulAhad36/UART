module uart_module #(parameter BAUD_RATE=24000)(
	//input  clk,
	input [7:0] data_in,	
	input tx_rx_start,
	//input tick,
	output  [7:0]data_out,
	output tx_done,
	output rx_done,
	output parity_bit,
	output [8:0] buffer,
	output  [3:0]count,
	output  [2:0] current_state_rx
	);
	
	wire clk_baud;
	wire tx;
	wire rx;
	reg clk;
	


	initial begin
	clk=0;
	end

	always begin
	 #1 clk=~clk;
	end	


	baudgen #(.BAUD_RATE(BAUD_RATE)) gen ( 
		.clk(clk),
		.tx_rx_start(tx_rx_start),
		.clk_baud(clk_baud)
	);


	uart_tx transmitter (
		.data_in(data_in),
		.tx_rx_start(tx_rx_start),
		//.tick(tick),
		.clk_baud(clk_baud),
		.tx_done(tx_done),
		.tx(tx)
	);

	uart_rx reciever (
		.rx(tx),
		.tx_rx_start(tx_rx_start),
		.clk_baud(clk_baud),
		.rx_done(rx_done),
		.data_out(data_out),
		.parity_bit(parity_bit),
		.current_state_rx(current_state_rx),
		.buffer(buffer),
		.count(count)
	);
	


endmodule