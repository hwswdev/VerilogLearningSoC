// ***************************************************************************
// * © Evgeny Sobolev, passport 76 1375783, 
// * disallowed to any type  of use by thirdparty
// * uart_tx, - UART module   
// ***************************************************************************
module uart_tx (
	i_rst,			  	// Module reset
	i_clk,				// System clock
	i_baud8_clk,		// Baud clock multiplyed by 8, the same as receiver
	i_wr,				// Write data strobe 
	i_data,				// Data 8-bit
	o_bsy,				// Means, bus is busy
	o_tx,				// USART TX pin
	o_rdy
	);
	
input  wire i_rst;
input  wire i_clk;
input  wire i_baud8_clk;
input  wire i_wr;
input  wire [7:0]i_data;
output reg o_bsy;
output reg o_rdy;
output wire o_tx;
	


reg r_wr;
reg [1:0]r_baud8_clk; 		 // i_baud8_clk, i.e. baud clock multipied by 8.
reg r_baud8_clk_posedge;	 // delayed by 3 i_clk, i_baud_clk pulse each posedge
reg r_baud8_clk_posedge_1ck; // delayed by 4 i_clk, i_baud_clk pulse each posedge
reg [2:0]r_baud8_clk_cntr;	 // decremented each r_baud8_clk_posedge, if o_bsy set
reg r_baud_clk;				 // baud clock pulses, if o_bsy set
reg [12:0]r_tx_data;		 // data, which contains { 1'b1, i_data[7:0], 2'b01 }
reg r_bsy_1ck;

	
assign o_tx = r_tx_data[0];

	
always @( posedge i_clk or posedge i_rst) begin
	if ( i_rst ) begin
		r_wr <= 1'b0;
	end else begin
		r_wr <= i_wr;
	end
end
	
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

// Divdide i_baud8_clk by 8, to get baud_clk
// baud_clk, have to be started fast as possible,
// after activation. Don't wait up to 7 i_baud8_clk
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		r_baud8_clk_cntr <= 3'h0;
	end else begin
		// LUT5, i.e. { o_bsy, r_baud8_clk_posedge, r_baud8_clk_cntr[2:0] }
		if ( o_bsy ) begin
			if ( r_baud8_clk_posedge ) begin
				r_baud8_clk_cntr <= r_baud8_clk_cntr + 3'b111; // i.e decrement counter
			end else begin
				r_baud8_clk_cntr <= r_baud8_clk_cntr;
			end
		end else begin
			r_baud8_clk_cntr <= 3'h0;
		end
	end
end

// Genreate r_baud_clk 
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		r_baud_clk <= 1'b0;
	end else begin
		// LUT4, generate baud clock on next i_baud8_clk
		r_baud_clk <= (&(r_baud8_clk_cntr)) & r_baud8_clk_posedge_1ck;
	end
end

// Make signal "o_bsy"
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		o_bsy <= 1'b0;
	end else begin
		// 3 x LUT4 + LUT3(4) ????
		o_bsy <= (|(r_tx_data[11:1])) | ( (~o_bsy) & i_wr );
		r_bsy_1ck <= o_bsy;
	end
end

// Make signal tx
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		r_tx_data <= 12'h01;
	end else begin			
		// 12 x LUT6, i.e. { i_data, r_tx_data[i], r_tx_data[i+1], i_wr, o_bsy, r_baud_clk }
		case ({ i_wr, o_bsy, r_baud_clk } )
			3'b000: r_tx_data <= 12'h01;
			3'b001: r_tx_data <= 12'h01;
			3'b100: r_tx_data <= { 2'b11, i_data, 2'b01 };
			3'b101: r_tx_data <= { 2'b11, i_data, 2'b01 };
			3'b110: r_tx_data <= r_tx_data;
			3'b010: r_tx_data <= r_tx_data;
			3'b011: r_tx_data <= { 1'b0,   r_tx_data[11:1] };
			3'b111: r_tx_data <= { 1'b0,   r_tx_data[11:1] };
		endcase
	end
end
	
// Generate tx complete signal
always @( posedge i_clk or posedge i_rst ) begin
	if ( i_rst ) begin
		o_rdy <= 1'b0;
	end else begin
		o_rdy <= (~o_bsy) & (r_bsy_1ck);		
	end
end

endmodule
