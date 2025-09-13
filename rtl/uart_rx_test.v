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

wire w_tx_bsy;
wire w_tx;
wire w_bit_strobe;
wire w_tx_rdy;	
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
	$dumpvars( 5, w_tx_rdy );
	$dumpvars( 6, w_tx_bsy );
	$dumpvars( 7, w_tx );
	$dumpvars( 2, r_baud8_rx_clk );	
	$dumpvars( 8, w_rx_rdy );
	$dumpvars( 9, w_rx_bsy );	
	$dumpvars(10, w_rx_data );	
	
	
	
	r_wr  = 1'b0;
	r_rst = 1'b0;
	r_clk = 1'b0;
	r_baud8_rx_clk = 1'b1;
	r_baud8_tx_clk = 1'b0;
	r_tx_data = 8'hFF;
	
	#100;
	r_rst <= 1'b1;
	#20;
	r_rst <= 1'b0;
		
	#8000;
	r_tx_data = 8'h55;
	#20;
	r_wr = 1'b1;
	#20;
	r_wr = 1'b0;

	r_tx_data = 8'hAA;
	#12000;
	r_wr = 1'b1;
	#20;
	r_wr = 1'b0;
	
	#20;	
	r_tx_data = 8'hC8;
	#4000;
	r_wr = 1'b1;
	
	#100000;
	$display("finished OK!");
	$finish;
end

always #10 begin
	r_clk <= ~r_clk;
end

always #50 begin
	r_baud8_tx_clk <= ~r_baud8_tx_clk;
end
	
always #51 begin
	r_baud8_rx_clk <= ~r_baud8_rx_clk;
end


uart_tx uart_tx_inst( 
	.i_rst(r_rst),
	.i_clk(r_clk),
	.i_baud8_clk(r_baud8_tx_clk),
	.i_wr(r_wr),
	.i_data(r_tx_data),
	.o_bsy(w_tx_bsy),
	.o_tx(w_tx),
	.o_rdy(w_tx_rdy)
	);
	
uart_rx uart_rx_inst( 
	.i_rst(r_rst),
	.i_clk(r_clk),
	.i_baud8_clk(r_baud8_rx_clk),
	.i_rx(w_tx),
	.o_rdy(w_rx_rdy),
	.o_data(w_rx_data),
	.o_bsy(w_rx_bsy)
	);

endmodule
