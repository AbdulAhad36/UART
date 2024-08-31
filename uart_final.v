module uart_final #(parameter BAUD_RATE=256000)(		//can can control the baud rate by assigning the desired value 
	input  clk,					//to parameter BAUD_RATE here we have taken 24000 as an example
	input [7:0] data_in,				//value
	input  wire tx_rx_start,
	output [7:0]data_out,
	output tx_done,
	output rx_done

	);
	
	wire clk_baud;
	wire tx;
	wire rx;
	//reg clk;
	
	
	//initial begin			
	//clk=0;
	//end

	//always begin
	// #1 clk=~clk;
	//end	

	
	

	baudgen #(.BAUD_RATE(BAUD_RATE)) gen (		//calling baud generator module
		.clk(clk),
		.tx_rx_start(tx_rx_start),
		.clk_baud(clk_baud)
	);


	uart_tx transmitter (				//calling transmitter module
		.data_in(data_in),
		.tx_rx_start(tx_rx_start),	
		.clk_baud(clk_baud),
		.tx_done(tx_done),
		.tx(tx)
	);

	uart_rx reciever (				// calling reciever module
		.rx(tx),
		.tx_rx_start(tx_rx_start),
		.clk_baud(clk_baud),
		.rx_done(rx_done),
		.data_out(data_out)
	
	);
	

endmodule

module uart_tx(						//transmitting module						
	input [7:0] data_in, //input data 8 bit	
	input wire tx_rx_start, //enable
	input clk_baud, //from baud gen
	output reg tx_done,  //indiactor
	output reg tx   //output serial data	
	
);

	parameter IDLE=2'b00;  //0 =idle
	parameter START=2'b01; //1=start
	parameter TRANS=2'b10; //2=transmission
	parameter STOP=2'b11; // 3= stop
	reg [1:0] current_state_tx= IDLE;
	reg [10:0] buffer;   //data pack
	reg [3:0] count;
	reg parity_bit;
	
	//initial 
	//begin : proc_parity_gen
   	//	parity_bit <= ^data_in; //parity bit generate using XOR operator
   		
  	//end
		
	always@(posedge clk_baud) begin: FSM			//finite state machine
	
	case(current_state_tx)
		IDLE: 
		begin
			
			if(tx_rx_start == 1'b1  )
			begin	
				current_state_tx <= START;		//proceeds to start state as the enable pin is pulled high
				tx <= 1 ;				//else stays idle
				tx_done <= 0;
				buffer <= 0;
				parity_bit <= ^data_in; 
		 
			end
			else 
			begin
				//tx <= 1;
				tx_done <= 0;
				//buffer <= 0;
				current_state_tx <= IDLE;
		 
			end
		end

		START:
		begin
			tx <= 0 ;
			if(tx_rx_start)						// input data loads in data packet as enable is pulled high
			begin							// then proceeds to tansmission state
				buffer <= {1'b1,parity_bit,data_in,1'b0}; // loading of data in data packet 
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

module uart_rx(						//reciever module
	input reg rx, //recieving data serial	
	input wire tx_rx_start,   //enable
	input clk_baud, //from baud gen
	output reg rx_done, //data sent indicator
	output reg [7:0] data_out   //output data 8bit

);

	parameter IDLE=3'b000;  //0=idle
	parameter START=3'b001; //1=start
	parameter RECIEVE=3'b010; //2=transmission
	parameter CHECK_SUM=3'b011;	 //3=check sum/parity check
	parameter STOP=3'b100; // 4= stop
	reg parity_bit;
	reg [2:0] current_state_rx= 3'b000;
	reg [8:0] buffer;  // 8 data 1 parity(data pack)
	reg [3:0] count;
	
	
	always@(posedge clk_baud) begin: FSM		//finite state machine
	
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
				//buffer <= 0;
				//count <= 0;
				current_state_rx <= IDLE;
		 
			end
		end

		START:
		begin		 
			if(rx==1'b0)				// when  rx=0 is recieved current state will switch to recieve state if not then it will remain in start state
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

		STOP:							//stop state is just for the indication of data receive confirmation
		begin
			rx_done <=1;							
			current_state_rx <= START ;	
										//as it pulls the rx_done high and then proceeds to IDLE state where all the values 
		end									//are intialized once again and as we know that until the new data is transmitted the 
									// the transmitter gives 1 as output due to which the code deosn't proceed to recieving state
		default: current_state_rx <= IDLE;
		
	endcase	
	
	end

endmodule

module baudgen #(parameter BAUD_RATE=2400)( 		//baud rate generator
	input  clk ,
	input wire tx_rx_start,
	output reg clk_baud
);
		
	parameter FREQ = 1000000; //1Mhz;
	parameter baud = FREQ/BAUD_RATE;
	reg [31:0] count = 0;

	always @(posedge clk ) 				//for every rising edge of input clock the value of count increases and
	begin						//as it reaches the value of baud the clk_baud becomes high ,then it resets
		if(tx_rx_start == 1'b0) begin		// as the value of count becomes greater
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

