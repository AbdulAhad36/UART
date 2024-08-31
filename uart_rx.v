module uart_rx(
	input reg rx, //recieving data serial	
	input tx_rx_start,   //enable
	input clk_baud, //from baud gen
	output reg rx_done, //data sent indicator
	output reg [7:0] data_out,   //output data 8bit
	output reg parity_bit,
	output reg [2:0] current_state_rx= 3'b000,
	output reg [8:0] buffer,  // 8 data 1 parity(data pack)
	output reg [3:0] count
);

	parameter IDLE=3'b000;  //0=idle
	parameter START=3'b001; //1=start
	parameter RECIEVE=3'b010; //2=transmission
	parameter CHECK_SUM=3'b011;	 //3=check sum/parity check
	parameter STOP=3'b100; // 4= stop
	
	//reg clk_sim;
	
	
	
	 
	
   	
	
	//initial begin   //clk generator for simulation purposes
	//	clk_sim=0;
	//	end

	//always
	//	#100 clk_sim=~clk_sim;




	always@(posedge clk_baud) begin: FSM
	
	case(current_state_rx)
		IDLE: 
		begin
		
			if(tx_rx_start == 1 )                //when enable pin is 1 will move to start state if not will stay idle
			begin			
				rx_done <= 0;
				buffer <= 0;
				count <= 0;
				current_state_rx <= START;	
		 
			end
			else 
			begin				
				rx_done <= 0;
				buffer <= 0;
				count <= 0;
				current_state_rx <= IDLE;
		 
			end
		end

		START:
		begin		 
			if(rx==1'b0)				// when the starts to recieve rx=0 will move to recieve state if not will remain in start state
			begin
				current_state_rx <= RECIEVE;
				buffer <= 0;
				count <= 0;
				rx_done <= 0;
				
			end
			else
			begin
				current_state_rx <= START; 
				buffer <= 0;          
				rx_done <= 0;		
				count <= 0;
			end

		end

		RECIEVE:
		begin
			if( count == 8 )
			begin
				buffer <= {rx,buffer[8:1]};
           			current_state_rx <= CHECK_SUM;
         		end
			else 
			begin
            			buffer <= {rx,buffer[8:1]};				//the count will increase as the revcieving data gets concatinated with the
            			count  <= count+1;					//1st to 8th bit of the register leaving the 9th bit for the parity check
          		end
		end

		CHECK_SUM:
		begin
			parity_bit = ^buffer[8:1];					//if the parity matches the first 1st to 8th bit is sent to output
			if( rx == parity_bit )
			begin
				data_out <= buffer [8:1];
				current_state_rx <= STOP;
			end
			else
			begin								//if not then an undefied value is def into the register with the 9th bit being the
   				data_out <= 'x;						//changed parity bit	
         			buffer[8] <= rx;
          			current_state_rx <= STOP;					//bot scenarios proceed to stop state
			end
				
		end

		STOP:
		begin
			rx_done <=1;
			data_out <= 'x	;					//stop state is just for the indication of data receive confirmation
			current_state_rx <= START ;						//as it pulls the rx_done high and then proceeds to IDLE state where all the values 
		end									//are intialized once again and as we know that until the new data is transmitted the 
											// the transmitter gives 1 as output due to which the code deosn't proceed to recieving state
		default: current_state_rx <= IDLE;
		


	endcase
	
	end

endmodule
