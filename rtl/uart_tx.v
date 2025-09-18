// ***************************************************************************
// * © Evgeny Sobolev, passport 76 1375783, 
// * disallowed to any type  of use by thirdparty
// * uart_tx, - UART module
// * i_rst - input reset signal
// * i_clk - input reset clock signal
// * i_baud8_clk - input baud clock multiplyed by 8
// * i_wr - input data (byte) write signal
// * i_data - input data (byte)
// * o_txe  - output flag, new data can be uploaded
// * o_txc  - output flag, byte transmit complete
// * o_tx   - output tx pin
// ****************************************************************************
module uart_tx (
	i_rst,			  	// Module reset
	i_clk,				// System clock
	i_baud8_clk,		// Baud clock multiplyed by 8, the same as receiver
	i_wr,				// Write data strobe 
	i_data,				// Data 8-bit
	o_tx,				// USART TX pin
	o_txe,				// Tx empty flag
	o_txc				// Tx complete strobe
	);
	
input  wire i_rst;
input  wire i_clk;
input  wire i_baud8_clk;
input  wire i_wr;
input  wire [7:0]i_data;
output reg o_bsy;
output reg o_txr;	
	
output wire o_rdy;
output wire o_tx;
	
output reg o_txe;
output reg o_txc;	
	
reg [1:0]r_baud8_clk;
reg r_baud_clk_posedge;
reg [6:0]r_baud8_counter;
reg [10:0]r_data;
	
assign o_tx = r_data[0];

// Generate baud clock posedge
// It's delayed from original i_baud8_clk, by 3 cycles
// But it's doesn't metters
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		r_baud8_clk <= 2'b00;
		r_baud_clk_posedge <= 1'b0;
	end else begin
		r_baud8_clk <= { r_baud8_clk[0], i_baud8_clk };
		r_baud_clk_posedge <= ~r_baud8_clk[0] & ( r_baud8_clk[1] );
	end
end


wire baud_counter_on;
assign baud_counter_on  = ( |(r_baud8_counter) );

wire tx_start_or_data;
assign tx_start_or_data	= ( |(r_baud8_counter[6:3]) );


always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		r_baud8_counter <= 7'h00;
	end else begin
		if ( baud_counter_on ) begin
			if ( r_baud_clk_posedge ) begin
				r_baud8_counter <= r_baud8_counter + 7'h7F;
			end else begin
				r_baud8_counter <= r_baud8_counter;
			end
		end else begin
			if ( ~r_data[1] ) begin
				r_baud8_counter <= 7'h50;
			end else begin
				r_baud8_counter <= r_baud8_counter;
			end
		end
	end
end
	
reg r_txe;
reg r_txc;
reg r_txc_1ck_late;
		
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		o_bsy <= 1'b0;
		r_txe <= 1'b0;
		r_txc <= 1'b0;
		r_txc_1ck_late <= 1'b0;
		o_txe <= 1'b0;
		o_txc <= 1'b0;
	end else begin
		o_bsy  <= baud_counter_on;
		r_txe <= ~tx_start_or_data;
		o_txe <= r_txe & (~r_data[1]) & ~i_wr; // data[1] is zero if new byte is loaded
		r_txc <= ~baud_counter_on;
		r_txc_1ck_late <= r_txc;
		o_txc <= (~r_txc_1ck_late) & r_txc;
	end
end	
	
wire next_bit_strobe;
assign next_bit_strobe = (&(r_baud8_counter[2:0])) & r_baud_clk_posedge;
	
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		r_data <= 10'h3FF;
	end else begin
		if ( i_wr & r_txe ) begin
			r_data <= { 1'b1, i_data, 2'b01 };
		end else begin
			if ( next_bit_strobe ) begin
				r_data <= { 1'b1, r_data[10:1] };
			end else begin
				r_data <= r_data;
			end
		end
	end
end
	
	
endmodule
