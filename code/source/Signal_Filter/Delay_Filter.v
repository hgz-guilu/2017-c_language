module Delay_Filter #(parameter NUM = 10)(CLK, RST_n, H2L_Sig, L2H_Sig, oSignal);
    input CLK;
	 input RST_n;
	 input H2L_Sig;
	 input L2H_Sig;
	 output oSignal;
	/***************************************************************/
	localparam FILTER_NUM = NUM-3;//滤波设置的过滤数,H2L_Sig延迟一个时钟，isCount延迟一个系统时钟，count_CLK延迟一个系统时钟，所以滤波计算要减3
	
	/*******************************************************************/
	 reg [31:0]count_CLK;
	always @ ( posedge CLK or negedge RST_n )
	  if( !RST_n )
			count_CLK <= 32'd0;
	  else if( isCount==1'b1)
			count_CLK <= count_CLK + 32'd1;
	  else 
			count_CLK <= 32'd0;
/***************************************************************************/
	reg [1:0]state;
	reg isCount;
	reg rSignal;
	always@(posedge CLK or negedge RST_n)
	if(!RST_n)
	begin
	  state<=2'd0;
	  isCount<=1'b0;
	  rSignal<=1'b0;
	end
	else
	begin
	/*------------实时监测边沿的触发状态-----------------------*/
	  if(H2L_Sig)
	  begin
	    isCount<=1'b0;//清零计数器信号
		 state<=2'd1;
	  end
	  else if(L2H_Sig)
	  begin 
	    isCount<=1'b0;//清零计数器信号
		 state<=2'd2;
	  end
	  /*------------下降沿延时计数，信号有效时，寄存器输出0-----------------------*/
	  if(state==2'd1)
	  begin
	    isCount<=1'b1;
	    if(count_CLK==FILTER_NUM)
		 begin
		   state<=2'd0;
		   rSignal<=1'b0;
			isCount<=1'b0;
		 end
	  end
	  /*------------上升沿延时计数，信号有效时，寄存器输出1-----------------------*/
	  else if(state==2'd2)
	  begin
	    isCount<=1'b1;
		 if(count_CLK==FILTER_NUM)
		 begin
		   state<=2'd0;
		   rSignal<=1'b1;
			isCount<=1'b0;
		 end
	  end
	end
/**************************************************************************************/
	assign oSignal=rSignal;
endmodule