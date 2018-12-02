module control(
input clock,
input filled_under,
input overflow,
input [19:0] completed_lines,
input start_game,
input resetn,
output reg load_block,
output reg drop_block,
output reg update_board_state,
output reg shift_down,
output reg game_over,
output reg [2:0]score_multiplier,
output reg add_score);
	
    reg [3:0] current_state, next_state; 
    
    localparam  S_PRE_GAME            = 4'd0,
					 S_PRE_GAME_BUFFER     = 4'd1,
                S_LOAD_BLOCK          = 4'd2,
                S_DROP_BLOCK          = 4'd3,
                S_UPDATE_BOARD_STATE  = 4'd4,
					 S_CHECK_LOSS          = 4'd5,
					 S_CHECK_LINES         = 4'd6,
					 S_CLEAR_LINE          = 4'd7,
					 S_ADD_SCORE           = 4'd8,
					 S_GAME_OVER           = 4'd9;
	
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_PRE_GAME: next_state = start_game ? S_PRE_GAME_BUFFER : S_PRE_GAME;
					 S_PRE_GAME_BUFFER: next_state = !start_game ? S_LOAD_BLOCK : S_PRE_GAME_BUFFER;
					 S_LOAD_BLOCK: next_state = S_DROP_BLOCK;
					 S_DROP_BLOCK: next_state = filled_under ? S_UPDATE_BOARD_STATE : S_DROP_BLOCK;
					 S_UPDATE_BOARD_STATE: next_state = S_CHECK_LOSS;
					 S_CHECK_LOSS: next_state = overflow ? S_GAME_OVER : S_CHECK_LINES;
					 S_CHECK_LINES: next_state = (|completed_lines) ? S_CLEAR_LINE : S_ADD_SCORE;
					 S_CLEAR_LINE: next_state = S_CHECK_LINES;
					 S_ADD_SCORE: next_state = S_LOAD_BLOCK;
					 S_GAME_OVER: next_state = S_GAME_OVER;
					 default: next_state = S_PRE_GAME;
        endcase
    end // state_table
	 
    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		  load_block = 0;
        drop_block = 0;
		  update_board_state = 0;
		  shift_down = 0;
		  game_over = 0;
		  add_score = 0;

        case (current_state)
            S_LOAD_BLOCK: begin
                load_block = 1;
					 score_multiplier = 0;
                end
            S_DROP_BLOCK: begin
                drop_block = 1;
                end
            S_UPDATE_BOARD_STATE: begin
                update_board_state = 1;
                end
				S_CLEAR_LINE: begin
					 shift_down = 1;
					 score_multiplier = score_multiplier + 1;
					 end
				S_ADD_SCORE: begin
					 add_score = 1;
					 end
				S_GAME_OVER: begin
					game_over = 1;
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