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
// FIFO.v
//
// 16-bit by 32,  dual-clock circular FIFO for interfacing at clock boundaries
//
// $Id: FIFO.v,v 1.0 7/19/2010 02:15:36 astill Exp $
// Written by: Aaron Stillmaker
//
// Origional AsAP FIFO Written by: Ryan Apperson 
// First In First Out circuitry:
// Main goal in rewriting was to have the whole FIFO in one file and not be
// AsAP specific.  I started fresh writing most code from scratch using 
// Ryan's thesis as a guide, some of code was used from his origional  
// code, and some of the new code was modeled after the origional code.
//

// Define FIFO Address width minus 1 and Data word width minus 1

`define ADDR_WIDTH_M1 2
`define DATA_WIDTH_M1 15

`timescale 10ps/1ps
`celldefine
module FIFO (
    reset,           // synchronous to read clock  --------------------------

    clk_wr,          // clock coming from write side of FIFO -- write signals
    wr_en,           // write enable
    data_in,         // data to be written  

    wr_request,      // low= Full, else NOT FULL
    async_empty,     // true if empty, but referenced to write side

    clk_rd,          // clock coming from read side of FIFO  -- read signals 
    rd_en,           // read enable
    data_out,        // data to be read  

    rd_request,      // FIFO is not empty (combinational in from 1st stage of FIFO)
    async_full      // true if FIFO is in reserve, but referenced to read side
    );


    // I/O %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    input reset;

    input clk_wr;
    input wr_en;
    input [`DATA_WIDTH_M1:0]  data_in;

    output wr_request;
    output async_empty;

    input clk_rd;
    input rd_en;
    output [`DATA_WIDTH_M1:0] data_out;  

    output rd_request;
    output async_full;

    reg [`DATA_WIDTH_M1:0] data_in_d = 0;
    reg [`DATA_WIDTH_M1:0] data_in_d = 0;

    reg [`ADDR_WIDTH_M1:0] wr_ptr = 0;
    reg [`ADDR_WIDTH_M1:0] rd_ptr = 0;
    reg [`ADDR_WIDTH_M1:0] wr_ptr_d = 0;
    reg [`ADDR_WIDTH_M1:0] rd_ptr_d = 0;
    reg wr_en_valid_d = 0;

    reg [`ADDR_WIDTH_M1:0] rd_ptr_on_wr = 0;
    reg [`ADDR_WIDTH_M1:0] wr_ptr_on_rd = 0;

    wire [`ADDR_WIDTH_M1:0] wr_ptr_next = (wr_ptr + 1);
    wire wr_request = (rd_ptr_on_wr == wr_ptr_next) ? 1'b0: 1'b1;// FIFO is full if wr_request = 0;
    wire async_empty = (rd_ptr_on_wr == wr_ptr) ? 1'b1: 1'b0;// FIFO is empty is async_empty = 0;
    wire wr_en_valid = (wr_en && wr_request);
    always @(posedge clk_wr or posedge reset)
    begin
        // Binary Incrementer %%
        // Asynchronous Communication of RD address pointer from RD side to
        //WR side %%
        if (reset)//reset address FFs
        begin
        end
	    else
        begin
            wr_ptr <= wr_ptr + wr_en_valid;
            rd_ptr_on_wr <= rd_ptr;

            // First latch the data
            wr_en_valid_d <= wr_en_valid;
            data_in_d <= data_in;
            wr_ptr_d <= wr_ptr;
        end 
    end


    // Read Logic %%%

    // Asychronous Empty Logic, used for asynchrnous wake
    
    wire [`ADDR_WIDTH_M1:0] wr_ptr_on_rd_next = (wr_ptr_on_rd + 1);
    assign rd_request = (wr_ptr_on_rd != rd_ptr);
    assign async_full = (wr_ptr_on_rd_next == (rd_ptr)) ? 1'b1: 1'b0;// FIFO is empty is async_empty = 0;
    wire rd_en_valid = (rd_en && rd_request);
    always @(posedge clk_rd)
    begin
        // Binary Incrementers %%
        if (reset)
        begin
        end
        else
        begin
            rd_ptr <= rd_ptr + rd_en_valid;
            rd_ptr_d <= rd_ptr;
            wr_ptr_on_rd <= wr_ptr_d;// make sure the data has been in the FIFO
        end

        // Register the SRAM output
//        data_out <= data_out_c;
    end

    //SRAM Memory Definition
    SRAM SRAM (
               .wr_en(wr_en_valid_d),   // write enable
               .clk_wr(clk_wr),      // clock coming from write side of FIFO
               .wr_ptr(wr_ptr_d),      // write pointer
               .data_in(data_in_d),  // data to be written into the SRAM 
               .rd_en(rd_en_valid),        // read enable
               .clk_rd(clk_rd),      // clock coming from read side of FIFO
               .rd_ptr(rd_ptr_d),      // read pointer
               .data_out(data_out) // data to be read from the SRAM
              );


endmodule
`endcelldefine


`celldefine
