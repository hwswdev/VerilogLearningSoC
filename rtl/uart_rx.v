// ***************************************************************************
// * © Evgeny Sobolev, passport 76 1375783, 
// * disallowed to any type  of use by thirdparty
// * uart_rx, - UART module   
// ***************************************************************************

module uart_rx (
	i_rst,			  	// Module reset
	i_clk,				// System clock
	i_baud8_clk,		// Baud clock multiplyed by 8, the same as receiver
	i_rx,				// RX input pin
	o_data,				// Data 8-bit
	o_rdy,				// Means, bus is busy
	o_bsy
	);

input  wire i_rst;
input  wire i_clk;
input  wire i_baud8_clk;
input  wire i_rx;
output wire [7:0]o_data;
output reg o_rdy;
output wire o_bsy;

reg [1:0]r_baud8_clk; 		 // i_baud8_clk, i.e. baud clock multipied by 8.
reg r_baud8_clk_posedge;	 // delayed by 3 i_clk, i_baud_clk pulse each posedge
reg r_baud8_clk_posedge_1ck; // delayed by 4 i_clk, i_baud_clk pulse each posedge	
	
reg [1:0]rx_shift_reg;
reg rx_bit_edge;
reg [6:0]r_rx_cnt;
reg rx_processing;
reg rx_processing_1ck;
reg r_rx_bit_strobe;
reg [9:0]r_rx_data;
reg [7:0]r_o_data;
	
assign o_bsy  = (rx_processing & rx_processing_1ck);
assign o_data = r_o_data;
			
// Shift i_baud8_clk into r_baud8_clk[1:0]
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		r_baud8_clk[1:0] <= 2'b00;
	end else begin
		// Shift data from i_baud8_clk
		r_baud8_clk[1:0] <= { r_baud8_clk[0], i_baud8_clk };
	end
end	

// Generate posedge of i_baud8_clk, single i_clk duration
// Signal r_baud8_clk_posedge is shifted by 3 i_clk clock signal
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		r_baud8_clk_posedge <= 1'b0;
		r_baud8_clk_posedge_1ck <= 1'b0;
	end else begin
		r_baud8_clk_posedge <= (~r_baud8_clk[1]) & r_baud8_clk[0];
		r_baud8_clk_posedge_1ck <= r_baud8_clk_posedge;
	end
end
	
// Get USART rx line stream
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		rx_shift_reg <= 8'b0;
	end else begin
		rx_shift_reg <= { rx_shift_reg[0], i_rx };
	end
end

// Make USART edge detection
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		rx_bit_edge <= 1'b0;
	end else begin
		rx_bit_edge <= (rx_shift_reg[1]) & (~rx_shift_reg[0]);
	end
end

wire w_rx_start;
assign w_rx_start = (rx_bit_edge & (~rx_processing));
	
// Read USART bit
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		rx_processing <= 1'b0;
		rx_processing_1ck <= 1'b0;
		r_rx_cnt <= 7'h00;
	end else begin
		rx_processing <= ( rx_processing & (|(r_rx_cnt[6:0]))) | w_rx_start;
		rx_processing_1ck <= rx_processing;
		if ( rx_processing ) begin
			if ( r_baud8_clk_posedge ) begin
				r_rx_cnt <= r_rx_cnt + 7'h7F;
			end else begin
				r_rx_cnt <= r_rx_cnt;
			end
		end	else begin
			if ( w_rx_start ) begin
				r_rx_cnt <= 7'h4C;
			end else begin
				r_rx_cnt <= r_rx_cnt;
			end
		end
	end
end
	

always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		r_rx_bit_strobe <= 1'b0;
	end else begin
		r_rx_bit_strobe <= ( (~r_rx_cnt[2]) & (~r_rx_cnt[1]) & (r_rx_cnt[0]) ) & r_baud8_clk_posedge_1ck;
	end
end
	
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		r_rx_data <= 10'h00;
	end else begin
		if ( r_rx_bit_strobe ) begin
			r_rx_data <= { i_rx, r_rx_data[9:1] };
		end else begin
			r_rx_data <= r_rx_data;
		end
	end
end
	
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		r_o_data <= 1'b0;
	end else begin
		if ( rx_processing_1ck & (~rx_processing) ) begin
			r_o_data <= r_rx_data[8:1];
		end else begin
			r_o_data <= r_o_data;
		end
	end
end	
	
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		o_rdy <= 1'b0;
	end else begin
		o_rdy <= rx_processing_1ck & (~rx_processing);
	end
	
end

endmodule


