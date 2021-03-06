module knight_rider_rom(
	input wire CLOCK_50,
	input wire SW,
	output wire [9:0] LEDR
);
	wire slow_clock;

	reg [3:0] count;
	reg count_up;

	clock_divider u0 (.fast_clock(CLOCK_50), .slow_clock(slow_clock), .speed_sw(SW));

	always @ (posedge slow_clock)
	begin
		if (count_up)
			count <= count + 1'b1;
		else
			count <= count - 1'b1;
	end

	always @ (posedge slow_clock)
	begin
		// count border conditions should be 8 and 1
		// due to the flip-flop prevoius/next values. 
		// On 9 it should start counting down and for
		// doing that we should change counting direction
		// on 8.
		if (count == 8)
			count_up <= 1'b0;
		else if (count == 1)
			count_up <= 1'b1;
		else
			count_up <= count_up;
	end

	assign LEDR[9:0] = (1'b1 << count);

endmodule


module clock_divider(
	input fast_clock,
	input speed_sw,
	output slow_clock
);
	// Every LED should light up for 0.1s => 10 Hz frequency
	// Let the divider be x, then it should be:
	//   50MHz/x = 10Hz -> x = 50MHz/10Hz = 5*10^5
	//   log2(5*10^6) = 22.25
	//   COUNTER_SIZE = 23 -> 0.16s light on
	//   COUNTER_SIZE = 22 -> 0.08s light on  <-------- best approximation
	//   COUNTER_SIZE = 21 -> 0.04s light on
	//parameter COUNTER_SIZE = 22;
	//parameter COUNTER_MAX_COUNT = (2 ** COUNTER_SIZE) - 1;

	parameter COUNTER_SIZE = 23;
	
	reg [31:0] count;
	wire [7:0] rom_out;
	
	ROM	ROM_inst (
		.address ( 0 ),
		.clock ( fast_clock ),
		.q ( rom_out )
	);
	
	always @ (posedge fast_clock)
	begin
			count <= count + 1'b1;
	end

	assign slow_clock = speed_sw ? count[COUNTER_SIZE-1] : count[rom_out];

endmodule 