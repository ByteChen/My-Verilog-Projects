//----------------------------------------------------------------------
// Title      : static_look_up_table_for_4x4_switch
// Project    : 10G Gigabit Ethernet
//----------------------------------------------------------------------
// File       : static_look_up_table_for_4x4_switch.v
// Author     : ByteChen
//----------------------------------------------------------------------
// Description: static_look_up_table for 4x4 switch.
//----------------------------------------------------------------------
/*
`timescale 1ps / 1ps

module static_look_up_table_for_4x4_switch (
  input              aclk,
  input              areset,
  input              enable_custom_preamble,
  //input              address_swap_enable,
  input       [63:0] rx_axis_tdata,
  input       [7:0]  rx_axis_tkeep,
  input              rx_axis_tlast,
  input              rx_axis_tvalid,
  output             rx_axis_tready,
  output      [63:0] tx_axis_tdata,
  output      [7:0]  tx_axis_tkeep,
  output             tx_axis_tlast,
  output             tx_axis_tvalid,
  input              tx_axis_tready,
  
  output      [1:0]  tx_axis_tdest
 );


  localparam  IDLE        = 0,
              PREAMBLE    = 1,
              ADDR        = 2,
              TLAST_SEEN  = 3;
              
  localparam  DEST_ADDR0 = 48'h010203040506,  //if frame's destination address is DEST_ADDR0, then route it to PORT1
              DEST_ADDR1 = 48'h060504030201,  //similarly,	DEST_ADDR1 --> PORT0
              DEST_ADDR2 = 48'ha0a0a0a0a0a0,  //similarly,	DEST_ADDR2 --> PORT3
              DEST_ADDR3 = 48'hb1b1b1b1b1b1;  //similarly,	DEST_ADDR3 --> PORT2
			  
  localparam  PORT0 = 2'b00,
              PORT1 = 2'b01,
              PORT2 = 2'b10,
              PORT3 = 2'b11;			  


  reg  [1:0]   state;
  //-------------------------------------------------------------------
  //-- internal signals used in this design example.
  //-------------------------------------------------------------------

  // two state fifo state machine
  reg          data_stored_n;

  // single register in Local Link data path
  reg  [63:0]  rx_axis_tdata_out_reg;
  reg  [63:0]  tx_data_in;
  reg  [63:0]  tx_axis_tdata_out;
  reg  [31:0]  rx_axis_tdata_out_reg_reg;
  reg  [7:0]   rx_axis_tkeep_reg;
  reg  [7:0]   tx_axis_tkeep_out;
  reg          rx_sof_n_reg;
  reg          rx_sof_n_reg_reg;
  reg          rx_axis_tlast_reg;
  reg          rx_axis_tvalid_reg;


  wire         axis_data_beat;

  reg          tx_axis_tlast_out;
  reg          tx_axis_tvalid_reg;
  reg          tx_axis_tvalid_out;


  //--------------------------------------------------------------------
  // State machine to determine Start Of Frame
  //--------------------------------------------------------------------
  always @(posedge aclk)
  begin
     if (areset) begin
        state <= IDLE;
        rx_sof_n_reg <= 0;
     end
     else begin
        case (state)
           IDLE : begin
              if (rx_axis_tvalid & rx_axis_tkeep != 0 & enable_custom_preamble & tx_axis_tready) begin
                 state <= PREAMBLE;
              end
              else if (rx_axis_tvalid & rx_axis_tkeep != 0 & !enable_custom_preamble & tx_axis_tready) begin
                 rx_sof_n_reg <= 1;
                 state <= ADDR;
              end
           end
           PREAMBLE : begin
              if (rx_axis_tvalid & rx_axis_tkeep != 0 & tx_axis_tready) begin
                 rx_sof_n_reg <= 1;
              end
              state <= ADDR;
           end
           ADDR : begin
            rx_sof_n_reg <= 0;
            if (rx_axis_tvalid & rx_axis_tlast & tx_axis_tready) begin
               state <= TLAST_SEEN;
            end
           end
           TLAST_SEEN : begin
              if (rx_axis_tvalid & rx_axis_tkeep != 0 & enable_custom_preamble & tx_axis_tready) begin
                 state <= PREAMBLE;
              end
              else if (rx_axis_tvalid & rx_axis_tkeep != 0 & !enable_custom_preamble & tx_axis_tready) begin
                 rx_sof_n_reg <= 1;
                 state <= ADDR;
              end
           end
        endcase
     end
  end

  assign axis_data_beat = rx_axis_tvalid & tx_axis_tready;

  always @(posedge aclk)
  begin
    if (areset) begin
       rx_axis_tdata_out_reg     <= 32'b0;
       rx_axis_tkeep_reg         <= 8'b0;
       rx_sof_n_reg_reg          <= 1'b0;
       rx_axis_tlast_reg         <= 1'b0;
       rx_axis_tdata_out_reg_reg <= 64'b0;
       data_stored_n             <= 1'b0;
       rx_axis_tvalid_reg        <= 1'b0;
    end
    else begin
       rx_axis_tvalid_reg <= rx_axis_tvalid;
       rx_axis_tlast_reg  <= 1'b0;
       if (axis_data_beat) begin
          data_stored_n         <= 1'b1;
          rx_axis_tdata_out_reg <= rx_axis_tdata;
          rx_axis_tkeep_reg     <= rx_axis_tkeep;
          rx_sof_n_reg_reg      <= rx_sof_n_reg;
          rx_axis_tlast_reg     <= rx_axis_tlast;
          rx_axis_tdata_out_reg_reg <= rx_axis_tdata_out_reg[47:16];
       end
       else if (!axis_data_beat && rx_axis_tlast_reg) begin
          rx_axis_tlast_reg     <= rx_axis_tlast_reg;
          data_stored_n         <= 1'b0;
       end
    end
  end


  //--------------------------------------------------------------------
  // Output to Tx
  //--------------------------------------------------------------------

  // address swap following new SOF
//  always @(rx_sof_n_reg or rx_axis_tdata_out_reg or rx_axis_tdata
//           or rx_sof_n_reg_reg or rx_axis_tdata_out_reg_reg)
//  begin
//    if (rx_sof_n_reg)
//      tx_data_in <= {rx_axis_tdata_out_reg[15:0], //第二个8B的低16位
//                     rx_axis_tdata[31:0],  //第二个8B的低32位
//                     rx_axis_tdata_out_reg[63:48]};  //第一个8B的高16位
//    else if (rx_sof_n_reg_reg)
//      tx_data_in <= {rx_axis_tdata_out_reg[63:32], 
//                     rx_axis_tdata_out_reg_reg};    //第一个8B的[47:16]位？
//    else
//      tx_data_in <= rx_axis_tdata_out_reg;
//  end
  
  //试试上面经过这样改是不是就不交换地址了=>是的呢！
  always @(rx_sof_n_reg or rx_axis_tdata_out_reg or rx_axis_tdata
           or rx_sof_n_reg_reg or rx_axis_tdata_out_reg_reg)
  begin
    if (rx_sof_n_reg)
      tx_data_in <= rx_axis_tdata_out_reg;
    else if (rx_sof_n_reg_reg)
      tx_data_in <= rx_axis_tdata_out_reg;
    else
      tx_data_in <= rx_axis_tdata_out_reg;
  end

  reg [47:0] DA;
  reg [1:0] tdest;
  always @(posedge aclk)
  begin
     if (areset) begin
        DA <= DEST_ADDR0;
        tdest <= 2'b00;
        end
  end
  //reg flag;
  always @(rx_sof_n_reg)  //不能加posedge，不然仿真不对
  begin
//    if(areset)
//    begin
//      //look_up_finished <= 1'b0;
//      tdest <= PORT0;
//      //flag <= 1'b0;
//    end
    
//    if(rx_sof_n_reg)
//    begin
//        DA <= rx_axis_tdata_out_reg[47:0];
//        case (DA)
//          DEST_ADDR0:
//            begin
//              //look_up_finished <= 1'b1;
//              tdest <= PORT1;
//              //flag <= 1'b0;
//            end
//          DEST_ADDR1:
//            begin
//              tdest <= PORT0;
//              //flag <= 1'b0;
//            end
//          DEST_ADDR2:
//            begin
//              tdest <= PORT3;
//              //flag <= 1'b0;
//            end
//          DEST_ADDR3:
//            begin
//              tdest <= PORT2;
//              //flag <= 1'b0;
//            end
//        endcase
//    end
    if(rx_sof_n_reg)
        DA <= rx_axis_tdata_out_reg[47:0];
    case (DA)
          DEST_ADDR0:
            begin
              //look_up_finished <= 1'b1;
              tdest <= PORT1;
              //flag <= 1'b0;
            end
          DEST_ADDR1:
            begin
              tdest <= PORT0;
              //flag <= 1'b0;
            end
          DEST_ADDR2:
            begin
              tdest <= PORT3;
              //flag <= 1'b0;
            end
          DEST_ADDR3:
            begin
              tdest <= PORT2;
              //flag <= 1'b0;
            end
        endcase
  end

  assign tx_axis_tdest = tdest;

  always @(posedge aclk) begin
     if (areset) begin
        tx_axis_tdata_out <= 64'b0;
        tx_axis_tkeep_out <= 8'b0;
        tx_axis_tvalid_out <= 1'b0;
        tx_axis_tvalid_reg <= 1'b0;
        tx_axis_tlast_out <= 1'b0;
     end
     else begin
        if (tx_axis_tready) begin
           tx_axis_tdata_out  <= tx_data_in;
           tx_axis_tkeep_out  <= rx_axis_tkeep_reg;
           tx_axis_tvalid_reg <= axis_data_beat;
           tx_axis_tvalid_out <= tx_axis_tvalid_reg;
           tx_axis_tlast_out  <= rx_axis_tlast_reg;
        end
     end
  end

//  assign tx_axis_tvalid = (address_swap_enable) ? tx_axis_tvalid_out : rx_axis_tvalid;
//  assign tx_axis_tdata  = (address_swap_enable) ? tx_axis_tdata_out : rx_axis_tdata;
//  assign tx_axis_tkeep  = (address_swap_enable) ? tx_axis_tkeep_out : rx_axis_tkeep;
//  assign tx_axis_tlast  = (address_swap_enable) ? (tx_axis_tlast_out & tx_axis_tready & tx_axis_tvalid_out) : rx_axis_tlast;
  
  //改一下，从而取消address_swap_enable输入，并简化.TO DO:上面的所有逻辑和交换地址不相关的，实际上也可以考虑简化掉。
  assign tx_axis_tvalid = tx_axis_tvalid_out;
  assign tx_axis_tdata  = tx_axis_tdata_out;
  assign tx_axis_tkeep  = tx_axis_tkeep_out; 
  assign tx_axis_tlast  = (tx_axis_tlast_out & tx_axis_tready & tx_axis_tvalid_out);
  
  assign rx_axis_tready = tx_axis_tready;

endmodule
*/






//++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// This is version 2
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++
`timescale 1ps / 1ps

module static_look_up_table_for_8x8_switch (
  input              aclk,
  input              areset,
  //input              enable_custom_preamble,
  //input              address_swap_enable,
  input       [63:0] rx_axis_tdata,
  input       [7:0]  rx_axis_tkeep,
  input              rx_axis_tlast,
  input              rx_axis_tvalid,
  output             rx_axis_tready,
  output   reg   [63:0] tx_axis_tdata,
  output   reg   [7:0]  tx_axis_tkeep,
  output   reg          tx_axis_tlast,
  output   reg          tx_axis_tvalid,
  input                 tx_axis_tready,
  
  output      [2:0]  tx_axis_tdest
 );

  wire   enable_custom_preamble;
  assign enable_custom_preamble = 1'b0;
              
  localparam  DEST_ADDR0 = 48'h000000000001,  //if frame's destination address is DEST_ADDR0, then route it to PORT1
              DEST_ADDR1 = 48'h000000000002,  //similarly,	DEST_ADDR1 --> PORT0
              DEST_ADDR2 = 48'h000000000003,  //similarly,	DEST_ADDR2 --> PORT3
              DEST_ADDR3 = 48'h000000000004,  //similarly,	DEST_ADDR3 --> PORT2
			  DEST_ADDR4 = 48'h000000000005,
			  DEST_ADDR5 = 48'h000000000006,
			  DEST_ADDR6 = 48'h000000000007,
			  DEST_ADDR7 = 48'h000000000008;
  localparam  PORT0 = 3'b000,
              PORT1 = 3'b001,
              PORT2 = 3'b010,
              PORT3 = 3'b011,			  
			  PORT4 = 3'b100,
			  PORT5 = 3'b101,
			  PORT6 = 3'B110,
			  PORT7 = 3'b111;		  


reg done ;



//辅助判断帧开始标识
always @(posedge aclk or posedge areset) begin
  if (areset) begin
    // reset
    done <= 1'b1 ;
  end
  else if (rx_axis_tlast == 1'b1) begin
    done <= 1'b1 ;
  end
  else if (rx_axis_tvalid == 1'b1) begin
    done <= 1'b0 ;
  end
end

reg [2:0] tx_axis_tdest_reg;
always @(posedge aclk or posedge areset) begin
  if (areset) begin
    // reset
    tx_axis_tdest_reg <= 3'b0 ;
  end
  else if (done == 1'b1 && rx_axis_tvalid == 1'b1) begin
    case (rx_axis_tdata[48:0])             //此处提取mac地址并判断输出端口号，需注意mac地址高低位顺序
        DEST_ADDR0: 
            tx_axis_tdest_reg <= PORT0;
			
        DEST_ADDR1: 
            tx_axis_tdest_reg <= PORT1;
			
        DEST_ADDR2:
            tx_axis_tdest_reg <= PORT2;
			
        DEST_ADDR3:
            tx_axis_tdest_reg <= PORT3;
			
		DEST_ADDR4:
            tx_axis_tdest_reg <= PORT4;
			
		DEST_ADDR5:
            tx_axis_tdest_reg <= PORT5;
			
		DEST_ADDR6:
            tx_axis_tdest_reg <= PORT6;
			
		DEST_ADDR7:
			tx_axis_tdest_reg <= PORT7;
		
    endcase
    end
end

assign tx_axis_tdest = tx_axis_tdest_reg;

always @(posedge aclk or posedge areset) begin
  if (areset) begin
    // reset
      tx_axis_tdata  <= 'b0 ;
      tx_axis_tkeep  <= 'b0 ;
      tx_axis_tlast  <= 'b0 ;
      tx_axis_tvalid <= 'b0 ;
  end
  else if (tx_axis_tready == 1'b1) begin //如果ready为0，中断数据的传递
    tx_axis_tdata  <= rx_axis_tdata ;
    tx_axis_tkeep  <= rx_axis_tkeep ;
    tx_axis_tlast  <= rx_axis_tlast ;
    tx_axis_tvalid <= rx_axis_tvalid ;
  end
end
  
  assign rx_axis_tready = tx_axis_tready;

endmodule


//+++++++++++++++++++++++++++++++++++++++++++++
// Next is v3
//+++++++++++++++++++++++++++++++++++++++++++++

/* `timescale 1ps / 1ps
module static_look_up_table_for_4x4_switch (
  input              aclk,
  input              areset,
  input              enable_custom_preamble,
  //input              address_swap_enable,
  input       [63:0] rx_axis_tdata,
  input       [7:0]  rx_axis_tkeep,
  input              rx_axis_tlast,
  input              rx_axis_tvalid,
  output             rx_axis_tready,
  output      [63:0] tx_axis_tdata,
  output      [7:0]  tx_axis_tkeep,
  output             tx_axis_tlast,
  output             tx_axis_tvalid,
  input              tx_axis_tready,
  
  output      [1:0]  tx_axis_tdest
 );


  localparam  IDLE        = 0,
              PREAMBLE    = 1,
              ADDR        = 2,
              TLAST_SEEN  = 3;
              
  localparam  DEST_ADDR0 = 48'h010203040506,  //if frame's destination address is DEST_ADDR0, then route it to PORT1
              DEST_ADDR1 = 48'h060504030201,  //similarly,	DEST_ADDR1 --> PORT0
              DEST_ADDR2 = 48'ha0a0a0a0a0a0,  //similarly,	DEST_ADDR2 --> PORT3
              DEST_ADDR3 = 48'hb1b1b1b1b1b1;  //similarly,	DEST_ADDR3 --> PORT2
			  
  localparam  PORT0 = 2'b00,
              PORT1 = 2'b01,
              PORT2 = 2'b10,
              PORT3 = 2'b11;			  


  reg  [1:0]   state;
  //-------------------------------------------------------------------
  //-- internal signals used in this design example.
  //-------------------------------------------------------------------

  // two state fifo state machine
  reg          data_stored_n;

  // single register in Local Link data path
  reg  [63:0]  rx_axis_tdata_out_reg;
  reg  [63:0]  tx_data_in;
  reg  [63:0]  tx_axis_tdata_out;
  reg  [31:0]  rx_axis_tdata_out_reg_reg;
  reg  [7:0]   rx_axis_tkeep_reg;
  reg  [7:0]   tx_axis_tkeep_out;
  reg          rx_sof_n_reg;
  reg          rx_sof_n_reg_reg;
  reg          rx_axis_tlast_reg;
  reg          rx_axis_tvalid_reg;


  wire         axis_data_beat;

  reg          tx_axis_tlast_out;
  reg          tx_axis_tvalid_reg;
  reg          tx_axis_tvalid_out;


  //--------------------------------------------------------------------
  // State machine to determine Start Of Frame
  //--------------------------------------------------------------------
  always @(posedge aclk)
  begin
     if (areset) begin
        state <= IDLE;
        rx_sof_n_reg <= 0;
     end
     else begin
        case (state)
           IDLE : begin
              if (rx_axis_tvalid & rx_axis_tkeep != 0 & enable_custom_preamble & tx_axis_tready) begin
                 state <= PREAMBLE;
              end
              else if (rx_axis_tvalid & rx_axis_tkeep != 0 & !enable_custom_preamble & tx_axis_tready) begin
                 rx_sof_n_reg <= 1;
                 state <= ADDR;
              end
           end
           PREAMBLE : begin
              if (rx_axis_tvalid & rx_axis_tkeep != 0 & tx_axis_tready) begin
                 rx_sof_n_reg <= 1;
              end
              state <= ADDR;
           end
           ADDR : begin
            rx_sof_n_reg <= 0;
            if (rx_axis_tvalid & rx_axis_tlast & tx_axis_tready) begin
               state <= TLAST_SEEN;
            end
           end
           TLAST_SEEN : begin
              if (rx_axis_tvalid & rx_axis_tkeep != 0 & enable_custom_preamble & tx_axis_tready) begin
                 state <= PREAMBLE;
              end
              else if (rx_axis_tvalid & rx_axis_tkeep != 0 & !enable_custom_preamble & tx_axis_tready) begin
                 rx_sof_n_reg <= 1;
                 state <= ADDR;
              end
           end
        endcase
     end
  end

  assign axis_data_beat = rx_axis_tvalid & tx_axis_tready;

  always @(posedge aclk)
  begin
    if (areset) begin
       rx_axis_tdata_out_reg     <= 32'b0;
       rx_axis_tkeep_reg         <= 8'b0;
       rx_sof_n_reg_reg          <= 1'b0;
       rx_axis_tlast_reg         <= 1'b0;
       rx_axis_tdata_out_reg_reg <= 64'b0;
       data_stored_n             <= 1'b0;
       rx_axis_tvalid_reg        <= 1'b0;
    end
    else begin
       rx_axis_tvalid_reg <= rx_axis_tvalid;
       rx_axis_tlast_reg  <= 1'b0;
       if (axis_data_beat) begin
          data_stored_n         <= 1'b1;
          rx_axis_tdata_out_reg <= rx_axis_tdata;
          rx_axis_tkeep_reg     <= rx_axis_tkeep;
          rx_sof_n_reg_reg      <= rx_sof_n_reg;
          rx_axis_tlast_reg     <= rx_axis_tlast;
          rx_axis_tdata_out_reg_reg <= rx_axis_tdata_out_reg[47:16];
       end
       else if (!axis_data_beat && rx_axis_tlast_reg) begin
          rx_axis_tlast_reg     <= rx_axis_tlast_reg;
          data_stored_n         <= 1'b0;
       end
    end
  end


  //--------------------------------------------------------------------
  // Output to Tx
  //--------------------------------------------------------------------
  //试试上面经过这样改是不是就不交换地址了=>是的呢！
  always @(rx_sof_n_reg or rx_axis_tdata_out_reg or rx_axis_tdata
           or rx_sof_n_reg_reg or rx_axis_tdata_out_reg_reg)
  begin
    if (rx_sof_n_reg)
      tx_data_in <= rx_axis_tdata_out_reg;
    else if (rx_sof_n_reg_reg)
      tx_data_in <= rx_axis_tdata_out_reg;
    else
      tx_data_in <= rx_axis_tdata_out_reg;
  end

  reg [47:0] DA;
  reg [1:0] tdest;
  always @(posedge aclk or areset)
  begin
     if (areset) begin
        DA <= DEST_ADDR0;
        tdest <= 2'b00;
        end
     else if(rx_sof_n_reg == 1'b1) begin
         DA <= rx_axis_tdata_out_reg[47:0];
         case (DA)
               DEST_ADDR0:
                 begin
                   tdest <= PORT0;
                 end
               DEST_ADDR1:
                 begin
                   tdest <= PORT1;
                 end
               DEST_ADDR2:
                 begin
                   tdest <= PORT2;
                 end
               DEST_ADDR3:
                 begin
                   tdest <= PORT3;
                 end
             endcase
       end
     end
//  always @(rx_sof_n_reg)  //不能加posedge，不然仿真不对
//  begin
////    if(areset)
////    begin
////      //look_up_finished <= 1'b0;
////      tdest <= PORT0;
////      //flag <= 1'b0;
////    end
    
////    if(rx_sof_n_reg)
////    begin
////        DA <= rx_axis_tdata_out_reg[47:0];
////        case (DA)
////          DEST_ADDR0:
////            begin
////              //look_up_finished <= 1'b1;
////              tdest <= PORT1;
////              //flag <= 1'b0;
////            end
////          DEST_ADDR1:
////            begin
////              tdest <= PORT0;
////              //flag <= 1'b0;
////            end
////          DEST_ADDR2:
////            begin
////              tdest <= PORT3;
////              //flag <= 1'b0;
////            end
////          DEST_ADDR3:
////            begin
////              tdest <= PORT2;
////              //flag <= 1'b0;
////            end
////        endcase
////    end
//    if(rx_sof_n_reg)
//        DA <= rx_axis_tdata_out_reg[47:0];
//    case (DA)
//          DEST_ADDR0:
//            begin
//              //look_up_finished <= 1'b1;
//              tdest <= PORT1;
//              //flag <= 1'b0;
//            end
//          DEST_ADDR1:
//            begin
//              tdest <= PORT0;
//              //flag <= 1'b0;
//            end
//          DEST_ADDR2:
//            begin
//              tdest <= PORT3;
//              //flag <= 1'b0;
//            end
//          DEST_ADDR3:
//            begin
//              tdest <= PORT2;
//              //flag <= 1'b0;
//            end
//        endcase
//  end

  assign tx_axis_tdest = tdest;

  always @(posedge aclk) begin
     if (areset) begin
        tx_axis_tdata_out <= 64'b0;
        tx_axis_tkeep_out <= 8'b0;
        tx_axis_tvalid_out <= 1'b0;
        tx_axis_tvalid_reg <= 1'b0;
        tx_axis_tlast_out <= 1'b0;
     end
     else begin
        if (tx_axis_tready) begin
           tx_axis_tdata_out  <= tx_data_in;
           tx_axis_tkeep_out  <= rx_axis_tkeep_reg;
           tx_axis_tvalid_reg <= axis_data_beat;
           tx_axis_tvalid_out <= tx_axis_tvalid_reg;
           tx_axis_tlast_out  <= rx_axis_tlast_reg;
        end
     end
  end

  assign tx_axis_tvalid = tx_axis_tvalid_out;
  assign tx_axis_tdata  = tx_axis_tdata_out;
  assign tx_axis_tkeep  = tx_axis_tkeep_out; 
  assign tx_axis_tlast  = (tx_axis_tlast_out & tx_axis_tready & tx_axis_tvalid_out);
  
  assign rx_axis_tready = tx_axis_tready;

endmodule */