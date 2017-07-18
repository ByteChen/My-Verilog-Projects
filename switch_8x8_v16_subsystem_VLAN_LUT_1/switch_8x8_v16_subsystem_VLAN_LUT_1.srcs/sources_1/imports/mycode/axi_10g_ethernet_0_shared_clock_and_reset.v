// ----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Title      : Shared clocking and resets
// Project    : 10G Gigabit Ethernet
//-----------------------------------------------------------------------------
// File       : axi_10g_ethernet_0_shared_clock_and_reset.v
//-----------------------------------------------------------------------------
// Description: This file contains the
// 10GBASE-R/KR clocking and reset logic which can be shared between multiple cores。
//  改动：取消refclk_p/n输入，取消refclk输出，输入refclkcopy。
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

(* DowngradeIPIdentifiedWarnings="yes" *)
module  axi_10g_ethernet_0_shared_clock_and_reset
    (
     input  areset,
	 
	 input refclkcopy,
     //input  refclk_p,
     //input  refclk_n,
     input  qpll0reset,
     //output refclk,
	 
     input  txoutclk,
     output coreclk,
     input  qplllock,
     input  reset_tx_bufg_gt,
     output wire areset_coreclk,
     output wire areset_txusrclk2,
     output gttxreset,
     output gtrxreset,
     output reg txuserrdy = 1'b0,
     output txusrclk,
     output txusrclk2,
     output qpllreset,
     output reset_counter_done
    );

  wire coreclk_buf;
  wire qplllock_txusrclk2;
  reg [8:0] reset_counter = 9'h000;
  assign reset_counter_done = reset_counter[8];
  reg [3:0] reset_pulse = 4'b1110;
  wire gttxreset_txusrclk2;

  //wire refclkcopy;  //改为input

/*   IBUFDS_GTE3 ibufds_inst
  (
      .O       (refclk),
      .ODIV2   (refclkcopy),
      .CEB     (1'b0),
      .I     (refclk_p),
      .IB    (refclk_n)
  ); */

  BUFG_GT refclk_bufg_gt_i
  (
      .I       (refclkcopy),
      .CE      (1'b1),
      .CEMASK  (1'b1),
      .CLR     (1'b0),
      .CLRMASK (1'b1),
      .DIV     (3'b000),
      .O       (coreclk)
  );


  BUFG_GT txoutclk_bufg_gt_i
  (
      .I       (txoutclk),
      .CE      (1'b1),
      .CEMASK  (1'b1),
      .CLR     (reset_tx_bufg_gt),
      .CLRMASK (1'b0),
      .DIV     (3'b000),
      .O       (txusrclk)
  );


  assign txusrclk2 = txusrclk;

  // Asynch reset synchronizers...

  axi_10g_ethernet_0_ff_synchronizer_rst2
    #(
      .C_NUM_SYNC_REGS(5),
      .C_RVAL  (1'b1))
  areset_coreclk_sync_i
    (
     .clk      (coreclk),
     .rst      (areset),
     .data_in  (1'b0),
     .data_out (areset_coreclk)
    );

  axi_10g_ethernet_0_ff_synchronizer_rst2
    #(
      .C_NUM_SYNC_REGS(5),
      .C_RVAL(1'b1))
  areset_txusrclk2_sync_i
    (
     .clk(txusrclk2),
     .rst(areset),
     .data_in(1'b0),
     .data_out(areset_txusrclk2)
    );

  axi_10g_ethernet_0_ff_synchronizer_rst2
    #(
      .C_NUM_SYNC_REGS(5),
      .C_RVAL  (1'b0))
  qplllock_txusrclk2_sync_i
    (
     .clk      (txusrclk2),
     .rst      (!qplllock),
     .data_in  (1'b1),
     .data_out (qplllock_txusrclk2)
    );


  // Hold off the GT resets until 500ns after configuration.
  // 128 ticks at 6.4ns period will be >> 500 ns.
  // 256 ticks at the minimum possible 2.56ns period (390MHz) will be >> 500 ns.

  always @(posedge coreclk)
  begin
    if (!reset_counter[8])
      reset_counter   <=   reset_counter + 1'b1;
    else
      reset_counter   <=   reset_counter;
  end

  always @(posedge coreclk)
  begin
    if (areset_coreclk == 1'b1)
      reset_pulse   <=   4'b1110;
    else if(reset_counter[8])
      reset_pulse   <=   {1'b0, reset_pulse[3:1]};
  end

  assign   qpllreset  =     qpll0reset;
  assign   gttxreset  =     reset_pulse[0];
  assign   gtrxreset  =     reset_pulse[0];

  axi_10g_ethernet_0_ff_synchronizer_rst2
    #(
      .C_NUM_SYNC_REGS(5),
      .C_RVAL  (1'b1))
  gttxreset_txusrclk2_sync_i
    (
     .clk      (txusrclk2),
     .rst      (gttxreset),
     .data_in  (1'b0),
     .data_out (gttxreset_txusrclk2)
    );

  always @(posedge txusrclk2 or posedge gttxreset_txusrclk2)
  begin
     if(gttxreset_txusrclk2)
       txuserrdy <= 1'b0;
     else
       txuserrdy <= qplllock_txusrclk2;
  end

endmodule

