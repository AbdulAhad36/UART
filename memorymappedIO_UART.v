module memorymappedIO_UART #(parameter BAUD_RATE=24000)(
	//input clk,
	input [31:0] address,  // from risc v ALU output
	input [31:0] WD,		//input data from risc v which goes to UART
	input [7:0] uart_reciever,	// recieves data from UART rx output
	input mem_write,		//control signal for enabling write	
	input wire [7:0] uart_transmitter,	//is used to transfer data to input of UART tx	 
	output  [31:0] RD,	// read data
	output [7:0]data_out,
	output tx_done,
	output rx_done

);
	//wire [7:0] uart_transmitter; //sending to tx input of uart
	wire tx;
	reg tx_rx_start;
	
	reg clk;
	initial begin
	clk<=0;
	end
	always begin
	#1 clk=~clk;
	end
	
	always@(posedge clk) begin
		if(uart_transmitter && rx_done==0) begin
			tx_rx_start<=1; end end
	always @(posedge clk) begin 
		 if(uart_transmitter && rx_done == 1) begin
			tx_rx_start<='x; end end


	memory_mapped_IO mmio (
		.clk(clk),
		.address(address),
		.WD(WD),
		.uart_reciever(data_out),
		.mem_write(mem_write),	
		.RD(RD),
		.uart_transmitter(uart_transmitter)

	);

	uart_final #(.BAUD_RATE(BAUD_RATE)) uart (
		.clk(clk),
		.data_in(uart_transmitter),
		.tx_rx_start(tx_rx_start),
		.data_out(data_out),
		.tx_done(tx_done),
		.rx_done(rx_done)

	);

endmodule
