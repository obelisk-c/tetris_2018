module control(
input clock,
input filled_under,
input start_game,
input resetn,
output reg load_block,
output reg drop_block,
output reg update_board_state);
	
    reg [3:0] current_state, next_state; 
    
    localparam  S_PRE_GAME            = 4'd0,
					 S_PRE_GAME_BUFFER     = 4'd1,
                S_LOAD_BLOCK          = 4'd2,
                S_DROP_BLOCK          = 4'd3,
                S_UPDATE_BOARD_STATE  = 4'd4;
	
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_PRE_GAME: next_state = start_game ? S_PRE_GAME_BUFFER : S_PRE_GAME;
					 S_PRE_GAME_BUFFER: next_state = !start_game ? S_LOAD_BLOCK : S_PRE_GAME_BUFFER;
					 S_LOAD_BLOCK: next_state = S_DROP_BLOCK;
					 S_DROP_BLOCK: next_state = filled_under ? S_UPDATE_BOARD_STATE : S_DROP_BLOCK;
					 S_UPDATE_BOARD_STATE: next_state = S_LOAD_BLOCK;
            default:     next_state = S_PRE_GAME;
        endcase
    end // state_table
	 
    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		  load_block = 0;
        drop_block = 0;
		  update_board_state = 0;

        case (current_state)
            S_LOAD_BLOCK: begin
                load_block = 1;
                end
            S_DROP_BLOCK: begin
                drop_block = 1;
                end
            S_UPDATE_BOARD_STATE: begin
                update_board_state = 1;
                end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(!resetn)
            current_state <= S_PRE_GAME;
        else
            current_state <= next_state;
    end // state_FFS
endmodule