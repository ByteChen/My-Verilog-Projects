//----------------------------------------------------------------------------
// Title      : switch_8x8_top
// Project    : 10G Gigabit Ethernet Switch 4x4
//-----------------------------------------------------------------------------
// File       : switch_8x8_top.v
// Author     : TongRao,ByteChen
//Email       : ByteChen@qq.com
//-----------------------------------------------------------------------------
// Description: 将switch_4x4拓展到8x8；
//              enabled VLAN；
//              增加了LUT；
//              调试：对subsystem0_rx -> fifo_0 -> LUT0 -> switch -> fifo_4 -> subsystem0_tx 这一路的所有信号进行了 mark_debug
//              使用IBUFDS_GTE3，将X0Y4所在quad的差分输入时钟refclk_p/n转为非差分时钟，提供给两个shared clock wrapper使用，解决参考时钟分叉问题。
//              简化掉非必须的代码，去除多余的注释，使简洁美观。
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module switch_top
  (
   // Clock inputs
   input             clk_in_p,       // Freerunning clock source
   input             clk_in_n,
   
   input             refclk_p,       // Transceiver reference clock source 0
   input             refclk_n,

   input             rst_n,
   
   //仿真所用的信号
   output            coreclk_out,
   input             sim_speedup_control,
   output            core_ready,

   // Serial I/O from/to transceiver
   output            txp,
   output            txn,
   input             rxp,
   input             rxn,
   
   output            txp_1,
   output            txn_1,
   input             rxp_1,
   input             rxn_1,
   
   output            txp_2,
   output            txn_2,
   input             rxp_2,
   input             rxn_2,
   
   output            txp_3,
   output            txn_3,
   input             rxp_3,
   input             rxn_3,
   
   output            txp_4,
   output            txn_4,
   input             rxp_4,
   input             rxn_4,
   
   output            txp_5,
   output            txn_5,
   input             rxp_5,
   input             rxn_5,
   
   output            txp_6,
   output            txn_6,
   input             rxp_6,
   input             rxn_6,
   
   output            txp_7,
   output            txn_7,
   input             rxp_7,
   input             rxn_7
   );
/*-------------------------------------------------------------------------*/

   // Set FIFO memory size
   localparam        FIFO_SIZE  = 1024;

   wire reset;
   assign reset = ~rst_n;

   // Signal declarations
   wire              enable_vlan;
   wire              s_axi_aclk;
   wire              tx_dcm_locked;
   wire    [79 : 0]  mac_tx_configuration_vector;
   wire    [79 : 0]  mac_rx_configuration_vector;
   wire   [2 : 0]    mac_status_vector;
   wire   [535 : 0]  pcs_pma_configuration_vector;
   wire   [447 : 0]  pcs_pma_status_vector;

   wire              tx_axis_aresetn;
   wire              rx_axis_aresetn;
   wire      [7:0]   pcspma_status;
   
   // Enable or disable VLAN mode
   assign enable_vlan = 1;

   // Assign the configuration settings to the configuration vectors
   assign mac_rx_configuration_vector = {72'd0,1'b0,4'd0,enable_vlan,2'b10};
   assign mac_tx_configuration_vector = {72'd0,1'b0,4'd0,enable_vlan,2'b10};
   assign pcs_pma_configuration_vector = {425'd0,1'b0,110'd0};
   
   //仿真时使用的core_ready
   wire              block_lock;
   wire              no_remote_and_local_faults;
   assign block_lock = pcspma_status[0];
   assign no_remote_and_local_faults = !mac_status_vector[0] && !mac_status_vector[1] ;
   assign core_ready = block_lock && no_remote_and_local_faults;

   // Combine reset sources
   assign tx_axis_aresetn  = ~reset;
   assign rx_axis_aresetn  = ~reset;
   
/*---------------------------- SIGNAL DECLARATION ---------------------------------------------*/
//mac_0's tx and rx signal
  (* mark_debug="true" *) wire         [63:0]                  tx_axis_mac_tdata;
  (* mark_debug="true" *) wire         [7:0]                   tx_axis_mac_tkeep;
  (* mark_debug="true" *) wire                                 tx_axis_mac_tvalid;
  (* mark_debug="true" *) wire                                 tx_axis_mac_tlast;
  (* mark_debug="true" *) wire                                 tx_axis_mac_tready;

  (* mark_debug="true" *) wire         [63:0]                  rx_axis_mac_tdata;
  (* mark_debug="true" *) wire         [7:0]                   rx_axis_mac_tkeep;
  (* mark_debug="true" *) wire                                 rx_axis_mac_tvalid;
  (* mark_debug="true" *) wire                                 rx_axis_mac_tuser;
  (* mark_debug="true" *) wire                                 rx_axis_mac_tlast;     
   
   //mac_1's tx and rx signal
   wire         [63:0]                  tx_axis_mac_tdata_1;
   wire         [7:0]                   tx_axis_mac_tkeep_1;
   wire                                 tx_axis_mac_tvalid_1;
   wire                                 tx_axis_mac_tlast_1;
   wire                                 tx_axis_mac_tready_1;

   wire         [63:0]                  rx_axis_mac_tdata_1;
   wire         [7:0]                   rx_axis_mac_tkeep_1;
   wire                                 rx_axis_mac_tvalid_1;
   wire                                 rx_axis_mac_tuser_1;
   wire                                 rx_axis_mac_tlast_1;
   
   //mac_2's tx and rx signal
   wire         [63:0]                  tx_axis_mac_tdata_2;
   wire         [7:0]                   tx_axis_mac_tkeep_2;
   wire                                 tx_axis_mac_tvalid_2;
   wire                                 tx_axis_mac_tlast_2;
   wire                                 tx_axis_mac_tready_2;

   wire         [63:0]                  rx_axis_mac_tdata_2;
   wire         [7:0]                   rx_axis_mac_tkeep_2;
   wire                                 rx_axis_mac_tvalid_2;
   wire                                 rx_axis_mac_tuser_2;
   wire                                 rx_axis_mac_tlast_2;
   
   //mac_3's tx and rx signal
   wire         [63:0]                  tx_axis_mac_tdata_3;
   wire         [7:0]                   tx_axis_mac_tkeep_3;
   wire                                 tx_axis_mac_tvalid_3;
   wire                                 tx_axis_mac_tlast_3;
   wire                                 tx_axis_mac_tready_3;

   wire         [63:0]                  rx_axis_mac_tdata_3;
   wire         [7:0]                   rx_axis_mac_tkeep_3;
   wire                                 rx_axis_mac_tvalid_3;
   wire                                 rx_axis_mac_tuser_3;
   wire                                 rx_axis_mac_tlast_3;
   
//fifo_0 to LUT0     //m和s是相对于fifo来说的
  (* mark_debug="true" *) wire         [63:0]                  m_switch_tdata;
  (* mark_debug="true" *) wire         [7:0]                   m_switch_tkeep;
  (* mark_debug="true" *) wire                                 m_switch_tvalid;
  (* mark_debug="true" *) wire                                 m_switch_tlast;
  (* mark_debug="true" *) wire                                 m_switch_tready;
   //wire                                 m_switch_tuser;   //此新fifo不输出tuser信号 

//fifo_1 to LUT1  
   wire         [63:0]                  m_switch_tdata_1;
   wire         [7:0]                   m_switch_tkeep_1;
   wire                                 m_switch_tvalid_1;
   wire                                 m_switch_tlast_1;
   wire                                 m_switch_tready_1;

//fifo_2 to LUT2 
   wire         [63:0]                  m_switch_tdata_2;
   wire         [7:0]                   m_switch_tkeep_2;
   wire                                 m_switch_tvalid_2;
   wire                                 m_switch_tlast_2;
   wire                                 m_switch_tready_2;
   
//fifo_3 to LUT3
   wire         [63:0]                  m_switch_tdata_3;
   wire         [7:0]                   m_switch_tkeep_3;
   wire                                 m_switch_tvalid_3;
   wire                                 m_switch_tlast_3;
   wire                                 m_switch_tready_3;
  
//LUT0 to switch
 (* mark_debug="true" *)  wire tx_axis_as_tvalid;
 (* mark_debug="true" *)  wire tx_axis_as_tlast;
 (* mark_debug="true" *)  wire tx_axis_as_tready; 
 (* mark_debug="true" *)  wire [63:0] tx_axis_as_tdata;
 (* mark_debug="true" *)  wire [7:0] tx_axis_as_tkeep;
 (* mark_debug="true" *)  wire [2:0] tx_axis_as_tdest;
 
//LUT1 to switch
   wire tx_axis_as_tvalid_1;
   wire tx_axis_as_tlast_1;
   wire tx_axis_as_tready_1; 
   wire [63:0] tx_axis_as_tdata_1;
   wire [7:0] tx_axis_as_tkeep_1;
   wire [2:0] tx_axis_as_tdest_1;   
 
//LUT2 to switch
   wire tx_axis_as_tvalid_2;
   wire tx_axis_as_tlast_2;
   wire tx_axis_as_tready_2; 
   wire [63:0] tx_axis_as_tdata_2;
   wire [7:0] tx_axis_as_tkeep_2;
   wire [2:0] tx_axis_as_tdest_2;   
 
//LUT3 to switch
   wire tx_axis_as_tvalid_3;
   wire tx_axis_as_tlast_3;
   wire tx_axis_as_tready_3; 
   wire [63:0] tx_axis_as_tdata_3;
   wire [7:0] tx_axis_as_tkeep_3;
   wire [2:0] tx_axis_as_tdest_3;
   
//switch to fifo4  
  (* mark_debug="true" *) wire         [63:0]                  s_switch_tdata;
  (* mark_debug="true" *) wire         [7:0]                   s_switch_tkeep;
  (* mark_debug="true" *) wire                                 s_switch_tvalid;
  (* mark_debug="true" *) wire                                 s_switch_tlast;
  (* mark_debug="true" *) wire                                 s_switch_tready;
   //wire                                 s_switch_tuser;
   
//switch to fifo5 
   wire         [63:0]                  s_switch_tdata_1;
   wire         [7:0]                   s_switch_tkeep_1;
   wire                                 s_switch_tvalid_1;
   wire                                 s_switch_tlast_1;
   wire                                 s_switch_tready_1;
   
//switch to fifo6 
   wire         [63:0]                  s_switch_tdata_2;
   wire         [7:0]                   s_switch_tkeep_2;
   wire                                 s_switch_tvalid_2;
   wire                                 s_switch_tlast_2;
   wire                                 s_switch_tready_2;

//switch to fifo7
   wire         [63:0]                  s_switch_tdata_3;
   wire         [7:0]                   s_switch_tkeep_3;
   wire                                 s_switch_tvalid_3;
   wire                                 s_switch_tlast_3;
   wire                                 s_switch_tready_3;

/*-----------------------在switch_4x4基础上增加的mac和fifo们的信号--------------------------------------------------*/
//mac_4's tx and rx signal
      wire         [63:0]                  tx_axis_mac_tdata_4;
      wire         [7:0]                   tx_axis_mac_tkeep_4;
      wire                                 tx_axis_mac_tvalid_4;
      wire                                 tx_axis_mac_tlast_4;
      wire                                 tx_axis_mac_tready_4;
   
      wire         [63:0]                  rx_axis_mac_tdata_4;
      wire         [7:0]                   rx_axis_mac_tkeep_4;
      wire                                 rx_axis_mac_tvalid_4;
      wire                                 rx_axis_mac_tuser_4;
      wire                                 rx_axis_mac_tlast_4;     
      
      //mac_5's tx and rx signal
      wire         [63:0]                  tx_axis_mac_tdata_5;
      wire         [7:0]                   tx_axis_mac_tkeep_5;
      wire                                 tx_axis_mac_tvalid_5;
      wire                                 tx_axis_mac_tlast_5;
      wire                                 tx_axis_mac_tready_5;
   
      wire         [63:0]                  rx_axis_mac_tdata_5;
      wire         [7:0]                   rx_axis_mac_tkeep_5;
      wire                                 rx_axis_mac_tvalid_5;
      wire                                 rx_axis_mac_tuser_5;
      wire                                 rx_axis_mac_tlast_5;
      
      //mac_6's tx and rx signal
      wire         [63:0]                  tx_axis_mac_tdata_6;
      wire         [7:0]                   tx_axis_mac_tkeep_6;
      wire                                 tx_axis_mac_tvalid_6;
      wire                                 tx_axis_mac_tlast_6;
      wire                                 tx_axis_mac_tready_6;
   
      wire         [63:0]                  rx_axis_mac_tdata_6;
      wire         [7:0]                   rx_axis_mac_tkeep_6;
      wire                                 rx_axis_mac_tvalid_6;
      wire                                 rx_axis_mac_tuser_6;
      wire                                 rx_axis_mac_tlast_6;
      
      //mac_7's tx and rx signal
      wire         [63:0]                  tx_axis_mac_tdata_7;
      wire         [7:0]                   tx_axis_mac_tkeep_7;
      wire                                 tx_axis_mac_tvalid_7;
      wire                                 tx_axis_mac_tlast_7;
      wire                                 tx_axis_mac_tready_7;
   
      wire         [63:0]                  rx_axis_mac_tdata_7;
      wire         [7:0]                   rx_axis_mac_tkeep_7;
      wire                                 rx_axis_mac_tvalid_7;
      wire                                 rx_axis_mac_tuser_7;
      wire                                 rx_axis_mac_tlast_7;
      
   // fifo_8 to LUT4     //m和s是相对于fifo来说的
      wire         [63:0]                  m_switch_tdata_4;
      wire         [7:0]                   m_switch_tkeep_4;
      wire                                 m_switch_tvalid_4;
      wire                                 m_switch_tlast_4;
      wire                                 m_switch_tready_4;
      //wire                                 m_switch_tuser; 
   
   //fifo_9 to LUT5  
      wire         [63:0]                  m_switch_tdata_5;
      wire         [7:0]                   m_switch_tkeep_5;
      wire                                 m_switch_tvalid_5;
      wire                                 m_switch_tlast_5;
      wire                                 m_switch_tready_5;
   
   //fifo_10 to LUT6 
      wire         [63:0]                  m_switch_tdata_6;
      wire         [7:0]                   m_switch_tkeep_6;
      wire                                 m_switch_tvalid_6;
      wire                                 m_switch_tlast_6;
      wire                                 m_switch_tready_6;
      
   //fifo_11 to LUT7
      wire         [63:0]                  m_switch_tdata_7;
      wire         [7:0]                   m_switch_tkeep_7;
      wire                                 m_switch_tvalid_7;
      wire                                 m_switch_tlast_7;
      wire                                 m_switch_tready_7;

//LUT4 to switch                  
   wire tx_axis_as_tvalid_4;        
   wire tx_axis_as_tlast_4;         
   wire tx_axis_as_tready_4;        
   wire [63:0] tx_axis_as_tdata_4;  
   wire [7:0] tx_axis_as_tkeep_4;   
   wire [2:0] tx_axis_as_tdest_4;   
                                  
//LUT5 to switch                  
   wire tx_axis_as_tvalid_5;      
   wire tx_axis_as_tlast_5;       
   wire tx_axis_as_tready_5;      
   wire [63:0] tx_axis_as_tdata_5;
   wire [7:0] tx_axis_as_tkeep_5; 
   wire [2:0] tx_axis_as_tdest_5; 
                                  
//LUT6 to switch                  
   wire tx_axis_as_tvalid_6;      
   wire tx_axis_as_tlast_6;       
   wire tx_axis_as_tready_6;      
   wire [63:0] tx_axis_as_tdata_6;
   wire [7:0] tx_axis_as_tkeep_6; 
   wire [2:0] tx_axis_as_tdest_6; 
                                  
//LUT7 to switch                  
   wire tx_axis_as_tvalid_7;      
   wire tx_axis_as_tlast_7;       
   wire tx_axis_as_tready_7;      
   wire [63:0] tx_axis_as_tdata_7;
   wire [7:0] tx_axis_as_tkeep_7; 
   wire [2:0] tx_axis_as_tdest_7; 

   //switch to fifo12  
      wire         [63:0]                  s_switch_tdata_4;
      wire         [7:0]                   s_switch_tkeep_4;
      wire                                 s_switch_tvalid_4;
      wire                                 s_switch_tlast_4;
      wire                                 s_switch_tready_4;
      //wire                                 s_switch_tuser;
      
   //switch to fifo13 
      wire         [63:0]                  s_switch_tdata_5;
      wire         [7:0]                   s_switch_tkeep_5;
      wire                                 s_switch_tvalid_5;
      wire                                 s_switch_tlast_5;
      wire                                 s_switch_tready_5;
      
   //switch to fifo14
      wire         [63:0]                  s_switch_tdata_6;
      wire         [7:0]                   s_switch_tkeep_6;
      wire                                 s_switch_tvalid_6;
      wire                                 s_switch_tlast_6;
      wire                                 s_switch_tready_6;
   
   //switch to fifo15
      wire         [63:0]                  s_switch_tdata_7;
      wire         [7:0]                   s_switch_tkeep_7;
      wire                                 s_switch_tvalid_7;
      wire                                 s_switch_tlast_7;
      wire                                 s_switch_tready_7;

/*-------------------------------------------------------------------------*/
  // 将差分时钟变为非差分，然后输出
  wire refclk,refclkcopy;
  IBUFDS_GTE3 ibufds_inst
  (
      .O       (refclk),
      .ODIV2   (refclkcopy),
      .CEB     (1'b0),
      .I     (refclk_p),
      .IB    (refclk_n)
  );
/*-------------------------------------------------------------------------*/
  
  wire dclk;
  
  wire txusrclk_out,txusrclk2_out,gttxreset_out,gtrxreset_out,txuserrdy_out;
  wire reset_counter_done_out;
  wire qpll0lock_out,qpll0outclk_out,qpll0outrefclk_out;
  wire areset_coreclk_out;
  wire shared_coreclk_out;
  wire reset_tx_bufg_gt;
  wire mac0_qpll0reset_out;
  wire mac0_txoutclk_out;
   
  // ?????????????? txusrclk2_out用来支持了另外3个subsystem的运行，那还能用来直接提供给fifo们做工作时钟吗？还是说assign给另一个信号，在将那个信号bufg_gt一下？
  
  //仿真时暂且使用txusrclk2_out作为总的链路传输时钟，实际前四个subsystem的是txusrclk2_out，后四个应该是txusrclk2_out_1
  assign coreclk_out = txusrclk2_out;

    //shared_clocking_wrapper_0 协同subsystem0，产生时钟给subsystem0~4使用
    axi_10g_ethernet_0_shared_clocking_wrapper_X0Y4_refclk0 shared_clocking_wrapper_0
    (
     .reset                            (reset),
     .refclk                           (refclk),
     .refclkcopy                       (refclkcopy),
     //.refclk_p                         (refclk_p),
     //.refclk_n                         (refclk_n),
     .qpll0reset                       (mac0_qpll0reset_out),
     .dclk                             (dclk),  //shared_clocking_wrapper实际上并没用处理dclk，随意随便赋个值也行，如1'b0
     .coreclk                          (shared_coreclk_out), //输出给mac们用
     .txoutclk                         (mac0_txoutclk_out),
     .txoutclk_out                     (),  //无意义的输出
     .areset_coreclk                   (areset_coreclk_out),  //输出同步到coreclk的reset信号
     .areset_txusrclk2                 (),  //无意义的输出
     .gttxreset                        (gttxreset_out),  //输出给mac
     .gtrxreset                        (gtrxreset_out),  //输出给mac  
     .txuserrdy                        (txuserrdy_out),  //输出给mac
     .txusrclk                         (txusrclk_out),   //输出给mac
     .txusrclk2                        (txusrclk2_out),  //输出给mac,是mac们的数据通路时钟，实际上内部实现中直接把assign txusrclk2 = txusrclk；
     .qpll0lock_out                    (qpll0lock_out),  //输出给mac
     .qpll0outclk                      (qpll0outclk_out),//输出给mac
     .qpll0outrefclk                   (qpll0outrefclk_out),//输出给mac
     .reset_counter_done               (reset_counter_done_out), //输出，证明reset已经保持足够长的时间
     .reset_tx_bufg_gt                 (reset_tx_bufg_gt), //输入，来自mac0,也许来自几个mac的同一信号的与或非更好
      // DRP ports
     .gt_common_drpaddr                (10'h000),
     .gt_common_drpclk                 (1'b0),
     .gt_common_drpdi                  (16'h0000),
     .gt_common_drpdo                  (),
     .gt_common_drpen                  (1'b0),
     .gt_common_drprdy                 (),
     .gt_common_drpwe                  (1'b0)
    );

  axi_10g_ethernet_0 ethernet_core_0 (
      .dclk                            (dclk),
      .coreclk                         (shared_coreclk_out),
      .txoutclk                        (mac0_txoutclk_out),
      .txusrclk                        (txusrclk_out),
      .txusrclk2                       (txusrclk2_out),
      .areset_coreclk                  (areset_coreclk_out),
      .txuserrdy                       (txuserrdy_out),
      .rxrecclk_out                    (),
      .areset                          (reset),
      .tx_resetdone                    (),
      .rx_resetdone                    (),
      .reset_counter_done              (reset_counter_done_out),
      .gttxreset                       (gttxreset_out),
      .gtrxreset                       (gtrxreset_out),
      .qpll0lock                       (qpll0lock_out),
      .qpll0outclk                     (qpll0outclk_out),
      .qpll0outrefclk                  (qpll0outrefclk_out),
      .qpll0reset                      (mac0_qpll0reset_out),
      .reset_tx_bufg_gt                (reset_tx_bufg_gt),  //output
      .tx_ifg_delay                    (8'd0),
      .tx_statistics_vector            (),
      .tx_statistics_valid             (),
      .rx_statistics_vector            (),
      .rx_statistics_valid             (),
      .s_axis_pause_tdata              (16'b0),
      .s_axis_pause_tvalid             (1'b0),

      .tx_axis_aresetn                 (tx_axis_aresetn),  //此处mac端并不需要所谓的同步复位
      .s_axis_tx_tdata                 (tx_axis_mac_tdata),
      .s_axis_tx_tvalid                (tx_axis_mac_tvalid),
      .s_axis_tx_tlast                 (tx_axis_mac_tlast),
      .s_axis_tx_tuser                 (1'b0),
      .s_axis_tx_tkeep                 (tx_axis_mac_tkeep),
      .s_axis_tx_tready                (tx_axis_mac_tready),

      .rx_axis_aresetn                 (rx_axis_aresetn),
      .m_axis_rx_tdata                 (rx_axis_mac_tdata),
      .m_axis_rx_tkeep                 (rx_axis_mac_tkeep),
      .m_axis_rx_tvalid                (rx_axis_mac_tvalid),
      .m_axis_rx_tuser                 (rx_axis_mac_tuser),
      .m_axis_rx_tlast                 (rx_axis_mac_tlast),
      
      .mac_tx_configuration_vector     (mac_tx_configuration_vector),
      .mac_rx_configuration_vector     (mac_rx_configuration_vector),
      .mac_status_vector               (mac_status_vector),
      .pcs_pma_configuration_vector    (pcs_pma_configuration_vector),
      .pcs_pma_status_vector           (pcs_pma_status_vector),


      // Serial links
      .txp                             (txp),
      .txn                             (txn),
      .rxp                             (rxp),
      .rxn                             (rxn),

      .sim_speedup_control             (sim_speedup_control),
      .signal_detect                   (1'b1),
      .tx_fault                        (1'b0),
      .tx_disable                      (),
      .pcspma_status                   (pcspma_status)
   );
  
  axi_10g_ethernet_1 ethernet_core_1 (
      .dclk                            (dclk),
      .coreclk                         (shared_coreclk_out),
      .txoutclk                        (),
      .txusrclk                        (txusrclk_out),
      .txusrclk2                       (txusrclk2_out),
      .areset_coreclk                  (areset_coreclk_out),
      .txuserrdy                       (txuserrdy_out),
      .rxrecclk_out                    (),
      .areset                          (reset),
      .tx_resetdone                    (),
      .rx_resetdone                    (),
      .reset_counter_done              (reset_counter_done_out),
      .gttxreset                       (gttxreset_out),
      .gtrxreset                       (gtrxreset_out),
      .qpll0lock                       (qpll0lock_out),
      .qpll0outclk                     (qpll0outclk_out),
      .qpll0outrefclk                  (qpll0outrefclk_out),
      .qpll0reset                      (), //output
      .reset_tx_bufg_gt                (),
      .tx_ifg_delay                    (8'd0),
      .tx_statistics_vector            (),
      .tx_statistics_valid             (),
      .rx_statistics_vector            (),
      .rx_statistics_valid             (),
      .s_axis_pause_tdata              (16'b0),
      .s_axis_pause_tvalid             (1'b0),

      .tx_axis_aresetn                 (tx_axis_aresetn),
      .s_axis_tx_tdata                 (tx_axis_mac_tdata_1),
      .s_axis_tx_tvalid                (tx_axis_mac_tvalid_1),
      .s_axis_tx_tlast                 (tx_axis_mac_tlast_1),
      .s_axis_tx_tuser                 (1'b0),
      .s_axis_tx_tkeep                 (tx_axis_mac_tkeep_1),
      .s_axis_tx_tready                (tx_axis_mac_tready_1),

      .rx_axis_aresetn                 (rx_axis_aresetn),
      .m_axis_rx_tdata                 (rx_axis_mac_tdata_1),
      .m_axis_rx_tkeep                 (rx_axis_mac_tkeep_1),
      .m_axis_rx_tvalid                (rx_axis_mac_tvalid_1),
      .m_axis_rx_tuser                 (rx_axis_mac_tuser_1),
      .m_axis_rx_tlast                 (rx_axis_mac_tlast_1),
      
      .mac_tx_configuration_vector     (mac_tx_configuration_vector),
      .mac_rx_configuration_vector     (mac_rx_configuration_vector),
      .mac_status_vector               (),
      .pcs_pma_configuration_vector    (pcs_pma_configuration_vector),
      .pcs_pma_status_vector           (),

      // Serial links
      .txp                             (txp_1),
      .txn                             (txn_1),
      .rxp                             (rxp_1),
      .rxn                             (rxn_1),

      .sim_speedup_control             (sim_speedup_control),
      .signal_detect                   (1'b1),
      .tx_fault                        (1'b0),
      .tx_disable                      (),
      .pcspma_status                   ()
   );
   
   
    axi_10g_ethernet_2 ethernet_core_2 (
       .dclk                            (dclk),
       .coreclk                         (shared_coreclk_out),
       .txoutclk                        (),
       .txusrclk                        (txusrclk_out),
       .txusrclk2                       (txusrclk2_out),
       .areset_coreclk                  (areset_coreclk_out),
       .txuserrdy                       (txuserrdy_out),
       .rxrecclk_out                    (),
       .areset                          (reset),
       .tx_resetdone                    (),
       .rx_resetdone                    (),
       .reset_counter_done              (reset_counter_done_out),
       .gttxreset                       (gttxreset_out),
       .gtrxreset                       (gtrxreset_out),
       .qpll0lock                       (qpll0lock_out),
       .qpll0outclk                     (qpll0outclk_out),
       .qpll0outrefclk                  (qpll0outrefclk_out),
       .qpll0reset                      (), //output
       .reset_tx_bufg_gt                (),
       .tx_ifg_delay                    (8'd0),
       .tx_statistics_vector            (),
       .tx_statistics_valid             (),
       .rx_statistics_vector            (),
       .rx_statistics_valid             (),
       .s_axis_pause_tdata              (16'b0),
       .s_axis_pause_tvalid             (1'b0),
 
       .tx_axis_aresetn                 (tx_axis_aresetn),
       .s_axis_tx_tdata                 (tx_axis_mac_tdata_2),
       .s_axis_tx_tvalid                (tx_axis_mac_tvalid_2),
       .s_axis_tx_tlast                 (tx_axis_mac_tlast_2),
       .s_axis_tx_tuser                 (1'b0),
       .s_axis_tx_tkeep                 (tx_axis_mac_tkeep_2),
       .s_axis_tx_tready                (tx_axis_mac_tready_2),
 
       .rx_axis_aresetn                 (rx_axis_aresetn),
       .m_axis_rx_tdata                 (rx_axis_mac_tdata_2),
       .m_axis_rx_tkeep                 (rx_axis_mac_tkeep_2),
       .m_axis_rx_tvalid                (rx_axis_mac_tvalid_2),
       .m_axis_rx_tuser                 (rx_axis_mac_tuser_2),
       .m_axis_rx_tlast                 (rx_axis_mac_tlast_2),
       
       .mac_tx_configuration_vector     (mac_tx_configuration_vector),
       .mac_rx_configuration_vector     (mac_rx_configuration_vector),
       .mac_status_vector               (),
       .pcs_pma_configuration_vector    (pcs_pma_configuration_vector),
       .pcs_pma_status_vector           (),
 
       // Serial links
       .txp                             (txp_2),
       .txn                             (txn_2),
       .rxp                             (rxp_2),
       .rxn                             (rxn_2),
 
       .sim_speedup_control             (sim_speedup_control),
       .signal_detect                   (1'b1),
       .tx_fault                        (1'b0),
       .tx_disable                      (),
       .pcspma_status                   ()
    );
    
   axi_10g_ethernet_3 ethernet_core_3 (
        .dclk                            (dclk),
        .coreclk                         (shared_coreclk_out),
        .txoutclk                        (),
        .txusrclk                        (txusrclk_out),
        .txusrclk2                       (txusrclk2_out),
        .areset_coreclk                  (areset_coreclk_out),
        .txuserrdy                       (txuserrdy_out),
        .rxrecclk_out                    (),
        .areset                          (reset),
        .tx_resetdone                    (),
        .rx_resetdone                    (),
        .reset_counter_done              (reset_counter_done_out),
        .gttxreset                       (gttxreset_out),
        .gtrxreset                       (gtrxreset_out),
        .qpll0lock                       (qpll0lock_out),
        .qpll0outclk                     (qpll0outclk_out),
        .qpll0outrefclk                  (qpll0outrefclk_out),
        .qpll0reset                      (), //output
        .reset_tx_bufg_gt                (),
        .tx_ifg_delay                    (8'd0),
        .tx_statistics_vector            (),
        .tx_statistics_valid             (),
        .rx_statistics_vector            (),
        .rx_statistics_valid             (),
        .s_axis_pause_tdata              (16'b0),
        .s_axis_pause_tvalid             (1'b0),
  
        .tx_axis_aresetn                 (tx_axis_aresetn),
        .s_axis_tx_tdata                 (tx_axis_mac_tdata_3),
        .s_axis_tx_tvalid                (tx_axis_mac_tvalid_3),
        .s_axis_tx_tlast                 (tx_axis_mac_tlast_3),
        .s_axis_tx_tuser                 (1'b0),
        .s_axis_tx_tkeep                 (tx_axis_mac_tkeep_3),
        .s_axis_tx_tready                (tx_axis_mac_tready_3),
  
        .rx_axis_aresetn                 (rx_axis_aresetn),
        .m_axis_rx_tdata                 (rx_axis_mac_tdata_3),
        .m_axis_rx_tkeep                 (rx_axis_mac_tkeep_3),
        .m_axis_rx_tvalid                (rx_axis_mac_tvalid_3),
        .m_axis_rx_tuser                 (rx_axis_mac_tuser_3),
        .m_axis_rx_tlast                 (rx_axis_mac_tlast_3),
        
        .mac_tx_configuration_vector     (mac_tx_configuration_vector),
        .mac_rx_configuration_vector     (mac_rx_configuration_vector),
        .mac_status_vector               (),
        .pcs_pma_configuration_vector    (pcs_pma_configuration_vector),
        .pcs_pma_status_vector           (),
  
        // Serial links
        .txp                             (txp_3),
        .txn                             (txn_3),
        .rxp                             (rxp_3),
        .rxn                             (rxn_3),
  
        .sim_speedup_control             (sim_speedup_control),
        .signal_detect                   (1'b1),
        .tx_fault                        (1'b0),
        .tx_disable                      (),
        .pcspma_status                   ()
     );
     
     
/*-------------------------------------------------------------------------*/
    //新增4个subsystem，shared_clocking_wrapper_1协同subsystem4，产生时钟给subsystem4~7使用
/*-------------------------------------------------------------------------*/
    wire txusrclk_out_1,txusrclk2_out_1,gttxreset_out_1,gtrxreset_out_1,txuserrdy_out_1;
    wire reset_counter_done_out_1;
    wire qpll0lock_out_1,qpll0outclk_out_1,qpll0outrefclk_out_1;
    wire areset_coreclk_out_1;
    wire areset_datapathclk_out_1;
    wire shared_coreclk_out_1;
    
    wire reset_tx_bufg_gt_1;
    wire mac4_qpll0reset_out;
    wire mac4_txoutclk_out;

    axi_10g_ethernet_0_shared_clocking_wrapper_X0Y8_refclk0_1 shared_clocking_wrapper_1
    (
     .reset                            (reset),
     .refclk                           (refclk),
     .refclkcopy                       (refclkcopy),
     //.refclk_p                         (refclk_p),
     //.refclk_n                         (refclk_n),
     .qpll0reset                       (mac4_qpll0reset_out),
     .dclk                             (dclk),  //shared_clocking_wrapper实际上并没用处理dclk，随意随便赋个值也行，如1'b0
     .coreclk                          (shared_coreclk_out_1), //输出给mac们用
     .txoutclk                         (mac4_txoutclk_out),
     .txoutclk_out                     (),  //无意义的输出
     .areset_coreclk                   (areset_coreclk_out_1),  //输出同步到coreclk的reset信号
     .areset_txusrclk2                 (),  //无意义的输出
     .gttxreset                        (gttxreset_out_1),  //输出给mac
     .gtrxreset                        (gtrxreset_out_1),  //输出给mac  
     .txuserrdy                        (txuserrdy_out_1),  //输出给mac
     .txusrclk                         (txusrclk_out_1),   //输出给mac
     .txusrclk2                        (txusrclk2_out_1),  //输出给mac,是mac们的数据通路时钟，实际上内部实现中直接把assign txusrclk2 = txusrclk；
     .qpll0lock_out                    (qpll0lock_out_1),  //输出给mac
     .qpll0outclk                      (qpll0outclk_out_1),//输出给mac
     .qpll0outrefclk                   (qpll0outrefclk_out_1),//输出给mac
     .reset_counter_done               (reset_counter_done_out_1), //输出，证明reset已经保持足够长的时间
     .reset_tx_bufg_gt                 (reset_tx_bufg_gt_1), //输入，来自mac4,也许来自几个mac的同一信号的与或非更好
      // DRP ports
     .gt_common_drpaddr                (10'h000),
     .gt_common_drpclk                 (1'b0),
     .gt_common_drpdi                  (16'h0000),
     .gt_common_drpdo                  (),
     .gt_common_drpen                  (1'b0),
     .gt_common_drprdy                 (),
     .gt_common_drpwe                  (1'b0)
    );
    
  axi_10g_ethernet_4 ethernet_core_4 (
        .dclk                            (dclk),
        .coreclk                         (shared_coreclk_out_1),
        .txoutclk                        (mac4_txoutclk_out),
        .txusrclk                        (txusrclk_out_1),
        .txusrclk2                       (txusrclk2_out_1),
        .areset_coreclk                  (areset_coreclk_out_1),
        .txuserrdy                       (txuserrdy_out_1),
        .rxrecclk_out                    (),
        .areset                          (reset),
        .tx_resetdone                    (),
        .rx_resetdone                    (),
        .reset_counter_done              (reset_counter_done_out_1),
        .gttxreset                       (gttxreset_out_1),
        .gtrxreset                       (gtrxreset_out_1),
        .qpll0lock                       (qpll0lock_out_1),
        .qpll0outclk                     (qpll0outclk_out_1),
        .qpll0outrefclk                  (qpll0outrefclk_out_1),
        .qpll0reset                      (mac4_qpll0reset_out),
        .reset_tx_bufg_gt                (reset_tx_bufg_gt_1),  //output
        .tx_ifg_delay                    (8'd0),
        .tx_statistics_vector            (),
        .tx_statistics_valid             (),
        .rx_statistics_vector            (),
        .rx_statistics_valid             (),
        .s_axis_pause_tdata              (16'b0),
        .s_axis_pause_tvalid             (1'b0),
  
        .tx_axis_aresetn                 (tx_axis_aresetn),  //此处mac端并不需要所谓的同步复位
        .s_axis_tx_tdata                 (tx_axis_mac_tdata_4),
        .s_axis_tx_tvalid                (tx_axis_mac_tvalid_4),
        .s_axis_tx_tlast                 (tx_axis_mac_tlast_4),
        .s_axis_tx_tuser                 (1'b0),
        .s_axis_tx_tkeep                 (tx_axis_mac_tkeep_4),
        .s_axis_tx_tready                (tx_axis_mac_tready_4),
  
        .rx_axis_aresetn                 (rx_axis_aresetn),
        .m_axis_rx_tdata                 (rx_axis_mac_tdata_4),
        .m_axis_rx_tkeep                 (rx_axis_mac_tkeep_4),
        .m_axis_rx_tvalid                (rx_axis_mac_tvalid_4),
        .m_axis_rx_tuser                 (rx_axis_mac_tuser_4),
        .m_axis_rx_tlast                 (rx_axis_mac_tlast_4),
        
        .mac_tx_configuration_vector     (mac_tx_configuration_vector),
        .mac_rx_configuration_vector     (mac_rx_configuration_vector),
        .mac_status_vector               (),
        .pcs_pma_configuration_vector    (pcs_pma_configuration_vector),
        .pcs_pma_status_vector           (),
  
  
        // Serial links
        .txp                             (txp_4),
        .txn                             (txn_4),
        .rxp                             (rxp_4),
        .rxn                             (rxn_4),
  
        .sim_speedup_control             (sim_speedup_control),
        .signal_detect                   (1'b1),
        .tx_fault                        (1'b0),
        .tx_disable                      (),
        .pcspma_status                   ()
     );

axi_10g_ethernet_5 ethernet_core_5 (
    .dclk                            (dclk),
    .coreclk                         (shared_coreclk_out_1),
    .txoutclk                        (),
    .txusrclk                        (txusrclk_out_1),
    .txusrclk2                       (txusrclk2_out_1),
    .areset_coreclk                  (areset_coreclk_out_1),
    .txuserrdy                       (txuserrdy_out_1),
    .rxrecclk_out                    (),
    .areset                          (reset),
    .tx_resetdone                    (),
    .rx_resetdone                    (),
    .reset_counter_done              (reset_counter_done_out_1),
    .gttxreset                       (gttxreset_out_1),
    .gtrxreset                       (gtrxreset_out_1),
    .qpll0lock                       (qpll0lock_out_1),
    .qpll0outclk                     (qpll0outclk_out_1),
    .qpll0outrefclk                  (qpll0outrefclk_out_1),
    .qpll0reset                      (), //output
    .reset_tx_bufg_gt                (),
    .tx_ifg_delay                    (8'd0),
    .tx_statistics_vector            (),
    .tx_statistics_valid             (),
    .rx_statistics_vector            (),
    .rx_statistics_valid             (),
    .s_axis_pause_tdata              (16'b0),
    .s_axis_pause_tvalid             (1'b0),

    .tx_axis_aresetn                 (tx_axis_aresetn),
    .s_axis_tx_tdata                 (tx_axis_mac_tdata_5),
    .s_axis_tx_tvalid                (tx_axis_mac_tvalid_5),
    .s_axis_tx_tlast                 (tx_axis_mac_tlast_5),
    .s_axis_tx_tuser                 (1'b0),
    .s_axis_tx_tkeep                 (tx_axis_mac_tkeep_5),
    .s_axis_tx_tready                (tx_axis_mac_tready_5),

    .rx_axis_aresetn                 (rx_axis_aresetn),
    .m_axis_rx_tdata                 (rx_axis_mac_tdata_5),
    .m_axis_rx_tkeep                 (rx_axis_mac_tkeep_5),
    .m_axis_rx_tvalid                (rx_axis_mac_tvalid_5),
    .m_axis_rx_tuser                 (rx_axis_mac_tuser_5),
    .m_axis_rx_tlast                 (rx_axis_mac_tlast_5),
    
    .mac_tx_configuration_vector     (mac_tx_configuration_vector),
    .mac_rx_configuration_vector     (mac_rx_configuration_vector),
    .mac_status_vector               (),
    .pcs_pma_configuration_vector    (pcs_pma_configuration_vector),
    .pcs_pma_status_vector           (),

    // Serial links
    .txp                             (txp_5),
    .txn                             (txn_5),
    .rxp                             (rxp_5),
    .rxn                             (rxn_5),

    .sim_speedup_control             (sim_speedup_control),
    .signal_detect                   (1'b1),
    .tx_fault                        (1'b0),
    .tx_disable                      (),
    .pcspma_status                   ()
 );
 
 
  axi_10g_ethernet_6 ethernet_core_6 (
     .dclk                            (dclk),
     .coreclk                         (shared_coreclk_out_1),
     .txoutclk                        (),
     .txusrclk                        (txusrclk_out_1),
     .txusrclk2                       (txusrclk2_out_1),
     .areset_coreclk                  (areset_coreclk_out_1),
     .txuserrdy                       (txuserrdy_out_1),
     .rxrecclk_out                    (),
     .areset                          (reset),
     .tx_resetdone                    (),
     .rx_resetdone                    (),
     .reset_counter_done              (reset_counter_done_out_1),
     .gttxreset                       (gttxreset_out_1),
     .gtrxreset                       (gtrxreset_out_1),
     .qpll0lock                       (qpll0lock_out_1),
     .qpll0outclk                     (qpll0outclk_out_1),
     .qpll0outrefclk                  (qpll0outrefclk_out_1),
     .qpll0reset                      (), //output
     .reset_tx_bufg_gt                (),
     .tx_ifg_delay                    (8'd0),
     .tx_statistics_vector            (),
     .tx_statistics_valid             (),
     .rx_statistics_vector            (),
     .rx_statistics_valid             (),
     .s_axis_pause_tdata              (16'b0),
     .s_axis_pause_tvalid             (1'b0),

     .tx_axis_aresetn                 (tx_axis_aresetn),
     .s_axis_tx_tdata                 (tx_axis_mac_tdata_6),
     .s_axis_tx_tvalid                (tx_axis_mac_tvalid_6),
     .s_axis_tx_tlast                 (tx_axis_mac_tlast_6),
     .s_axis_tx_tuser                 (1'b0),
     .s_axis_tx_tkeep                 (tx_axis_mac_tkeep_6),
     .s_axis_tx_tready                (tx_axis_mac_tready_6),

     .rx_axis_aresetn                 (rx_axis_aresetn),
     .m_axis_rx_tdata                 (rx_axis_mac_tdata_6),
     .m_axis_rx_tkeep                 (rx_axis_mac_tkeep_6),
     .m_axis_rx_tvalid                (rx_axis_mac_tvalid_6),
     .m_axis_rx_tuser                 (rx_axis_mac_tuser_6),
     .m_axis_rx_tlast                 (rx_axis_mac_tlast_6),
     
     .mac_tx_configuration_vector     (mac_tx_configuration_vector),
     .mac_rx_configuration_vector     (mac_rx_configuration_vector),
     .mac_status_vector               (),
     .pcs_pma_configuration_vector    (pcs_pma_configuration_vector),
     .pcs_pma_status_vector           (),

     // Serial links
     .txp                             (txp_6),
     .txn                             (txn_6),
     .rxp                             (rxp_6),
     .rxn                             (rxn_6),

     .sim_speedup_control             (sim_speedup_control),
     .signal_detect                   (1'b1),
     .tx_fault                        (1'b0),
     .tx_disable                      (),
     .pcspma_status                   ()
  );
  
 axi_10g_ethernet_7 ethernet_core_7 (
      .dclk                            (dclk),
      .coreclk                         (shared_coreclk_out_1),
      .txoutclk                        (),
      .txusrclk                        (txusrclk_out_1),
      .txusrclk2                       (txusrclk2_out_1),
      .areset_coreclk                  (areset_coreclk_out_1),
      .txuserrdy                       (txuserrdy_out_1),
      .rxrecclk_out                    (),
      .areset                          (reset),
      .tx_resetdone                    (),
      .rx_resetdone                    (),
      .reset_counter_done              (reset_counter_done_out_1),
      .gttxreset                       (gttxreset_out_1),
      .gtrxreset                       (gtrxreset_out_1),
      .qpll0lock                       (qpll0lock_out_1),
      .qpll0outclk                     (qpll0outclk_out_1),
      .qpll0outrefclk                  (qpll0outrefclk_out_1),
      .qpll0reset                      (), //output
      .reset_tx_bufg_gt                (),
      .tx_ifg_delay                    (8'd0),
      .tx_statistics_vector            (),
      .tx_statistics_valid             (),
      .rx_statistics_vector            (),
      .rx_statistics_valid             (),
      .s_axis_pause_tdata              (16'b0),
      .s_axis_pause_tvalid             (1'b0),

      .tx_axis_aresetn                 (tx_axis_aresetn),
      .s_axis_tx_tdata                 (tx_axis_mac_tdata_7),
      .s_axis_tx_tvalid                (tx_axis_mac_tvalid_7),
      .s_axis_tx_tlast                 (tx_axis_mac_tlast_7),
      .s_axis_tx_tuser                 (1'b0),
      .s_axis_tx_tkeep                 (tx_axis_mac_tkeep_7),
      .s_axis_tx_tready                (tx_axis_mac_tready_7),

      .rx_axis_aresetn                 (rx_axis_aresetn),
      .m_axis_rx_tdata                 (rx_axis_mac_tdata_7),
      .m_axis_rx_tkeep                 (rx_axis_mac_tkeep_7),
      .m_axis_rx_tvalid                (rx_axis_mac_tvalid_7),
      .m_axis_rx_tuser                 (rx_axis_mac_tuser_7),
      .m_axis_rx_tlast                 (rx_axis_mac_tlast_7),
      
      .mac_tx_configuration_vector     (mac_tx_configuration_vector),
      .mac_rx_configuration_vector     (mac_rx_configuration_vector),
      .mac_status_vector               (),
      .pcs_pma_configuration_vector    (pcs_pma_configuration_vector),
      .pcs_pma_status_vector           (),

      // Serial links
      .txp                             (txp_7),
      .txn                             (txn_7),
      .rxp                             (rxp_7),
      .rxn                             (rxn_7),

      .sim_speedup_control             (sim_speedup_control),
      .signal_detect                   (1'b1),
      .tx_fault                        (1'b0),
      .tx_disable                      (),
      .pcspma_status                   ()
   );

/*-------------------------------------------------------------------------*/
//下面为fifo0-7们写同步reset   
   wire mac_and_fifo_clk;                                //定义为mac与fifo之间链路的时钟,而fifo和switch之间链路的时钟是s_axi_aclk
   assign mac_and_fifo_clk = txusrclk2_out;
   wire mac_and_fifo_aresetn;  //定义为mac和fifo之间的同步复位，其中areset_datapathclk_out是同步到txusrclk2_out的reset输出
   wire switch_and_fifo_aresetn;                         //定义为同步到switch工作时钟s_axi_aclk的复位信号，低电平有效
   
   axi_10g_ethernet_0_sync_reset gen_mac_sync_aresetn (
        .reset_in                        (~reset),
        .clk                             (mac_and_fifo_clk),  
        .reset_out                       (mac_and_fifo_aresetn));
            
   axi_10g_ethernet_0_sync_reset gen_switch_sync_aresetn (
         .reset_in                        (~reset),
         .clk                             (s_axi_aclk),  
         .reset_out                       (switch_and_fifo_aresetn));
         
    //改用example design中代码的fifo模块取代axis-data-fifo IP核
    //经过对比，这个fifo能够阻止错误帧的继续传输，即根据tuser信号丢弃坏帧
    //需要包含两个module文件 axi_10g_ethernet_0_fifo_ram.v  &&  axi_10g_ethernet_0_axi_fifo.v
    //wr端 等价于原FIFO IP核的slave端，rd端 等价于master端
    axi_10g_ethernet_0_axi_fifo #(
          .FIFO_SIZE        (FIFO_SIZE),
          .IS_TX            (0)             //若是发往mac_tx端的，则 IS_TX == 1; 否则，则是从mac_rx端接收数据， IS_TX == 0
       ) axis_data_fifo_0 (
       .wr_axis_aresetn (mac_and_fifo_aresetn),
       .wr_axis_aclk    (mac_and_fifo_clk),
     
       .wr_axis_tdata   (rx_axis_mac_tdata),
       .wr_axis_tkeep   (rx_axis_mac_tkeep),
       .wr_axis_tvalid  (rx_axis_mac_tvalid),
       .wr_axis_tlast   (rx_axis_mac_tlast),
       .wr_axis_tready  (),             //考虑若fifo满了，mac继续往里发，怎么处理？
       .wr_axis_tuser   (rx_axis_mac_tuser),
     
       .rd_axis_aresetn (switch_and_fifo_aresetn),
       .rd_axis_aclk    (s_axi_aclk),
     
       .rd_axis_tdata   (m_switch_tdata),
       .rd_axis_tkeep   (m_switch_tkeep),
       .rd_axis_tvalid  (m_switch_tvalid),
       .rd_axis_tlast   (m_switch_tlast),
       .rd_axis_tready  (m_switch_tready)
       //此fifo 的 rd端无 _tuser 信号输出，不过这个信号并不必须，因此可以继续尝试
       //因为mac_rx往上层发的时候，提供过tuser信号进行过一次过滤了，从此交换机内部就不需要这步了吧
       //上两行说得不全对，此处没有tuser输出，则switch和后续fifo要作相应调整
       
       //以下两个是fifo输出的状态信号，目前用不上
       //.fifo_status     (tx_fifo_status),
       //.fifo_full       (tx_fifo_full)
       );
   
   static_look_up_table_for_8x8_switch LUT0 (
          .aclk                            (s_axi_aclk),
          .areset                          (~switch_and_fifo_aresetn),
          //.enable_custom_preamble          (1'b0),
    
          .rx_axis_tdata                   (m_switch_tdata),
          .rx_axis_tkeep                   (m_switch_tkeep),
          .rx_axis_tvalid                  (m_switch_tvalid),
          .rx_axis_tlast                   (m_switch_tlast),
          .rx_axis_tready                  (m_switch_tready),
          
          .tx_axis_tdata                   (tx_axis_as_tdata),
          .tx_axis_tkeep                   (tx_axis_as_tkeep),
          .tx_axis_tvalid                  (tx_axis_as_tvalid),
          .tx_axis_tlast                   (tx_axis_as_tlast),
          .tx_axis_tready                  (tx_axis_as_tready),
          .tx_axis_tdest                   (tx_axis_as_tdest)
       );

    axi_10g_ethernet_0_axi_fifo #(
          .FIFO_SIZE        (FIFO_SIZE),
          .IS_TX            (0)
       ) axis_data_fifo_1 (
       .wr_axis_aresetn (mac_and_fifo_aresetn),
       .wr_axis_aclk    (mac_and_fifo_clk),
     
       .wr_axis_tdata   (rx_axis_mac_tdata_1),
       .wr_axis_tkeep   (rx_axis_mac_tkeep_1),
       .wr_axis_tvalid  (rx_axis_mac_tvalid_1),
       .wr_axis_tlast   (rx_axis_mac_tlast_1),
       .wr_axis_tready  (),
       .wr_axis_tuser   (rx_axis_mac_tuser_1),
     
       .rd_axis_aresetn (switch_and_fifo_aresetn),
       .rd_axis_aclk    (s_axi_aclk),
     
       .rd_axis_tdata   (m_switch_tdata_1),
       .rd_axis_tkeep   (m_switch_tkeep_1),
       .rd_axis_tvalid  (m_switch_tvalid_1),
       .rd_axis_tlast   (m_switch_tlast_1),
       .rd_axis_tready  (m_switch_tready_1)
       );
       
   static_look_up_table_for_8x8_switch LUT1 (
      .aclk                            (s_axi_aclk),
      .areset                          (~switch_and_fifo_aresetn),
      //.enable_custom_preamble          (1'b0),

      .rx_axis_tdata                   (m_switch_tdata_1),
      .rx_axis_tkeep                   (m_switch_tkeep_1),
      .rx_axis_tvalid                  (m_switch_tvalid_1),
      .rx_axis_tlast                   (m_switch_tlast_1),
      .rx_axis_tready                  (m_switch_tready_1),
      
      .tx_axis_tdata                   (tx_axis_as_tdata_1),
      .tx_axis_tkeep                   (tx_axis_as_tkeep_1),
      .tx_axis_tvalid                  (tx_axis_as_tvalid_1),
      .tx_axis_tlast                   (tx_axis_as_tlast_1),
      .tx_axis_tready                  (tx_axis_as_tready_1),
      .tx_axis_tdest                   (tx_axis_as_tdest_1)
   );
       
    axi_10g_ethernet_0_axi_fifo #(
         .FIFO_SIZE        (FIFO_SIZE),
         .IS_TX            (0)            
      ) axis_data_fifo_2 (
      .wr_axis_aresetn (mac_and_fifo_aresetn),
      .wr_axis_aclk    (mac_and_fifo_clk),
    
      .wr_axis_tdata   (rx_axis_mac_tdata_2),
      .wr_axis_tkeep   (rx_axis_mac_tkeep_2),
      .wr_axis_tvalid  (rx_axis_mac_tvalid_2),
      .wr_axis_tlast   (rx_axis_mac_tlast_2),
      .wr_axis_tready  (),             
      .wr_axis_tuser   (rx_axis_mac_tuser_2),
    
      .rd_axis_aresetn (switch_and_fifo_aresetn),
      .rd_axis_aclk    (s_axi_aclk),
    
      .rd_axis_tdata   (m_switch_tdata_2),
      .rd_axis_tkeep   (m_switch_tkeep_2),
      .rd_axis_tvalid  (m_switch_tvalid_2),
      .rd_axis_tlast   (m_switch_tlast_2),
      .rd_axis_tready  (m_switch_tready_2)
      );
      
    static_look_up_table_for_8x8_switch LUT2 (
      .aclk                            (s_axi_aclk),
      .areset                          (~switch_and_fifo_aresetn),
      //.enable_custom_preamble          (1'b0),

      .rx_axis_tdata                   (m_switch_tdata_2),
      .rx_axis_tkeep                   (m_switch_tkeep_2),
      .rx_axis_tvalid                  (m_switch_tvalid_2),
      .rx_axis_tlast                   (m_switch_tlast_2),
      .rx_axis_tready                  (m_switch_tready_2),
    
      .tx_axis_tdata                   (tx_axis_as_tdata_2),
      .tx_axis_tkeep                   (tx_axis_as_tkeep_2),
      .tx_axis_tvalid                  (tx_axis_as_tvalid_2),
      .tx_axis_tlast                   (tx_axis_as_tlast_2),
      .tx_axis_tready                  (tx_axis_as_tready_2),
      .tx_axis_tdest                   (tx_axis_as_tdest_2)
 );
      
    axi_10g_ethernet_0_axi_fifo #(
           .FIFO_SIZE        (FIFO_SIZE),
           .IS_TX            (0)             
        ) axis_data_fifo_3 (
        .wr_axis_aresetn (mac_and_fifo_aresetn),
        .wr_axis_aclk    (mac_and_fifo_clk),
      
        .wr_axis_tdata   (rx_axis_mac_tdata_3),
        .wr_axis_tkeep   (rx_axis_mac_tkeep_3),
        .wr_axis_tvalid  (rx_axis_mac_tvalid_3),
        .wr_axis_tlast   (rx_axis_mac_tlast_3),
        .wr_axis_tready  (),             
        .wr_axis_tuser   (rx_axis_mac_tuser_3),
      
        .rd_axis_aresetn (switch_and_fifo_aresetn),
        .rd_axis_aclk    (s_axi_aclk),
      
        .rd_axis_tdata   (m_switch_tdata_3),
        .rd_axis_tkeep   (m_switch_tkeep_3),
        .rd_axis_tvalid  (m_switch_tvalid_3),
        .rd_axis_tlast   (m_switch_tlast_3),
        .rd_axis_tready  (m_switch_tready_3)
        );
        
    static_look_up_table_for_8x8_switch LUT3 (
       .aclk                            (s_axi_aclk),
       .areset                          (~switch_and_fifo_aresetn),
       //.enable_custom_preamble          (1'b0),
 
       .rx_axis_tdata                   (m_switch_tdata_3),
       .rx_axis_tkeep                   (m_switch_tkeep_3),
       .rx_axis_tvalid                  (m_switch_tvalid_3),
       .rx_axis_tlast                   (m_switch_tlast_3),
       .rx_axis_tready                  (m_switch_tready_3),
       
       .tx_axis_tdata                   (tx_axis_as_tdata_3),
       .tx_axis_tkeep                   (tx_axis_as_tkeep_3),
       .tx_axis_tvalid                  (tx_axis_as_tvalid_3),
       .tx_axis_tlast                   (tx_axis_as_tlast_3),
       .tx_axis_tready                  (tx_axis_as_tready_3),
       .tx_axis_tdest                   (tx_axis_as_tdest_3)
    );

    /*
    //对于switch出来之后的fifo，需要定义一些辅助信号
    //由于fifo0-fifo3在输出数据到switch时，已经不发送tuser信号了，因此switch出来的信号中也没有tuser，或者说tuser状态是X；但是，
    //switch出来之后的fifo4-fifo7是需要接收tuser信号的，若tuser为X，则认为是坏帧，丢弃；所以需要给fifo2 fifo3一个有效的tuser信号，
    //这个信号用对应的tlast信号来赋值是合理的，即假设交换机内部的帧都是好帧。
    */
    axi_10g_ethernet_0_axi_fifo #(
          .FIFO_SIZE        (FIFO_SIZE),
          .IS_TX            (1)
       ) axis_data_fifo_4 (
       .wr_axis_aresetn (switch_and_fifo_aresetn),
       .wr_axis_aclk    (s_axi_aclk),
     
       .wr_axis_tdata   (s_switch_tdata),
       .wr_axis_tkeep   (s_switch_tkeep),
       .wr_axis_tvalid  (s_switch_tvalid),
       .wr_axis_tlast   (s_switch_tlast),
       .wr_axis_tready  (s_switch_tready),
       .wr_axis_tuser   (s_switch_tlast),
     
       .rd_axis_aresetn (mac_and_fifo_aresetn),
       .rd_axis_aclk    (mac_and_fifo_clk),
     
       .rd_axis_tdata   (tx_axis_mac_tdata),
       .rd_axis_tkeep   (tx_axis_mac_tkeep),
       .rd_axis_tvalid  (tx_axis_mac_tvalid),
       .rd_axis_tlast   (tx_axis_mac_tlast),
       .rd_axis_tready  (tx_axis_mac_tready)
       );
    
    axi_10g_ethernet_0_axi_fifo #(
          .FIFO_SIZE        (FIFO_SIZE),
          .IS_TX            (1)
       ) axis_data_fifo_5 (
       .wr_axis_aresetn (switch_and_fifo_aresetn),
       .wr_axis_aclk    (s_axi_aclk),
     
       .wr_axis_tdata   (s_switch_tdata_1),
       .wr_axis_tkeep   (s_switch_tkeep_1),
       .wr_axis_tvalid  (s_switch_tvalid_1),
       .wr_axis_tlast   (s_switch_tlast_1),
       .wr_axis_tready  (s_switch_tready_1),
       //.wr_axis_tuser   (s_switch_tuser_1),  //初次仿真，前面直到fifo3的收端都有数据，但是发端无数据，应该是tuser问题，令其等于tlast试试，即认为每个到这里的帧都是好帧
       .wr_axis_tuser  (s_switch_tlast_1),
       
       .rd_axis_aresetn (mac_and_fifo_aresetn),
       .rd_axis_aclk    (mac_and_fifo_clk),
     
       .rd_axis_tdata   (tx_axis_mac_tdata_1),
       .rd_axis_tkeep   (tx_axis_mac_tkeep_1),
       .rd_axis_tvalid  (tx_axis_mac_tvalid_1),
       .rd_axis_tlast   (tx_axis_mac_tlast_1),
       .rd_axis_tready  (tx_axis_mac_tready_1)
       );
       
   axi_10g_ethernet_0_axi_fifo #(
         .FIFO_SIZE        (FIFO_SIZE),
         .IS_TX            (1)
      ) axis_data_fifo_6 (
      .wr_axis_aresetn (switch_and_fifo_aresetn),
      .wr_axis_aclk    (s_axi_aclk),
    
      .wr_axis_tdata   (s_switch_tdata_2),
      .wr_axis_tkeep   (s_switch_tkeep_2),
      .wr_axis_tvalid  (s_switch_tvalid_2),
      .wr_axis_tlast   (s_switch_tlast_2),
      .wr_axis_tready  (s_switch_tready_2),
      .wr_axis_tuser   (s_switch_tlast_2),
    
      .rd_axis_aresetn (mac_and_fifo_aresetn),
      .rd_axis_aclk    (mac_and_fifo_clk),
    
      .rd_axis_tdata   (tx_axis_mac_tdata_2),
      .rd_axis_tkeep   (tx_axis_mac_tkeep_2),
      .rd_axis_tvalid  (tx_axis_mac_tvalid_2),
      .rd_axis_tlast   (tx_axis_mac_tlast_2),
      .rd_axis_tready  (tx_axis_mac_tready_2)
      );
      
    axi_10g_ethernet_0_axi_fifo #(
        .FIFO_SIZE        (FIFO_SIZE),
        .IS_TX            (1)
     ) axis_data_fifo_7 (
     .wr_axis_aresetn (switch_and_fifo_aresetn),
     .wr_axis_aclk    (s_axi_aclk),
   
     .wr_axis_tdata   (s_switch_tdata_3),
     .wr_axis_tkeep   (s_switch_tkeep_3),
     .wr_axis_tvalid  (s_switch_tvalid_3),
     .wr_axis_tlast   (s_switch_tlast_3),
     .wr_axis_tready  (s_switch_tready_3),
     .wr_axis_tuser   (s_switch_tlast_3),
   
     .rd_axis_aresetn (mac_and_fifo_aresetn),
     .rd_axis_aclk    (mac_and_fifo_clk),
   
     .rd_axis_tdata   (tx_axis_mac_tdata_3),
     .rd_axis_tkeep   (tx_axis_mac_tkeep_3),
     .rd_axis_tvalid  (tx_axis_mac_tvalid_3),
     .rd_axis_tlast   (tx_axis_mac_tlast_3),
     .rd_axis_tready  (tx_axis_mac_tready_3)
     );
     
/*-------------------------------------------------------------------------*/
//下面新增fifo 8-15，提供给subsystem4-7使用
/*-------------------------------------------------------------------------*/
//下面为fifo8-15们写同步reset   
   wire mac_and_fifo_clk_1;                             //定义为mac与fifo之间链路的时钟,而fifo和switch之间链路的时钟是s_axi_aclk
   assign mac_and_fifo_clk_1 = txusrclk2_out_1;
   wire mac_and_fifo_aresetn_1;                         //定义为mac和fifo之间的同步复位
//   wire switch_and_fifo_aresetn_1;                      //定义为switch和fifo之间链路的同步复位；不用这个信号了，因为和switch_and_fifo_aresetn是一样的。
   
   axi_10g_ethernet_0_sync_reset gen_mac_sync_aresetn_1 (
        .reset_in                        (~reset),
        .clk                             (mac_and_fifo_clk_1),  
        .reset_out                       (mac_and_fifo_aresetn_1));
    
//   axi_10g_ethernet_0_sync_reset gen_switch_sync_aresetn_1 (
//         .reset_in                        (~reset),
//         .clk                             (s_axi_aclk),  
//         .reset_out                       (switch_and_fifo_aresetn_1));
         
    axi_10g_ethernet_0_axi_fifo #(
          .FIFO_SIZE        (FIFO_SIZE),
          .IS_TX            (0)            
       ) axis_data_fifo_8 (
       .wr_axis_aresetn (mac_and_fifo_aresetn_1),
       .wr_axis_aclk    (mac_and_fifo_clk_1),
     
       .wr_axis_tdata   (rx_axis_mac_tdata_4),
       .wr_axis_tkeep   (rx_axis_mac_tkeep_4),
       .wr_axis_tvalid  (rx_axis_mac_tvalid_4),
       .wr_axis_tlast   (rx_axis_mac_tlast_4),
       .wr_axis_tready  (),             
       .wr_axis_tuser   (rx_axis_mac_tuser_4),
     
       .rd_axis_aresetn (switch_and_fifo_aresetn),
       .rd_axis_aclk    (s_axi_aclk),
     
       .rd_axis_tdata   (m_switch_tdata_4),
       .rd_axis_tkeep   (m_switch_tkeep_4),
       .rd_axis_tvalid  (m_switch_tvalid_4),
       .rd_axis_tlast   (m_switch_tlast_4),
       .rd_axis_tready  (m_switch_tready_4)
       );
       
    static_look_up_table_for_8x8_switch LUT4 (
        .aclk                            (s_axi_aclk),
        .areset                          (~switch_and_fifo_aresetn),
        //.enable_custom_preamble          (1'b0),
        .rx_axis_tdata                   (m_switch_tdata_4),
        .rx_axis_tkeep                   (m_switch_tkeep_4),
        .rx_axis_tvalid                  (m_switch_tvalid_4),
        .rx_axis_tlast                   (m_switch_tlast_4),
        .rx_axis_tready                  (m_switch_tready_4),
        
        .tx_axis_tdata                   (tx_axis_as_tdata_4),
        .tx_axis_tkeep                   (tx_axis_as_tkeep_4),
        .tx_axis_tvalid                  (tx_axis_as_tvalid_4),
        .tx_axis_tlast                   (tx_axis_as_tlast_4),
        .tx_axis_tready                  (tx_axis_as_tready_4),
        .tx_axis_tdest                   (tx_axis_as_tdest_4)
     );
  
    axi_10g_ethernet_0_axi_fifo #(
          .FIFO_SIZE        (FIFO_SIZE),
          .IS_TX            (0)
       ) axis_data_fifo_9 (
       .wr_axis_aresetn (mac_and_fifo_aresetn_1),
       .wr_axis_aclk    (mac_and_fifo_clk_1),
     
       .wr_axis_tdata   (rx_axis_mac_tdata_5),
       .wr_axis_tkeep   (rx_axis_mac_tkeep_5),
       .wr_axis_tvalid  (rx_axis_mac_tvalid_5),
       .wr_axis_tlast   (rx_axis_mac_tlast_5),
       .wr_axis_tready  (),
       .wr_axis_tuser   (rx_axis_mac_tuser_5),
     
       .rd_axis_aresetn (switch_and_fifo_aresetn),
       .rd_axis_aclk    (s_axi_aclk),
     
       .rd_axis_tdata   (m_switch_tdata_5),
       .rd_axis_tkeep   (m_switch_tkeep_5),
       .rd_axis_tvalid  (m_switch_tvalid_5),
       .rd_axis_tlast   (m_switch_tlast_5),
       .rd_axis_tready  (m_switch_tready_5)
       );
       
    static_look_up_table_for_8x8_switch LUT5 (
       .aclk                            (s_axi_aclk),
       .areset                          (~switch_and_fifo_aresetn),
       //.enable_custom_preamble          (1'b0),
       .rx_axis_tdata                   (m_switch_tdata_5),
       .rx_axis_tkeep                   (m_switch_tkeep_5),
       .rx_axis_tvalid                  (m_switch_tvalid_5),
       .rx_axis_tlast                   (m_switch_tlast_5),
       .rx_axis_tready                  (m_switch_tready_5),
       
       .tx_axis_tdata                   (tx_axis_as_tdata_5),
       .tx_axis_tkeep                   (tx_axis_as_tkeep_5),
       .tx_axis_tvalid                  (tx_axis_as_tvalid_5),
       .tx_axis_tlast                   (tx_axis_as_tlast_5),
       .tx_axis_tready                  (tx_axis_as_tready_5),
       .tx_axis_tdest                   (tx_axis_as_tdest_5)
  );
       
    axi_10g_ethernet_0_axi_fifo #(
         .FIFO_SIZE        (FIFO_SIZE),
         .IS_TX            (0)            
      ) axis_data_fifo_10 (
      .wr_axis_aresetn (mac_and_fifo_aresetn_1),
      .wr_axis_aclk    (mac_and_fifo_clk_1),
    
      .wr_axis_tdata   (rx_axis_mac_tdata_6),
      .wr_axis_tkeep   (rx_axis_mac_tkeep_6),
      .wr_axis_tvalid  (rx_axis_mac_tvalid_6),
      .wr_axis_tlast   (rx_axis_mac_tlast_6),
      .wr_axis_tready  (),             
      .wr_axis_tuser   (rx_axis_mac_tuser_6),
    
      .rd_axis_aresetn (switch_and_fifo_aresetn),
      .rd_axis_aclk    (s_axi_aclk),
    
      .rd_axis_tdata   (m_switch_tdata_6),
      .rd_axis_tkeep   (m_switch_tkeep_6),
      .rd_axis_tvalid  (m_switch_tvalid_6),
      .rd_axis_tlast   (m_switch_tlast_6),
      .rd_axis_tready  (m_switch_tready_6)
      );
      
    static_look_up_table_for_8x8_switch LUT6 (
      .aclk                            (s_axi_aclk),
      .areset                          (~switch_and_fifo_aresetn),
     // .enable_custom_preamble          (1'b0),
      .rx_axis_tdata                   (m_switch_tdata_6),
      .rx_axis_tkeep                   (m_switch_tkeep_6),
      .rx_axis_tvalid                  (m_switch_tvalid_6),
      .rx_axis_tlast                   (m_switch_tlast_6),
      .rx_axis_tready                  (m_switch_tready_6),
      
      .tx_axis_tdata                   (tx_axis_as_tdata_6),
      .tx_axis_tkeep                   (tx_axis_as_tkeep_6),
      .tx_axis_tvalid                  (tx_axis_as_tvalid_6),
      .tx_axis_tlast                   (tx_axis_as_tlast_6),
      .tx_axis_tready                  (tx_axis_as_tready_6),
      .tx_axis_tdest                   (tx_axis_as_tdest_6)
    );
      
    axi_10g_ethernet_0_axi_fifo #(
           .FIFO_SIZE        (FIFO_SIZE),
           .IS_TX            (0)             
        ) axis_data_fifo_11 (
        .wr_axis_aresetn (mac_and_fifo_aresetn_1),
        .wr_axis_aclk    (mac_and_fifo_clk_1),
      
        .wr_axis_tdata   (rx_axis_mac_tdata_7),
        .wr_axis_tkeep   (rx_axis_mac_tkeep_7),
        .wr_axis_tvalid  (rx_axis_mac_tvalid_7),
        .wr_axis_tlast   (rx_axis_mac_tlast_7),
        .wr_axis_tready  (),             
        .wr_axis_tuser   (rx_axis_mac_tuser_7),
      
        .rd_axis_aresetn (switch_and_fifo_aresetn),
        .rd_axis_aclk    (s_axi_aclk),
      
        .rd_axis_tdata   (m_switch_tdata_7),
        .rd_axis_tkeep   (m_switch_tkeep_7),
        .rd_axis_tvalid  (m_switch_tvalid_7),
        .rd_axis_tlast   (m_switch_tlast_7),
        .rd_axis_tready  (m_switch_tready_7)
        );
        
     static_look_up_table_for_8x8_switch LUT7 (
        .aclk                            (s_axi_aclk),
        .areset                          (~switch_and_fifo_aresetn),
        //.enable_custom_preamble          (1'b0),
        .rx_axis_tdata                   (m_switch_tdata_7),
        .rx_axis_tkeep                   (m_switch_tkeep_7),
        .rx_axis_tvalid                  (m_switch_tvalid_7),
        .rx_axis_tlast                   (m_switch_tlast_7),
        .rx_axis_tready                  (m_switch_tready_7),
        
        .tx_axis_tdata                   (tx_axis_as_tdata_7),
        .tx_axis_tkeep                   (tx_axis_as_tkeep_7),
        .tx_axis_tvalid                  (tx_axis_as_tvalid_7),
        .tx_axis_tlast                   (tx_axis_as_tlast_7),
        .tx_axis_tready                  (tx_axis_as_tready_7),
        .tx_axis_tdest                   (tx_axis_as_tdest_7)
    );

    axi_10g_ethernet_0_axi_fifo #(
          .FIFO_SIZE        (FIFO_SIZE),
          .IS_TX            (1)
       ) axis_data_fifo_12 (
       .wr_axis_aresetn (switch_and_fifo_aresetn),
       .wr_axis_aclk    (s_axi_aclk),
     
       .wr_axis_tdata   (s_switch_tdata_4),
       .wr_axis_tkeep   (s_switch_tkeep_4),
       .wr_axis_tvalid  (s_switch_tvalid_4),
       .wr_axis_tlast   (s_switch_tlast_4),
       .wr_axis_tready  (s_switch_tready_4),
       .wr_axis_tuser   (s_switch_tlast_4),
     
       .rd_axis_aresetn (mac_and_fifo_aresetn_1),
       .rd_axis_aclk    (mac_and_fifo_clk_1),
     
       .rd_axis_tdata   (tx_axis_mac_tdata_4),
       .rd_axis_tkeep   (tx_axis_mac_tkeep_4),
       .rd_axis_tvalid  (tx_axis_mac_tvalid_4),
       .rd_axis_tlast   (tx_axis_mac_tlast_4),
       .rd_axis_tready  (tx_axis_mac_tready_4)
       );

    axi_10g_ethernet_0_axi_fifo #(
          .FIFO_SIZE        (FIFO_SIZE),
          .IS_TX            (1)
       ) axis_data_fifo_13 (
       .wr_axis_aresetn (switch_and_fifo_aresetn),
       .wr_axis_aclk    (s_axi_aclk),
     
       .wr_axis_tdata   (s_switch_tdata_5),
       .wr_axis_tkeep   (s_switch_tkeep_5),
       .wr_axis_tvalid  (s_switch_tvalid_5),
       .wr_axis_tlast   (s_switch_tlast_5),
       .wr_axis_tready  (s_switch_tready_5),
       .wr_axis_tuser  (s_switch_tlast_5),
       
       .rd_axis_aresetn (mac_and_fifo_aresetn_1),
       .rd_axis_aclk    (mac_and_fifo_clk_1),
     
       .rd_axis_tdata   (tx_axis_mac_tdata_5),
       .rd_axis_tkeep   (tx_axis_mac_tkeep_5),
       .rd_axis_tvalid  (tx_axis_mac_tvalid_5),
       .rd_axis_tlast   (tx_axis_mac_tlast_5),
       .rd_axis_tready  (tx_axis_mac_tready_5)
       );

   axi_10g_ethernet_0_axi_fifo #(
         .FIFO_SIZE        (FIFO_SIZE),
         .IS_TX            (1)
      ) axis_data_fifo_14 (
      .wr_axis_aresetn (switch_and_fifo_aresetn),
      .wr_axis_aclk    (s_axi_aclk),
    
      .wr_axis_tdata   (s_switch_tdata_6),
      .wr_axis_tkeep   (s_switch_tkeep_6),
      .wr_axis_tvalid  (s_switch_tvalid_6),
      .wr_axis_tlast   (s_switch_tlast_6),
      .wr_axis_tready  (s_switch_tready_6),
      .wr_axis_tuser   (s_switch_tlast_6),
    
      .rd_axis_aresetn (mac_and_fifo_aresetn_1),
      .rd_axis_aclk    (mac_and_fifo_clk_1),
    
      .rd_axis_tdata   (tx_axis_mac_tdata_6),
      .rd_axis_tkeep   (tx_axis_mac_tkeep_6),
      .rd_axis_tvalid  (tx_axis_mac_tvalid_6),
      .rd_axis_tlast   (tx_axis_mac_tlast_6),
      .rd_axis_tready  (tx_axis_mac_tready_6)
      );

    axi_10g_ethernet_0_axi_fifo #(
        .FIFO_SIZE        (FIFO_SIZE),
        .IS_TX            (1)
     ) axis_data_fifo_15 (
     .wr_axis_aresetn (switch_and_fifo_aresetn),
     .wr_axis_aclk    (s_axi_aclk),
   
     .wr_axis_tdata   (s_switch_tdata_7),
     .wr_axis_tkeep   (s_switch_tkeep_7),
     .wr_axis_tvalid  (s_switch_tvalid_7),
     .wr_axis_tlast   (s_switch_tlast_7),
     .wr_axis_tready  (s_switch_tready_7),
     .wr_axis_tuser   (s_switch_tlast_7),
   
     .rd_axis_aresetn (mac_and_fifo_aresetn_1),
     .rd_axis_aclk    (mac_and_fifo_clk_1),
   
     .rd_axis_tdata   (tx_axis_mac_tdata_7),
     .rd_axis_tkeep   (tx_axis_mac_tkeep_7),
     .rd_axis_tvalid  (tx_axis_mac_tvalid_7),
     .rd_axis_tlast   (tx_axis_mac_tlast_7),
     .rd_axis_tready  (tx_axis_mac_tready_7)
     );
     
/*-------------------------------------------------------------------------*/
//接下来是switch结构
/*-------------------------------------------------------------------------*/
   axis_switch_0 axis_switch_0 (
     .aclk(s_axi_aclk),               
     .aresetn(switch_and_fifo_aresetn),   
     
     .s_axis_tvalid({ tx_axis_as_tvalid_7, tx_axis_as_tvalid_6, tx_axis_as_tvalid_5, tx_axis_as_tvalid_4, tx_axis_as_tvalid_3, tx_axis_as_tvalid_2, tx_axis_as_tvalid_1, tx_axis_as_tvalid}), 
     .s_axis_tdata({ tx_axis_as_tdata_7, tx_axis_as_tdata_6, tx_axis_as_tdata_5, tx_axis_as_tdata_4, tx_axis_as_tdata_3, tx_axis_as_tdata_2, tx_axis_as_tdata_1, tx_axis_as_tdata}),    
     .s_axis_tready({ tx_axis_as_tready_7, tx_axis_as_tready_6, tx_axis_as_tready_5, tx_axis_as_tready_4 ,tx_axis_as_tready_3, tx_axis_as_tready_2, tx_axis_as_tready_1, tx_axis_as_tready}),
     .s_axis_tkeep({ tx_axis_as_tkeep_7, tx_axis_as_tkeep_6, tx_axis_as_tkeep_5, tx_axis_as_tkeep_4, tx_axis_as_tkeep_3, tx_axis_as_tkeep_2, tx_axis_as_tkeep_1, tx_axis_as_tkeep}),  
     .s_axis_tlast({ tx_axis_as_tlast_7, tx_axis_as_tlast_6, tx_axis_as_tlast_5, tx_axis_as_tlast_4, tx_axis_as_tlast_3, tx_axis_as_tlast_2, tx_axis_as_tlast_1, tx_axis_as_tlast}),  
     
     .s_axis_tdest({tx_axis_as_tdest_7, tx_axis_as_tdest_6, tx_axis_as_tdest_5,tx_axis_as_tdest_4, tx_axis_as_tdest_3, tx_axis_as_tdest_2, tx_axis_as_tdest_1,tx_axis_as_tdest}),   
      
     .m_axis_tvalid({ s_switch_tvalid_7, s_switch_tvalid_6, s_switch_tvalid_5, s_switch_tvalid_4,s_switch_tvalid_3, s_switch_tvalid_2, s_switch_tvalid_1, s_switch_tvalid}), 
     .m_axis_tready({ s_switch_tready_7, s_switch_tready_6, s_switch_tready_5, s_switch_tready_4,s_switch_tready_3, s_switch_tready_2, s_switch_tready_1, s_switch_tready}), 
     .m_axis_tdata({ s_switch_tdata_7, s_switch_tdata_6, s_switch_tdata_5, s_switch_tdata_4,s_switch_tdata_3, s_switch_tdata_2, s_switch_tdata_1, s_switch_tdata}),    
     .m_axis_tkeep({ s_switch_tkeep_7, s_switch_tkeep_6, s_switch_tkeep_5, s_switch_tkeep_4,s_switch_tkeep_3, s_switch_tkeep_2, s_switch_tkeep_1, s_switch_tkeep}),    
     .m_axis_tlast({ s_switch_tlast_7, s_switch_tlast_6, s_switch_tlast_5, s_switch_tlast_4,s_switch_tlast_3, s_switch_tlast_2, s_switch_tlast_1, s_switch_tlast})     
     //.m_axis_tuser({ s_switch_tuser_1, s_switch_tuser})   
  );

    //--------------------------------------------------------------------------
    // Instantiate the SWITCH/DRPCLK Clock source module
    //--------------------------------------------------------------------------

    axi_10g_ethernet_0_clocking axi_lite_clocking_i (
      .clk_in_p                        (clk_in_p),
      .clk_in_n                        (clk_in_n),
      .s_axi_aclk                      (s_axi_aclk),
      .dclk                            (dclk),
      .tx_mmcm_reset                   (reset),
      .tx_mmcm_locked                  (tx_dcm_locked)
    );  //s_axi_aclk作为switch的工作时钟  

endmodule
