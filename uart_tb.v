
//incomplete
module uart_tb();

	reg [7:0] data_in;
	reg clk;
	reg  tx_start;
	reg tick;   
	wire  tx_done;
	wire  tx;

	wire [1:0] current_state= 2'b00;
	wire [10:0] buffer;   //data pack
	wire[3:0] count;
	wire parity_bit;

	parameter IDLE=2'b00;  //0 pe idle
	parameter START=2'b01; //1=start
	parameter TRANS=2'b10; //2=transmission
	parameter STOP=2'b11; // 3= stop
	
	//wire [1:0] current_state= IDLE;
	//wire [10:0] buffer;
	//wire [3:0] count;
	//wire parity_bit;



uart uart_tx( data_in ,clk,tx_start,tick,tx_done,tx,current_state,buffer,count,parity_bit);

	initial begin
		clk=0;
		end
	initial 
	begin : proc_parity_gen
   		parity_bit = ^data_in; //parity bit generate using XOR operator
   		
  	end


	always
		#100 clk=~clk;

	initial begin
		data_in <= 8'b00000011;
		tx_start <= 0;
		#300 tx_start<=1;
		tick <=1;
		end
endmodule
 	