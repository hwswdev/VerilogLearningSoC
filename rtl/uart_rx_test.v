// ***************************************************************************
// * © Evgeny Sobolev, passport 76 1375783, disallowed to copy by thirdparty
// * uart_tx_test, - UART TX module test  
// * 
// ***************************************************************************
`timescale 100ps/10ps

module uart_tx_test();

reg  r_clk;
reg  r_baud8_tx_clk;
reg  r_baud8_rx_clk;
reg  r_rst;
reg  r_wr;
reg [7:0]r_tx_data;

	
reg  r_clk2;
reg	 r_sysclk_div;
	
	
wire w_tx_bsy;
wire w_tx_line;
wire w_tx_empty;
wire w_tx_complete;
	
wire w_tx_line2;
wire w_tx_empty2;
wire w_tx_complete2;
	
wire w_rx_rdy;
wire w_rx_bsy;
wire [6:0]w_rx_cntr;
wire [7:0]w_rx_data;

initial begin
	
	$dumpfile("uart_tx_test.vcd");
	
	$dumpvars( 0, r_rst );
	$dumpvars( 1, r_clk );
	$dumpvars( 2, r_baud8_tx_clk );
	$dumpvars( 3, r_tx_data );
	$dumpvars( 4, r_wr );
	$dumpvars( 5, w_tx_empty );
	$dumpvars( 6, w_tx_complete );
	$dumpvars( 7, w_tx_line );
	$dumpvars( 2, r_baud8_rx_clk );	
	$dumpvars( 8, w_rx_rdy );
	$dumpvars( 9, w_rx_bsy );
	$dumpvars(10, w_rx_data );
	
	$dumpvars(11, r_clk2 );
	$dumpvars(12, w_tx_empty2 );
	$dumpvars(13, w_tx_complete2 );
	$dumpvars(14, w_tx_line2 );
	
	r_wr  = 1'b0;
	r_rst = 1'b0;
	r_clk = 1'b0;
	r_clk2 = 1'b0;
	r_sysclk_div = 1'b0;	
	r_baud8_rx_clk = 1'b1;
	r_baud8_tx_clk = 1'b0;

	
	r_tx_data = 8'hFF;
	#100;
	r_rst <= 1'b1;
	#60;
	r_rst <= 1'b0;
	#1000;
	r_tx_data = 8'h55;
	#60;
	r_wr = 1'b1;
	#60;
	r_wr = 1'b0;
	r_tx_data = 8'h75;
	//#7200;
	#7150;
	r_wr = 1'b1;
	#60;
	r_wr = 1'b0;
	#2500;
	r_wr = 1'b1;
	#60;
	r_wr = 1'b0;
	r_tx_data = 8'h55;
	#7500;
	r_wr = 1'b1;
	#60;
	r_wr = 1'b0;
	#7200;	
	r_tx_data = 8'h7F;
	#4000;
	r_wr = 1'b1;
	#7200;
	r_tx_data = 8'h55;
	#20000;
	r_tx_data = 8'h00;
	#10000;
	r_tx_data = 8'hFF;
	#55000;
	r_wr = 1'b0;
	#20000;
	
	
	$display("finished OK!");
	$finish;
end

always #12 begin
	r_sysclk_div <= ~r_sysclk_div;
	r_clk <= ~r_clk;
	if ( r_sysclk_div ) begin
		r_clk2 <= ~r_clk2;
	end else begin
		r_clk2 <= r_clk2;
	end
end

always #50 begin
	r_baud8_tx_clk <= ~r_baud8_tx_clk;
end
	
always #48 begin
	r_baud8_rx_clk <= ~r_baud8_rx_clk;
end


uart_tx uart_tx_inst( 
	.i_rst(r_rst),
	.i_clk(r_clk),
	.i_baud8_clk(r_baud8_tx_clk),
	.i_wr(r_wr),
	.i_data(r_tx_data),
	.o_txe(w_tx_empty),
	.o_txc(w_tx_complete),
	.o_tx(w_tx_line)
);
		
uart_rx uart_rx_inst( 
	.i_rst(r_rst),
	.i_clk(r_clk),
	.i_baud8_clk(r_baud8_rx_clk),
	.i_rx(w_tx_line),
	.o_rdy(w_rx_rdy),
	.o_data(w_rx_data),
	.o_bsy(w_rx_bsy)
	);

uart_tx uart_tx_inst2( 
	.i_rst(r_rst),
	.i_clk(r_clk2),
	.i_baud8_clk(r_baud8_tx_clk),
	.i_wr(r_wr),
	.i_data(r_tx_data),
	.o_txe(w_tx_empty2),
	.o_txc(w_tx_complete2),
	.o_tx(w_tx_line2)
);	
	

endmodule
