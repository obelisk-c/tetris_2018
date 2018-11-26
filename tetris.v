module tetris(
input clock_on_board,
input start_game,
input resetn,
input key_left,
input key_right);

	// An array that contains the status of each location in the board, and whether there is an already dropped
	// block filling that coordinate.
	reg [9:0] board_state[0:22];
	
	// The location at which to load the central block.
	reg [3:0]load_x;
   reg [4:0]load_y;
	
	// The x and y positions of the four blocks of the tetromino.
	wire [4:0] block1_y, block2_y, block3_y, block4_y;
	wire [3:0] block1_x, block2_x, block3_x, block4_x;
	
	// The x and y positions of the tetromino's central block.
	reg [4:0] y;
	reg [3:0] x;
	
	// Used for the for loop to initialize the board.
	integer i, j;
	
	// The clocks used in the game.
	wire clock_framerate, clock_block_fall;
	
	// Initializes the board.
	initial begin
		for (i=0; i<23; i=i+1) begin
			for (j=0; j<10; j=j+1) begin
				board_state[i][j] <= 0;
			end 
		end
	end
	
	// Returns the four blocks of the current tetromino.
	block_returner b1(
	.x(x),
	.y(y),
	.x1(block1_x),
	.y1(block1_y),
	.x2(block2_x),
	.y2(block2_y),
	.x3(block3_x),
	.y3(block3_y),
	.x4(block4_x),
	.y4(block4_y));
	
	// Returns a 60Hz (approximately) clock.
	rate_divider r1(
	.resetn(resetn),
	//.load_value(20'd833333),
	.load_value(20'd3),
	.clock_in(clock_on_board),
	.clock_out(clock_framerate));
	
	// Returns a much slower clock for the rate of the block fall.
	rate_divider r2(
	.resetn(resetn),
	//.load_value(some arbitrary number),
	.load_value(20'd2),
	.clock_in(clock_framerate),
	.clock_out(clock_block_fall));

	// Moves the y coordinate of the central block down.
	task move_down(); 
		begin
		   y <= y - 1;
		end
	endtask
	
	// Moves the x coordinate of the central block left.
	task move_left(); 
		begin
		   x <= x - 1;
		end
	endtask
	
	// Moves the x coordinate of the central block right.
	task move_right(); 
		begin
		   x <= x + 1;
		end
	endtask
	
	// Fills in the board state with the current coordinates of the four blocks.
	task update_board();
		begin
			board_state[block1_y][block1_x] <= 1;
			board_state[block2_y][block2_x] <= 1;
			board_state[block3_y][block3_x] <= 1;
			board_state[block4_y][block4_x] <= 1;
		end
		
	endtask
	
	// Whether any of the four blocks have an already dropped block under them or are at the bottom row.
	wire filled_under = (block1_y == 0 || block2_y == 0 || block3_y == 0 || block4_y == 0) || 
	(board_state[block1_y - 1][block1_x] || board_state[block2_y - 1][block2_x] 
   || board_state[block3_y - 1][block3_x] || board_state[block4_y - 1][block4_x]);
	
	// Whether any of the four blocks have an already dropped block to the left of them or are at the leftmost row.
	wire filled_left = (block1_x == 0 || block2_x == 0 || block3_x == 0 || block4_x == 0) || 
	(board_state[block1_y][block1_x - 1] || board_state[block2_y][block2_x - 1] 
	|| board_state[block3_y][block3_x - 1] || board_state[block4_y][block4_x - 1]);
	
	// Whether any of the four blocks have an already dropped block under them or are at the bottom row.
	wire filled_right = (block1_x == 9 || block2_x == 9 || block3_x == 9 || block4_x == 9) || 
	(board_state[block1_y][block1_x + 1] || board_state[block2_y][block2_x + 1] 
	|| board_state[block3_y][block3_x + 1] || board_state[block4_y][block4_x + 1]);
	
	control c1(.clock(clock_block_fall),
	.start_game(start_game),
	.resetn(resetn),
	.filled_under(filled_under),
	.load_block(load_block),
	.drop_block(drop_block),
	.update_board_state(update_board_state));
	
	
	
	// Game logic.  Effectively datapath.
	always@(posedge clock_framerate) begin
		if (!resetn) begin
			y <= load_x;
			x <= load_y;
		// Checks if the block is supposed to drop this cycle. Does that if it should.
		end else if (clock_block_fall) begin
			if (load_block) begin
				x <= load_x;
				y <= load_y;
			end
			if (drop_block && !filled_under) begin
				move_down();
			end
			if (update_board_state) begin
				update_board();
			end
		// Checks if the user wants to move to the left.
		end else if (key_left && !filled_left) begin
			move_left();
		// Checks if the user wants to move to the right.
		end else if (key_right && !filled_right) begin
			move_right();
		end
	end
endmodule

