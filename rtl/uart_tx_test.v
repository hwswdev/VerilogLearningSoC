// ***************************************************************************
// * © Evgeny Sobolev, passport 76 1375783, disallowed to copy by thirdparty
// * uart_tx_test, - UART TX module test  
// * 
// ***************************************************************************
`timescale 100ps/10ps

module uart_tx_test();

reg  r_clk;
reg  r_baud8_clk;
reg  r_rst;
reg  r_wr;
wire w_bsy;
wire w_tx;
wire w_bit_strobe;

initial begin
	$dumpfile("uart_tx_test.vcd");
	$dumpvars(0, r_rst);
	$dumpvars(1, r_clk);
	$dumpvars(2, r_baud8_clk);
	$dumpvars(3, r_wr);
	$dumpvars(4, w_bsy);
	$dumpvars(5, w_tx);
	$dumpvars(6, w_bit_strobe);
	
	r_wr  = 1'b0;
	r_rst = 1'b0;
	r_clk = 1'b0;
	r_baud8_clk = 1'b0;
	
	#100;
	r_rst <= 1'b1;
	#20;
	r_rst <= 1'b0;
	
	#100;
	r_wr = 1'b1;
	#20;
	r_wr = 1'b0;

	#1000;
	r_wr = 1'b1;	
	
	#100000;
	$display("finished OK!");
	$finish;
end

always #10 begin
	r_clk <= ~r_clk;
end

always #35 begin
	r_baud8_clk <= ~r_baud8_clk;
end


uart_tx uart_tx_inst( 
	.i_rst(r_rst),
	.i_clk(r_clk),
	.i_baud8_clk(r_baud8_clk),
	.i_wr(r_wr),
	.i_data(8'h55),
	.o_bsy(w_bsy),
	.o_tx(w_tx),
	.o_bit_strobe(w_bit_strobe)
	);

endmodule
