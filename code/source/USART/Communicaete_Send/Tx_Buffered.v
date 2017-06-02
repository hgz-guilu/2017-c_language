module Tx_Buffered(CLOCK_50M,RST_n,Frame_Start_Sig,Data_Send_Sig,Data,Tx_Done_Sig,Tx_Data,Tx_En_Sig);

 input CLOCK_50M;
 input RST_n;
 input Frame_Start_Sig;//һ��ʱ�ӵĸߵ�ƽ���壬����һ֡���ݿ�ʼ����
 input Data_Send_Sig;//һ�������źţ���ʾһ��8λ���ݵ���
 input [7:0]Data;//����һ��8x8�����ݻ������������ݴ�Բ��դ�͹�դ�ߵ�������� ����	 
 input Tx_Done_Sig;//����һ���ֽ����ݷ�����ɣ�
 output [7:0]Tx_Data;//���͵��ֽ�
 output Tx_En_Sig;//����ʱ��ʹ���źţ������ڲ���������ʱ���÷���ʱ��ֹͣ

/***************************************************************/
`define FRAME_HEAD0_INDEX      		8'd0
`define FRAME_HEAD1_INDEX      		8'd1
`define FRAME_TYPE_INDEX       		8'd2
`define FRAME_DATA_LEN_INDEX   		8'd3
`define FRAME_DATA_INDEX       		8'd4
`define FRAME_DATA_END_INDEX       	(`FRAME_DATA_INDEX+`FRAME_DATA_LEN-8'd1)
`define FRAME_CHECK_SUM0_INDEX 		8'd8
`define FRAME_CHECK_SUM1_INDEX 		8'd9
`define FRAME_TAIL0_INDEX			   8'd10
`define FRAME_TAIL1_INDEX			   8'd11
`define FRAME_END_INDEX			      8'd12

`define FRAME_HEAD0                 8'hff
`define FRAME_HEAD1                 8'hfe
`define FRAME_TYPE                  8'h01   //��ʾ�����ݣ�0x00��ʾ�����0x02��ʾ�Ǵ�����Ϣ
`define FRAME_DATA_LEN              8'd4
//��������
//16λУ���
`define FRAME_TAIL0                 8'hfe
`define FRAME_TAIL1                 8'hff
/**************************************************************/
    /*************************************
	�������ݣ������ڻ����У���������ϣ�rec_complete�ߵ�ƽ
	****************************************************/
	reg rec_start;//��ʼ����һ�ֽ�����
	reg rec_complete;//һ֡����ȫ���������
	reg [7:0]data_count;
	reg [7:0]rData[20:0];
	reg [15:0]check_sum;

	always @(posedge CLOCK_50M or negedge RST_n)
		if(!RST_n)
		begin			
			data_count<=8'd0;
			rec_start<=1'b0;
			rec_complete<=1'b0;
			check_sum<=16'd0;
		end
		else if(Frame_Start_Sig)
		begin
			rec_start<=1'b1;
			data_count<=8'd0;
			rec_complete<=1'b0;
			check_sum<=16'd0;
		end
		else if(rec_start)
		begin
			if(Data_Send_Sig)
			begin
				check_sum<=check_sum+Data;//У���
				rData[data_count]<=Data;//���ݻ���
				data_count<=data_count+8'd1;
				if(data_count>=(`FRAME_DATA_LEN-1'd1))
				begin
					rec_complete<=1'b1;
					rec_start<=1'b0;
				end				 
			end			
		end
/******************************************************************
Tx_Done_Sig�źţ���Ϊ��Tx_Control_Moduleģ���У�����Ĭ��״̬�ǵ͵�ƽ��ֻ���ڽ��յ�һ���ֽڵ�
���ݺ�Ż�����һ��ϵͳ����ʱ�ӣ������ڷ��͵�һ���ֽ�ʱ������ͨ��Tx_Done_Sig�źţ��жϣ���Ȼ
�ͻ����뻥�⣬���ȵ�״̬��
�������ϵ�һ���ֽڷ���ʱ�����;����ǿ��еģ����ԾͲ����ж�Tx_Done_Sig�ź��ˣ�����֮����ֽ�Ҫ�жϣ�
�Ա�֤���ͻ������е��ֽڲ��ᱻ���ǵ���
********************************************************************/
reg [7:0]i;
reg tx_enable;
reg [7:0]rTx_Data;
reg frame_send_complete;
	always @(posedge CLOCK_50M or negedge RST_n)
		if(!RST_n)
		begin
			tx_enable<=1'b0;
			rTx_Data<=8'h00;
			frame_send_complete=1'b0;
			i=8'd0;
		end
		else if(!rec_complete)//�ȴ�һ֡����ȫ������
		begin
			tx_enable<=1'b0;
			rTx_Data<=8'h00;
			frame_send_complete=1'b0;
			i=8'd0;
		end
		else if(frame_send_complete==1'b0)//һ֡����ȫ��������ɣ���ʼ����
		begin
			tx_enable<=1'b1;
			if(i==8'd0)
			begin rTx_Data<=`FRAME_HEAD0; i<=i+8'd1;end//���͵�һ�ֽ�����
			if(Tx_Done_Sig )//��һ�ֽ������Ƿ�����ɣ�Tx_Done_Sig�Ƿ�����һ��ϵͳʱ�ӵĸ������ź�
			begin				
				case (i)
				//	`FRAME_HEAD0_INDEX: 
					`FRAME_HEAD1_INDEX:      begin rTx_Data<=`FRAME_HEAD1; i<=i+8'd1;end
					`FRAME_TYPE_INDEX:       begin rTx_Data<=`FRAME_TYPE; i<=i+8'd1;end
					`FRAME_DATA_LEN_INDEX:   begin rTx_Data<=`FRAME_DATA_LEN; i<=i+8'd1;end
	
					`FRAME_CHECK_SUM0_INDEX: begin rTx_Data<=check_sum[15:8]; i<=i+8'd1;end
					`FRAME_CHECK_SUM1_INDEX: begin rTx_Data<=check_sum[7:0]; i<=i+8'd1;end
					`FRAME_TAIL0_INDEX:      begin rTx_Data<=`FRAME_TAIL0; i<=i+8'd1;end
					`FRAME_TAIL1_INDEX:      begin rTx_Data<=`FRAME_TAIL1; i<=i+8'd1;end
					`FRAME_END_INDEX: frame_send_complete=1'b1;//һ֡���ݴ������
					default:begin
									if(i>=`FRAME_DATA_INDEX && i<=`FRAME_DATA_END_INDEX)
									begin
										rTx_Data<=rData[i-`FRAME_DATA_INDEX];
										i<=i+8'd1;
									end
									else if(i!=8'd0)
										frame_send_complete=1'b1; 
							  end
				endcase			
			end			
		end
		else //if(frame_send_complete==1'b1)
			tx_enable<=1'b0;//��ʼ��������

		
    /*************************************/
	 
	 assign Tx_En_Sig = tx_enable;
	 assign Tx_Data = rTx_Data;
	 
	 /*************************************/
	 

endmodule
