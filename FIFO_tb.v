//******************************************************************************
//                                                                             *
// Copyright (C) 2010 Regents of the University of California.                 *
//                                                                             *
// The information contained herein is the exclusive property of the VCL       *
// group but may be used and/or modified for non-comercial purposes if the     *
// author is acknowledged.  For all other uses, permission must be attained    *
// by the VLSI Computation Lab.                                                *
//                                                                             *
// This work has been developed by members of the VLSI Computation Lab         *
// (VCL) in the Department of Electrical and Computer Engineering at           *
// the University of California at Davis.  Contact: bbaas@ece.ucdavis.edu      *
//******************************************************************************
//
// tb.vt
//
// Testbench for FIFO
//
// This module will rigorously test the FIFO module.
//
// Written by Aaron Stillmaker
// 8/13/10

// Define FIFO Address width minus 1 and Data word width minus 1

`define ADDR_WIDTH_M1 2
`define DATA_WIDTH_M1 15

`timescale 10ps/1ps
module FIFO_tb();                           
    reg reset  = 0;
    reg clk_wr = 0;
    reg clk_rd = 0;
    reg wr_en  = 0;
    reg rd_en  = 0;

    reg [`ADDR_WIDTH_M1: 0] count;
    reg [`DATA_WIDTH_M1: 0] data_in = 0;

    wire wr_request;
    wire async_empty;
    wire [`DATA_WIDTH_M1: 0] data_out;
    wire rd_request;
    wire async_full;

    // Submodule
    FIFO DUT (
    .reset      (reset),           // synchronous to read clock  --------------------------
    .clk_wr     (clk_wr),          // clock coming from write side of FIFO -- write signals
    .wr_en      (wr_en),           // write enable
    .data_in    (data_in),         // data to be written 
    .wr_request (wr_request),      // low= Full, else NOT FULL
    .async_empty(async_empty),     // true if empty, but referenced to write side
    .clk_rd     (clk_rd),          // clock coming from read side of FIFO  -- read signals 
    .rd_en      (rd_en),           // read enable
    .data_out   (data_out),        // data to be read  
    .rd_request (rd_request),      // FIFO is not empty (combinational in from 1st stage of FIFO)
    .async_full (async_full)       // true if FIFO is in reserve, but referenced to read side
    );

    // Initialization for data capture
    initial
    begin
        //$recordfile("tb");
        //$recordvars(tb);

        $dumpfile("FIFO.vcd"); 
        $dumpvars(0, FIFO_tb); 

        #0
        reset = 0;
        clk_wr = 0;
        clk_rd = 0;
        wr_en = 0;
        rd_en = 0;
        count = 0;
        data_in = 0;
         
        #201
        reset = 0;
        wr_en = 1;
        rd_en = 1;

        #40000

        #100
        $finish;
    end
  
    always @ (negedge clk_wr)
    begin
        if ((wr_request) && (wr_en))
        begin
            count = count + 1;
        end
        data_in = count;
    end

    always
        #500 clk_wr = !clk_wr;

    always
        #100 clk_rd = !clk_rd;

endmodule

