// ----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Title      : Support clocking wrapper level for 10G Gigabit Ethernet
// Project    : 10G Gigabit Ethernet
//-----------------------------------------------------------------------------
// File       : axi_10g_ethernet_0_shared_clocking_wrapper.v
// Author     : Xilinx Inc.
//-----------------------------------------------------------------------------
// Description: This is the Shared clocking wrapper level code for the 10G
//              Gigabit Ethernet Core.  It contains the shareable clocking,
//              reset circuitry and the gt common block.
//				改动：增加refclk、refclkcopy输入，取消refclk_p/n输入
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

module axi_10g_ethernet_0_shared_clocking_wrapper_X0Y4_refclk0  (
   input          reset,
   
   input 	  	  refclk,
   input 		  refclkcopy,
   //input          refclk_p,
   //input          refclk_n,
   
   input          qpll0reset,
   input          dclk,
   input          txoutclk,
   output         txoutclk_out,
   output         coreclk,
   input  reset_tx_bufg_gt,
   output wire areset_coreclk,
   output wire areset_txusrclk2,
   output         gttxreset,
   output         gtrxreset,
   output         txuserrdy,
   output         txusrclk,
   output         txusrclk2,
   output         reset_counter_done,
   output         qpll0lock_out,
   output         qpll0outclk,
   output         qpll0outrefclk,
  // DRP signals
   input   [9:0]  gt_common_drpaddr,
   input          gt_common_drpclk,
   input   [15:0] gt_common_drpdi,
   output  [15:0] gt_common_drpdo,
   input          gt_common_drpen,
   output         gt_common_drprdy,
   input          gt_common_drpwe
   );

/*-------------------------------------------------------------------------*/

  // Signal declarations
  wire   qpll0lock;
  //wire   refclk;
  wire   counter_done;
  wire   qpllreset;

  assign qpll0lock_out          = qpll0lock;
  assign reset_counter_done     = counter_done;


  //---------------------------------------------------------------------------
  // Instantiate the 10GBASER/KR GT Common block
  //---------------------------------------------------------------------------
  axi_10g_ethernet_0_gt_common_X0Y4_refclk0 # (
      .WRAPPER_SIM_GTRESET_SPEEDUP("TRUE") ) //Does not affect hardware
  gt_common_block_i
    (
     .refclk                (refclk),
     .qpllreset             (qpllreset),
     .qpll0lock             (qpll0lock),
     .qpll0outclk           (qpll0outclk),
     .qpll0outrefclk        (qpll0outrefclk),
      // DRP signals
     .gt_common_drpaddr     (gt_common_drpaddr),
     .gt_common_drpclk      (gt_common_drpclk),
     .gt_common_drpdi       (gt_common_drpdi),
     .gt_common_drpdo       (gt_common_drpdo),
     .gt_common_drpen       (gt_common_drpen),
     .gt_common_drprdy      (gt_common_drprdy),
     .gt_common_drpwe       (gt_common_drpwe)
    );

  //---------------------------------------------------------------------------
  // Instantiate the 10GBASER/KR shared clock/reset block
  //---------------------------------------------------------------------------

  axi_10g_ethernet_0_shared_clock_and_reset ethernet_shared_clock_reset_block_i
    (
     .areset                (reset),
     .coreclk               (coreclk),
	 
	 .refclkcopy			(refclkcopy),
     //.refclk_p              (refclk_p),
     //.refclk_n              (refclk_n),
     //.refclk                (refclk),
     .txoutclk              (txoutclk),
     .qplllock              (qpll0lock),
     .qpll0reset            (qpll0reset),
     .reset_tx_bufg_gt      (reset_tx_bufg_gt),
     .areset_coreclk        (areset_coreclk),
     .areset_txusrclk2      (areset_txusrclk2),
     .gttxreset             (gttxreset),
     .gtrxreset             (gtrxreset),
     .txuserrdy             (txuserrdy),
     .txusrclk              (txusrclk),
     .txusrclk2             (txusrclk2),
     .qpllreset             (qpllreset),
     .reset_counter_done    (counter_done)
    );

endmodule
