module main
	(
		CLOCK_50,						//	On Board 50 MHz
        KEY,
        SW,
		  HEX0,
		  HEX1,
		  HEX2,
		  HEX3,
		  HEX4,
		  HEX5,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	
	output  [6:0]   HEX0;
	output  [6:0]   HEX1;
	output  [6:0]   HEX2;
	output  [6:0]   HEX3;
	output  [6:0]   HEX4;
	output  [6:0]   HEX5;

	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	wire go;
	assign resetn = SW[0];
	assign go = SW[1];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120"; // try changing this, but keeping x and y the same width
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	wire framerate;
	wire [229:0] board;
	wire [3:0] x1, x2, x3, x4;
	wire [4:0] y1, y2, y3, y4;
	wire [9:0]hundred_thousands, ten_thousands, thousands, hundreds, tens, ones;
	
	// Should automatically zero extend...
	// wire [3:0] xout;
	// wire [4:0] yout;
	// assign x = {4'd0, xout};
	// assign y = {2'd0, yout};

	tetris t0(
		.clock_on_board(CLOCK_50),
		.start_game(go),
		.resetn(resetn),
		.key_left(!KEY[2]),
		.key_right(!KEY[0]),
		.key_rotate(!KEY[3]),
		.flat_board(board),
		.block1_x(x1),
		.block2_x(x2),
		.block3_x(x3),
		.block4_x(x4),
		.block1_y(y1),
		.block2_y(y2),
		.block3_y(y3),
		.block4_y(y4),
		.hundred_thousands(hundred_thousands),
		.ten_thousands(ten_thousands),
		.thousands(thousands),
		.hundreds(hundreds),
		.tens(tens),
		.ones(ones)
		);
		
	hex_decoder h0(
		.hex_digit(ones),
		.segments(HEX0)
	);
	
	hex_decoder h1(
		.hex_digit(tens),
		.segments(HEX1)
	);
	
	hex_decoder h2(
		.hex_digit(hundreds),
		.segments(HEX2)
	);
	
	hex_decoder h3(
		.hex_digit(thousands),
		.segments(HEX3)
	);
	
	hex_decoder h4(
		.hex_digit(ten_thousands),
		.segments(HEX4)
	);
	
	hex_decoder h5(
		.hex_digit(hundred_thousands),
		.segments(HEX5)
	);
	
	control_data cd0(
		.enable(framerate),
		.clock(CLOCK_50),
		.resetn(resetn),
		.board(board),
		.b1_col(x1),
		.b2_col(x2),
		.b3_col(x3),
		.b4_col(x4),
		.b1_row(y1),
		.b2_row(y2),
		.b3_row(y3),
		.b4_row(y4),
		.plot(writeEn),
		.x(x),
		.y(y),
		.colour(colour)
		);
	
	rate_divider r1(
		.resetn(resetn),
		.load_value(20'd833333),
		//.load_value(20'd3),
		.clock_in(CLOCK_50),
		.clock_out(framerate)
		);
endmodule

module control_data(
input enable, clock, resetn,
input [229:0] board,
input [3:0] b1_col, b2_col, b3_col, b4_col,
input [4:0] b1_row, b2_row, b3_row, b4_row,
output plot,
output [3:0] x,
output [4:0] y,
output [2:0] colour);
	
	wire [9:0] counter;
	wire [2:0] blockcolour;
	wire resetcount, drawblock, load1,load2, load3, load4;
	
	vga_control vgac0(
		.enable(enable),
		.clock(clock),
		.resetn(resetn),
		.count_in(counter),
		.plot(plot),
		.reset_count(resetcount),
		.draw_block(drawblock),
		.load_b1(load1),
		.load_b2(load2),
		.load_b3(load3),
		.load_b4(load4),
		.colour(blockcolour)
		);
	datapath d0(
		.clock(clock),
		.resetn(resetn),
		.reset_count(resetcount),
		.draw_block(drawblock),
		.load_b1(load1),
		.load_b2(load2),
		.load_b3(load3),
		.load_b4(load4),
		.colour_in(blockcolour),
		.board(board),
		.b1_col(b1_col),
		.b2_col(b2_col),
		.b3_col(b3_col),
		.b4_col(b4_col),
		.b1_row(b1_row),
		.b2_row(b2_row),
		.b3_row(b3_row),
		.b4_row(b4_row),
		.xout(x),
		.yout(y),
		.colour_out(colour),
		.count_out(counter)
		);	
endmodule


module vga_control(
input enable, clock, resetn,
input [9:0] count_in,
output reg plot,
output reg reset_count, draw_block,
output reg load_b1, load_b2, load_b3, load_b4,
output reg [2:0] colour);

	reg [3:0] current_state, next_state;
	
	localparam	WAIT				= 4'd0,
					WAIT2				= 4'd1,
					ERASE				= 4'd2,
					ERASE_WAIT		= 4'd3,
					WAIT3				= 4'd4,
					DRAW				= 4'd5,
					DRAW_B1_PREP 	= 4'd6,
					DRAW_B1			= 4'd7,
					DRAW_B2			= 4'd8,
					DRAW_B3			= 4'd9,
					DRAW_B4			= 4'd10;

	always @(*) begin
		case (current_state)
			WAIT: next_state = enable ? WAIT2 : WAIT;
			WAIT2: next_state = ERASE;
			ERASE: next_state = (count_in == 10'b1111_1111_11) ? ERASE_WAIT : ERASE;
			ERASE_WAIT: next_state = WAIT3;
			WAIT3: next_state = DRAW;
			DRAW: next_state = (count_in == 10'b1111_1111_11) ? DRAW_B1_PREP : DRAW;
			DRAW_B1_PREP: next_state = DRAW_B1;
			DRAW_B1: next_state = DRAW_B2;
			DRAW_B2: next_state = DRAW_B3;
			DRAW_B3: next_state = DRAW_B4;
			DRAW_B4: next_state = WAIT;
			default: next_state = WAIT;
		endcase
	end
	
	always @(*) begin
		plot = 1'b0;
		reset_count = 1'b0;
		draw_block = 1'b0;
		load_b1 = 1'b0;
		load_b2 = 1'b0;
		load_b3 = 1'b0;
		load_b4 = 1'b0;
		colour = 3'b111;
		case (current_state)
			WAIT: begin
				reset_count = 1'b1;
				end
			ERASE: begin
				plot = 1'b1;
				colour = 3'b111;  // white background
				end
			ERASE_WAIT: begin
				reset_count = 1'b1;
				end
			DRAW: begin
				plot = 1'b1;
				colour = 3'b100; // red blocks
				end
			DRAW_B1_PREP: begin
				load_b1 = 1'b1;
				end
			DRAW_B1: begin
				plot = 1'b1;
				draw_block = 1'b1;
				load_b2 = 1'b1;
				colour = 3'b010;
				end
			DRAW_B2: begin
				plot = 1'b1;
				draw_block = 1'b1;
				load_b3 = 1'b1;
				colour = 3'b010;
				end
			DRAW_B3: begin
				plot = 1'b1;
				draw_block = 1'b1;
				load_b4 = 1'b1;
				colour = 3'b010;
				end
			DRAW_B4: begin
				plot = 1'b1;
				draw_block = 1'b1;
				colour = 3'b010;
				end
		endcase
	end
	
	always @(posedge clock) begin
		if (!resetn)
			current_state <= WAIT;
		else
			current_state <= next_state;
	end
endmodule

module datapath(
input clock, resetn,
input reset_count, draw_block, load_b1, load_b2, load_b3, load_b4,
input [2:0] colour_in,
input [229:0] board,
input [3:0] b1_col, b2_col, b3_col, b4_col,
input [4:0] b1_row, b2_row, b3_row, b4_row,
output reg [3:0] xout,
output reg [4:0] yout,
output reg [2:0] colour_out,
output [9:0] count_out);

	reg [9:0] board_state[0:22];
	
	integer i;  // initialize board
	always@(posedge clock) begin
		for (i=0; i<23; i=i+1) begin
			board_state[i] <= board[10*i +: 10];
		end
	end
	
	always @(*) begin
		if (draw_block) begin
			colour_out <= colour_in;
			end
		else if (xout < 10 && yout < 23 && yout > 2) begin  // within board
			colour_out <= (board_state[22 - yout][xout]) ? colour_in : 3'b111;
			end
		else begin  // outside board
			colour_out <= 3'b000;
			end
	end
		
	always @(posedge clock) begin
		if (!resetn) begin
			xout <= 4'd0;
			yout <= 5'd0;
			end
		else begin
			if (load_b1) begin
				xout <= b1_col;
				yout <= 5'd22 - b1_row;
				end
			else if (load_b2) begin
				xout <= b2_col;
				yout <= 5'd22 - b2_row;
				end
			else if (load_b3) begin
				xout <= b3_col;
				yout <= 5'd22 - b3_row;
				end
			else if (load_b4) begin
				xout <= b4_col;
				yout <= 5'd22 - b4_row;
				end
			else begin
				xout <= count_out[3:0];
				yout <= count_out[8:4];
				end
		end
	end	
	
	counter10bit c0(
		.load(reset_count),
		.clk(clock),
		.resetn(resetn),
		.q(count_out)
		);
endmodule


module counter10bit(
input load, clk, resetn,
output reg [9:0] q);

	always @(posedge clk) begin
		if (!resetn)
			q <= 10'd0;
		else if (load)
			q <= 10'b0111_1111_11;
		else if (q == 10'b1111_1111_11)
			q <= 10'b1111_1111_11;
		else
			q <= q - 10'd1;
	end
endmodule
