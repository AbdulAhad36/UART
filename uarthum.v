module uarthum (
  input              clk_t  ,
  input              srst   ,
  input              start  ,
  input        [7:0] data_in,
  output logic       tx     ,
  output logic       busy
);

  typedef enum logic[3:0]{IDLE =0 ,START=1,TRANSMIT=2,STOP=3} state_e;

  logic   end_tx    = 0   ;
  state_e cur_state = IDLE; //initial idle state
  state_e nxt_state       ;

  logic [10:0] tx_pack   ;
  logic        parity_bit;
  logic [ 3:0] cnt       ; // to keep record of bit transmitted;

  always_comb begin : proc_parity_gen
    parity_bit = ^data_in; //parity bit generate
    busy       = (cur_state == STOP);
  end


// always_ff @(posedge clk_t) begin
//  if(srst) begin
//    cnt<=0;
//    cur_state <= START;
//  end else begin
//    cur_state <= cur_state ;
//  end
// end


  always_ff @(posedge clk_t) begin : proc_main_fsm
    end_tx <= 0;
    case(cur_state)
      IDLE : begin
        if(srst)
          begin
            cur_state <= IDLE;
            tx_pack   <= 0;
            cnt       <= 0;
          end
        else
          cur_state <= START;
      end

      START : begin
        if(start) begin
          tx_pack   <= {1'b1,parity_bit,data_in,1'b0};//pack to be transmitt
          cnt       <= 0;
          cur_state <= TRANSMIT;
        end
        else
          begin
            tx_pack   <= 0;//pack to be transmitt
            cur_state <= START;//stays in the same state
          end
      end
      TRANSMIT :
        begin//CNT IS INC AFTER TRANSMITT BIT
          if(cnt==9) begin//from start to data sent sending parity then jump to stop state;
            tx        <= tx_pack[0];
            tx_pack   <= tx_pack>>1;
            cnt       <= cnt+1;
            cur_state <= STOP;
          end
          else begin
            tx      <= tx_pack[0];
            tx_pack <= tx_pack>>1;
            cnt     <= cnt+1;
          end
        end
      STOP :
        begin
          tx        <= tx_pack[0];
          tx_pack   <= tx_pack>>1;
          cnt       <= cnt+1;
          cur_state <= START;
          end_tx    <= 1;
        end
      default : cur_state <=IDLE;
    endcase // cur_state
  end


endmodule
