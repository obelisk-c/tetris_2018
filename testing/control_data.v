// ....
// BBB.
//  BF.
// ....
// top, bottom, right black. B: current blocks. F: fallen blocks. ( ): empty space


module control_data(
input enable, clk, resetn,
output plot,
output [1:0] x,
output [1:0] y,
output [2:0] colour);
	
	wire [4:0] counter;
	wire [2:0] blockcolour;
	wire resetcount, drawblock, load1, load2, load3, load4;
	
	control c0(
		.enable(enable),
		.clock(clk),
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
		.clock(clk),
		.resetn(resetn),
		.reset_count(resetcount),
		.draw_block(drawblock),
		.load_b1(load1),
		.load_b2(load2),
		.load_b3(load3),
		.load_b4(load4),
		.colour_in(blockcolour),
		.xout(x),
		.yout(y),
		.colour_out(colour),
		.count_out(counter)
		);
endmodule


module control(
input enable, clock, resetn,
input [4:0] count_in,
output reg plot,
output reg reset_count, draw_block,
output reg load_b1, load_b2, load_b3, load_b4,
output reg [2:0] colour);

	reg [3:0] current_state, next_state;
	
	localparam	WAIT				= 4'd0,
					WAIT2		= 4'd1,
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
			ERASE: next_state = (count_in == 5'd31) ? ERASE_WAIT : ERASE;
			ERASE_WAIT: next_state = WAIT3;
			WAIT3: next_state = DRAW;
			DRAW: next_state = (count_in == 5'd31) ? DRAW_B1_PREP : DRAW;
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
				colour = 3'b100;
				end
			DRAW_B2: begin
				plot = 1'b1;
				draw_block = 1'b1;
				load_b3 = 1'b1;
				colour = 3'b100;
				end
			DRAW_B3: begin
				plot = 1'b1;
				draw_block = 1'b1;
				load_b4 = 1'b1;
				colour = 3'b100;
				end
			DRAW_B4: begin
				plot = 1'b1;
				draw_block = 1'b1;
				colour = 3'b100;
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
input reset_count, draw_block,
input load_b1, load_b2, load_b3, load_b4,
input [2:0] colour_in,
output reg [1:0] xout,
output reg [1:0] yout,
output reg [2:0] colour_out,
output [4:0] count_out);

	reg [2:0] board_state[0:2];
	
	integer i;  // initialize board so bottom right is filled
	always@(posedge clock) begin
		board_state[0][0] <= 1'b0;  // board_state[0] <= 3'b100; ?
		board_state[0][1] <= 1'b0;
		board_state[0][2] <= 1'b1;		
		board_state[1] <= 3'b000;
		board_state[2] <= 3'b000;
	end
	
	wire [1:0] b1_col, b2_col, b3_col, b4_col, b1_row, b2_row, b3_row, b4_row;  //initialize T block on bottom
	assign b1_col = 2'd0;
	assign b1_row = 2'd1;
	assign b2_col = 2'd1;
	assign b2_row = 2'd0;
	assign b3_col = 2'd1;
	assign b3_row = 2'd1;
	assign b4_col = 2'd2;
	assign b4_row = 2'd1;
	
	always @(*) begin
		if (draw_block) begin
			colour_out <= colour_in;
			end
		else if (xout < 3 && yout < 3 && yout > 0) begin  // within board
			colour_out <= (board_state[2 - yout][xout]) ? colour_in : 3'b111;
			end
		else begin  // outside board
			colour_out <= 3'b000;
			end
	end
		
	always @(posedge clock) begin
		if (!resetn) begin
			xout <= 2'd0;
			yout <= 2'd0;
			end
		else begin
			if (load_b1) begin
				xout <= b1_col;
				yout <= 2'd2 - b1_row;
				end
			else if (load_b2) begin
				xout <= b2_col;
				yout <= 2'd2 - b2_row;
				end
			else if (load_b3) begin
				xout <= b3_col;
				yout <= 2'd2 - b3_row;
				end
			else if (load_b4) begin
				xout <= b4_col;
				yout <= 2'd2 - b4_row;
				end
			else begin
				xout <= count_out[1:0];
				yout <= count_out[3:2];
				end
		end
	end	
	
	counter5bit c0(
		.load(reset_count),
		.clk(clock),
		.resetn(resetn),
		.q(count_out)
		);
endmodule


module counter5bit(
input load, clk, resetn,
output reg [4:0] q);

	always @(posedge clk) begin
		if (!resetn)
			q <= 5'd0;
		else if (load)
			q <= 5'b0111_1;
		else if (q == -1)
			q <= -1;
		else
			q <= q - 1;
	end
endmodule