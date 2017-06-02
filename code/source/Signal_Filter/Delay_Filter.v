module Delay_Filter #(parameter NUM = 10)(CLK, RST_n, H2L_Sig, L2H_Sig, oSignal);
    input CLK;
	 input RST_n;
	 input H2L_Sig;
	 input L2H_Sig;
	 output oSignal;
	/***************************************************************/
	localparam FILTER_NUM = NUM-3;//�˲����õĹ�����,H2L_Sig�ӳ�һ��ʱ�ӣ�isCount�ӳ�һ��ϵͳʱ�ӣ�count_CLK�ӳ�һ��ϵͳʱ�ӣ������˲�����Ҫ��3
	
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
	/*------------ʵʱ�����صĴ���״̬-----------------------*/
	  if(H2L_Sig)
	  begin
	    isCount<=1'b0;//����������ź�
		 state<=2'd1;
	  end
	  else if(L2H_Sig)
	  begin 
	    isCount<=1'b0;//����������ź�
		 state<=2'd2;
	  end
	  /*------------�½�����ʱ�������ź���Чʱ���Ĵ������0-----------------------*/
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
	  /*------------��������ʱ�������ź���Чʱ���Ĵ������1-----------------------*/
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