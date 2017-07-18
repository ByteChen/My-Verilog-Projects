// ----------------------------------------------------------------------------
// (c) Copyright 2014 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// ----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Title      : GT Common wrapper
// Project    : 10G Gigabit Ethernet
//-----------------------------------------------------------------------------
// File       : axi_10g_ethernet_0_gt_common.v
// Author     : Xilinx Inc.
//-----------------------------------------------------------------------------
// Description: This file contains the 10GBASE-R Transceiver GT Common block.
//-----------------------------------------------------------------------------

`timescale 1ns / 1ps

module  axi_10g_ethernet_0_gt_common_X0Y8_refclk0_1 # (
  parameter WRAPPER_SIM_GTRESET_SPEEDUP = "false" ) //Does not affect hardware
    (
     input  refclk,
     input  qpllreset,
     output qpll0lock,
     output qpll0outclk,
     output qpll0outrefclk,
  // DRP signals
     input   [9:0]  gt_common_drpaddr,
     input          gt_common_drpclk,
     input   [15:0] gt_common_drpdi,
     output  [15:0] gt_common_drpdo,
     input          gt_common_drpen,
     output         gt_common_drprdy,
     input          gt_common_drpwe
    );

assign gt_common_drpdo = 0;
assign gt_common_drprdy = 0;

//***************************** Parameter Declarations ************************
    localparam QPLL_FBDIV_TOP =  66;

    localparam QPLL_FBDIV_IN  =  (QPLL_FBDIV_TOP == 16)  ? 10'b0000100000 :
            (QPLL_FBDIV_TOP == 20)  ? 10'b0000110000 :
            (QPLL_FBDIV_TOP == 32)  ? 10'b0001100000 :
            (QPLL_FBDIV_TOP == 40)  ? 10'b0010000000 :
            (QPLL_FBDIV_TOP == 64)  ? 10'b0011100000 :
            (QPLL_FBDIV_TOP == 66)  ? 10'b0101000000 :
            (QPLL_FBDIV_TOP == 80)  ? 10'b0100100000 :
            (QPLL_FBDIV_TOP == 100) ? 10'b0101110000 : 10'b0000000000;

   localparam QPLL_FBDIV_RATIO = (QPLL_FBDIV_TOP == 16)  ? 1'b1 :
            (QPLL_FBDIV_TOP == 20)  ? 1'b1 :
            (QPLL_FBDIV_TOP == 32)  ? 1'b1 :
            (QPLL_FBDIV_TOP == 40)  ? 1'b1 :
            (QPLL_FBDIV_TOP == 64)  ? 1'b1 :
            (QPLL_FBDIV_TOP == 66)  ? 1'b0 :
            (QPLL_FBDIV_TOP == 80)  ? 1'b1 :
            (QPLL_FBDIV_TOP == 100) ? 1'b1 : 1'b1;

//***************************** Wire Declarations *****************************

    // ground and vcc signals
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [63:0]  tied_to_vcc_vec_i;

//********************************* Main Body of Code**************************

    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 64'h0000000000000000;
    assign tied_to_vcc_i                = 1'b1;
    assign tied_to_vcc_vec_i            = 64'hffffffffffffffff;

  // List of signals to connect to GT Common block

  wire [2:0] GTYE3_COMMON_QPLL0REFCLKSEL;
  wire GTYE3_COMMON_QPLL0RESET;
  wire GTYE3_COMMON_QPLL0LOCK;
  wire GTYE3_COMMON_QPLL0OUTCLK;
  wire GTYE3_COMMON_QPLL0OUTREFCLK;
  
  // Connect only required internal signals to GT Common block
  assign GTYE3_COMMON_QPLL0RESET = qpllreset;
  assign qpll0lock = GTYE3_COMMON_QPLL0LOCK;
  assign qpll0outclk = GTYE3_COMMON_QPLL0OUTCLK;
  assign qpll0outrefclk = GTYE3_COMMON_QPLL0OUTREFCLK;  

  wire GTYE3_COMMON_GTNORTHREFCLK00;
  assign GTYE3_COMMON_GTNORTHREFCLK00 = refclk;
  assign GTYE3_COMMON_QPLL0REFCLKSEL = 3'b011;
  // Instantiate the 10GBASER/KR GT Common block
  axi_10g_ethernet_0_gt_common_wrapper axi_10g_ethernet_0_gt_common_wrapper_i
  (
   .GTYE3_COMMON_BGBYPASSB(1'b1),
   .GTYE3_COMMON_BGMONITORENB(1'b1),
   .GTYE3_COMMON_BGPDB(1'b1),
   .GTYE3_COMMON_BGRCALOVRD(5'b10000),
   .GTYE3_COMMON_BGRCALOVRDENB(1'b1),
   .GTYE3_COMMON_DRPADDR(10'b0000000000),
   .GTYE3_COMMON_DRPCLK(1'b0),
   .GTYE3_COMMON_DRPDI(16'b0000000000000000),
   .GTYE3_COMMON_DRPDO(),
   .GTYE3_COMMON_DRPEN(1'b0),
   .GTYE3_COMMON_DRPRDY(),
   .GTYE3_COMMON_DRPWE(1'b0),
   .GTYE3_COMMON_GTGREFCLK0(1'b0),
   .GTYE3_COMMON_GTGREFCLK1(1'b0),
   .GTYE3_COMMON_GTNORTHREFCLK00(GTYE3_COMMON_GTNORTHREFCLK00),
   .GTYE3_COMMON_GTNORTHREFCLK01(1'b0),
   .GTYE3_COMMON_GTNORTHREFCLK10(1'b0),
   .GTYE3_COMMON_GTNORTHREFCLK11(1'b0),
   .GTYE3_COMMON_GTREFCLK00(1'b0),
   .GTYE3_COMMON_GTREFCLK01(1'b0),
   .GTYE3_COMMON_GTREFCLK10(1'b0),
   .GTYE3_COMMON_GTREFCLK11(1'b0),
   .GTYE3_COMMON_GTSOUTHREFCLK00(1'b0),
   .GTYE3_COMMON_GTSOUTHREFCLK01(1'b0),
   .GTYE3_COMMON_GTSOUTHREFCLK10(1'b0),
   .GTYE3_COMMON_GTSOUTHREFCLK11(1'b0),
   .GTYE3_COMMON_PMARSVD0(8'b00000000),
   .GTYE3_COMMON_PMARSVD1(8'b00000000),
   .GTYE3_COMMON_PMARSVDOUT0(),
   .GTYE3_COMMON_PMARSVDOUT1(),
   .GTYE3_COMMON_QPLL0CLKRSVD0(1'b0),
   .GTYE3_COMMON_QPLL0FBCLKLOST(),
   .GTYE3_COMMON_QPLL0LOCK(GTYE3_COMMON_QPLL0LOCK),
   .GTYE3_COMMON_QPLL0LOCKDETCLK(1'b0),
   .GTYE3_COMMON_QPLL0LOCKEN(1'b1),
   .GTYE3_COMMON_QPLL0OUTCLK(GTYE3_COMMON_QPLL0OUTCLK),
   .GTYE3_COMMON_QPLL0OUTREFCLK(GTYE3_COMMON_QPLL0OUTREFCLK),
   .GTYE3_COMMON_QPLL0PD(1'b0),
   .GTYE3_COMMON_QPLL0REFCLKLOST(),
   .GTYE3_COMMON_QPLL0REFCLKSEL(GTYE3_COMMON_QPLL0REFCLKSEL),
   .GTYE3_COMMON_QPLL0RESET(GTYE3_COMMON_QPLL0RESET),
   .GTYE3_COMMON_QPLL1CLKRSVD0(1'b0),
   .GTYE3_COMMON_QPLL1FBCLKLOST(),
   .GTYE3_COMMON_QPLL1LOCK(),
   .GTYE3_COMMON_QPLL1LOCKDETCLK(1'b0),
   .GTYE3_COMMON_QPLL1LOCKEN(1'b0),
   .GTYE3_COMMON_QPLL1OUTCLK(),
   .GTYE3_COMMON_QPLL1OUTREFCLK(),
   .GTYE3_COMMON_QPLL1PD(1'b1),
   .GTYE3_COMMON_QPLL1REFCLKLOST(),
   .GTYE3_COMMON_QPLL1REFCLKSEL(3'b001),
   .GTYE3_COMMON_QPLL1RESET(1'b1),
   .GTYE3_COMMON_QPLLDMONITOR0(),
   .GTYE3_COMMON_QPLLDMONITOR1(),
   .GTYE3_COMMON_QPLLRSVD1(8'b00000000),
   .GTYE3_COMMON_QPLLRSVD2(5'b00000),
   .GTYE3_COMMON_QPLLRSVD3(5'b00000),
   .GTYE3_COMMON_QPLLRSVD4(8'b00000000),
   .GTYE3_COMMON_RCALENB(1'b1),
   .GTYE3_COMMON_REFCLKOUTMONITOR0(),
   .GTYE3_COMMON_REFCLKOUTMONITOR1(),
   .GTYE3_COMMON_RXRECCLK0_SEL(),
   .GTYE3_COMMON_RXRECCLK1_SEL(),
   .GTYE3_COMMON_SDM0DATA(25'b0000000000000000000000000),
   .GTYE3_COMMON_SDM0FINALOUT(),
   .GTYE3_COMMON_SDM0RESET(1'b0),
   .GTYE3_COMMON_SDM0TESTDATA(),
   .GTYE3_COMMON_SDM0WIDTH(2'b00),
   .GTYE3_COMMON_SDM1DATA(25'b0000000000000000000000000),
   .GTYE3_COMMON_SDM1FINALOUT(),
   .GTYE3_COMMON_SDM1RESET(1'b0),
   .GTYE3_COMMON_SDM1TESTDATA(),
   .GTYE3_COMMON_SDM1WIDTH(2'b00)
  );


endmodule

