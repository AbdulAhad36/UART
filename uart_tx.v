module uart_tx(
	input [7:0] data_in, //input data 8 bit	
	input  tx_rx_start, //enable
	//input tick, 	
	input clk_baud, //from baud gen
	output reg tx_done,  //indiactor
	output reg tx   //output serial data	
	
);


	parameter IDLE=2'b00;  //0 =idle
	parameter START=2'b01; //1=start
	parameter TRANS=2'b10; //2=transmission
	parameter STOP=2'b11; // 3= stop
	
	//reg clk_sim;	
	reg [1:0] current_state_tx= IDLE;
	reg [10:0] buffer;   //data pack
	reg [3:0] count;
	reg parity_bit;
	
	
	
	initial 
	begin : proc_parity_gen
   		parity_bit <= ^data_in; //parity bit generate using XOR operator
   		
  	end

	//initial begin			//clk gen for simulation purposes
	//	clk_sim=0;
	//	end
	//always
	//	#100 clk_sim=~clk_sim;
	

	
	always@(posedge clk_baud) begin: FSM
	
	case(current_state_tx)
		IDLE: 
		begin
		
			if(tx_rx_start == 1'b1 )
			begin	
				current_state_tx <= START;			//proceeds to start state as the enable pin is pulled high
				tx <= 1 ;				//else stays idle
				tx_done <= 0;
				buffer <= 0;
		 
			end
			else 
			begin
				tx <= 1;
				tx_done <= 0;
				buffer <= 0;
				current_state_tx <= IDLE;
		 
			end
		end

		START:
		begin
			tx <= 0 ;
			if(tx_rx_start)						// input data loads in data packet as tick is pulled high
			begin							// then proceeds to tansmission state
				buffer <= {1'b1,parity_bit,data_in,1'b0}; // data pack 
				count <= 0;
				tx_done <= 0;
				current_state_tx <= TRANS;
			end
			else
			begin
				current_state_tx <= START;
				tx_done <= 0;		
				count <= 0;
			end

		end

		TRANS:
		begin
			if(count==9)				//the count increases as the input data gets loaded bit by bit into the
			begin					// the buffer/data packet then proceeds to stop state
				tx  <= buffer[0];
            			buffer   <= buffer>>1;
            			count    <= count+1;
           			current_state_tx <= STOP;
         		end
			else 
			begin
            			tx      <= buffer[0];
           			buffer <=  buffer>>1;
            			count     <= count+1;
          		end
		end

		STOP:						//tx_done/indiactor is pulled high and the state is set to IDLE
		begin						// where all the values are intialized and 1 is trasnmitted until
			tx   <= 1;				// enable is pulled high
			tx_done <=1;
			current_state_tx <= IDLE;
		end

		default: current_state_tx <= IDLE;
		


	endcase
	
	end

endmodule

