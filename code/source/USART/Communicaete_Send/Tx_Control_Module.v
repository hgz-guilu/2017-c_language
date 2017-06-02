module Tx_Control_Module
(
    CLOCK_50M, RST_n,
	 Tx_En_Sig, Tx_Data, BPS_CLK, 
    Tx_Done_Sig, Tx_Pin
	 
);

    input CLOCK_50M;
	 input RST_n;
	 
	 input Tx_En_Sig;
	 input [7:0]Tx_Data;
	 input BPS_CLK;
	 
	 output Tx_Done_Sig;//当一字节数据传输完成，会发出一个高脉冲信号
	 output Tx_Pin;
	 
	 /********************************************************/

	 reg [3:0]i;
	 reg rTx;
	 reg isDone;
	
	 always @ ( posedge CLOCK_50M or negedge RST_n )
	     if( !RST_n )
		      begin
		          i <= 4'd0;
					 rTx <= 1'b1;
					 isDone 	<= 1'b0;
				end
		  else if( Tx_En_Sig )
		      case ( i )
				
			       4'd0 :
					 if( BPS_CLK ) begin i <= i + 1'b1; rTx <= 1'b0; end //起始位
					 
					 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8 :
					 if( BPS_CLK ) begin i <= i + 1'b1; rTx <= Tx_Data[ i - 1 ]; end//数据位
					 
					 4'd9 :
					 if( BPS_CLK ) begin i <= i + 1'b1; rTx <= 1'b1; end//停止位/奇偶校验位
					 			 
					 4'd10 :
					 if( BPS_CLK ) begin i <= i + 1'b1; rTx <= 1'b1; end//停止位
					 
					 4'd11 :
					 if( BPS_CLK ) begin i <= i + 1'b1; isDone <= 1'b1; end
					 
					 4'd12 :
					 begin i <= 1'b0; isDone <= 1'b0; end //这一步没有判断BPS_CLK.即isDone的高电平只保持一个系统时钟
				default:i<=1'b0; 
				endcase
				
    /********************************************************/
	 
	 assign Tx_Pin = rTx;
	 assign Tx_Done_Sig = isDone;
	 
	 /*********************************************************/
	 
endmodule

