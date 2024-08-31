module clock_divider (
	input  clk ,
	input  reset,
	input [8:0] state_duration,
	output clk_baud
);
	assign state_duration = 9'h144;	
	reg [8:0] count = 0;
	//reg clk_ss;

	//initial begin
	//clk_ss=0;
	//end

	//always begin
	//#1	clk_ss=~clk_ss;
	//end

	always @(posedge clk ) 
	begin
		if(reset == 1'b0) begin
			count <= 0;
		end
		else if(count>=state_duration) begin 			
			count <= 0;
		end
		else begin
			count <= count + 1  ;
		end
		
	end

	assign clk_baud = count == state_duration;
	
	
	
endmodule













