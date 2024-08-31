module baudgen #(parameter BAUD_RATE=2400)(
	input  clk ,
	input  tx_rx_start,
	output reg clk_baud
);
		
	parameter FREQ = 1000000; //1Mhz;
	parameter baud = FREQ/BAUD_RATE;

	reg [31:0] count = 0;
	//reg clk_ss;

	//initial begin
	//clk_ss=0;
	//end

	//always begin
	//#5	clk_ss=~clk_ss;
	//end

	always @(posedge clk ) 
	begin
		if(tx_rx_start == 1'b0) begin
			count <= 0;
		end
		else if(count>=baud) begin 			
			count <= 0;
		end
		else begin
			count <= count + 1  ;
		end
		
	end

	
	always@(posedge clk) begin 		
		clk_baud = count == baud;
		end


	
	
	
endmodule
