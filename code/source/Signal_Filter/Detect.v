module Detect(CLK,RST_n,Signal,H2L_Sig,L2H_Sig);
input CLK;
input RST_n;
input Signal;
output H2L_Sig;//下降沿脉冲信号
output L2H_Sig;//上升沿脉冲信号

/*******************************************************************
每发生一次边沿跳变时，就会有一个时钟脉冲的高电平信号发送出去
****************************************************************/
	 reg H2L_F1;//当前时钟信号
	 reg H2L_F2;//前一个时钟的信号
	 reg L2H_F1;//当前时钟信号
	 reg L2H_F2;//前一个时钟的信号
	 always @ ( posedge CLK or negedge RST_n )
	     if( !RST_n )
		      begin
				    H2L_F1 <= 1'b1;
					 H2L_F2 <= 1'b1;
					 L2H_F1 <= 1'b0;
					 L2H_F2 <= 1'b0;
			   end
		  else
		      begin
					 H2L_F1 <= Signal; 
					 H2L_F2 <= H2L_F1;
					 L2H_F1 <= Signal;//
					 L2H_F2 <= L2H_F1;
				end
				
    /***********************************/
	 

	 assign H2L_Sig = ( H2L_F2 & !H2L_F1 ) ;
	 assign L2H_Sig = ( !L2H_F2 & L2H_F1 ) ;


endmodule