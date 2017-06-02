module Detect(CLK,RST_n,Signal,H2L_Sig,L2H_Sig);
input CLK;
input RST_n;
input Signal;
output H2L_Sig;//�½��������ź�
output L2H_Sig;//�����������ź�

/*******************************************************************
ÿ����һ�α�������ʱ���ͻ���һ��ʱ������ĸߵ�ƽ�źŷ��ͳ�ȥ
****************************************************************/
	 reg H2L_F1;//��ǰʱ���ź�
	 reg H2L_F2;//ǰһ��ʱ�ӵ��ź�
	 reg L2H_F1;//��ǰʱ���ź�
	 reg L2H_F2;//ǰһ��ʱ�ӵ��ź�
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