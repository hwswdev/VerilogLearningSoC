#!/bin/bash
iverilog -o uart_tx_test.vvp uart_tx.v uart_rx.v uart_rx_test.v
vvp uart_tx_test.vvp
# gtkwave uart_tx_test.vcd

