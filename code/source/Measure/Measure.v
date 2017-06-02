module Measure(CLOCK_50M,RST_n,iRESR_signalA,iRESR_signalZ,iRGS_signalA,Signal_Corotation,
				Frame_Start_Sig,Data_Send_Sig,Data,LED
				);


input CLOCK_50M;
input RST_n;
input iRESR_signalA;    //Բ��դ�����źţ��ߵ�ƽΪһ��ϵͳʱ�������ź�
input iRESR_signalZ;          //һ��ϵͳʱ�������Բ��դ0λ�ź�
input iRGS_signalA;		//��դ���źţ��ߵ�ƽΪһ��ϵͳʱ�������ź�
input Signal_Corotation;  //�������ת�źţ��ź�Ϊ1�������ת���ź�Ϊ0�������ת
 output Frame_Start_Sig;//һ��ʱ�ӵĸߵ�ƽ���壬����һ֡���ݿ�ʼ����
 output Data_Send_Sig;//һ�������źţ���ʾһ��8λ���ݵ���
 output [7:0]Data;//����һ��8x8�����ݻ������������ݴ�Բ��դ�͹�դ�ߵ�������� ����	
 output [8:0]LED;//���������ã�
/***************************************************************************/
`define RESR_CIRCLE_PLUSE_NUM   1296000
`define NUM                      40
`define MEASURE_RESR_NUM       (`RESR_CIRCLE_PLUSE_NUM/`NUM-1)  //32400-1
`define GROUP_NUM              (`NUM-1)      //40-1

/****************************************************************************/
reg [8:0]rLED;
always@(posedge CLOCK_50M or negedge RST_n)
	if(!RST_n)
		rLED<=8'd0;
	else if(iRESR_signalZ)//������0λ�ź�ʱ��һ�����ݿ�ʼ����	
		rLED<=~rLED;	
assign LED=rLED;
/***************************************************************************
-----------------------------------------------------------
iSignal_A | 
---------------------------------------------------------------
0λ�źţ�Ҫ���ǵ�һת��Բ��դ������������ڻ��������õĸ�����
���ˣ�ֱ�Ӳ���������
��������ʱ0λ�źŻ�����Բ��դ����������źţ���0λ�źſ�ʼһ���µļ���ֵ
���ˣ�ֱ���ӵ�
��������ʱ���ɼ��������ͳ��һת���Ѿ������˶��������ݣ�����������õ�����ʱ��
	  �ȴ�0λ�źų��֣���������Բ��դ����������ź���������ʹ����һ������Ŀ�ʼ��
	  
�ܵ�ԭ��Բ��դʵ�ʵ�����������������Ԥ�Ƶ�����������ܴ󣬼�����༸ʮ��
��һ����ͳ�Ƹ���1696��ȣ�Ӧ���ܽ��ܡ�
--------------------------------------------------------------
�����ģ��Ŀ�ʼ�ڣ�����⵽��һ��0λ�ź�ʱ����
��ģ��������˿��һת���ϴ�1000�����ݣ�����Բ��դ�����źŵ�1296000/ת������
һ�����ü��������СΪ1296����������Ϊ1000��������Ĵ�������1000��˵��һת��Բ��դ����
���ˡ�
--------------------------------------------------------------
ע�⣺���ܵ��������дʱ��������Ϊ�κ��źŶ���ͳ��Բ��դ�����������
******************************************************************************/

reg is_measure_start;//����⵽��һ��0λ�ź�ʱ����⿪ʼ��
reg is_first_ZERO_pulse;//��һ��0λ�źŵı�־
reg group_measure_again;//��Ϊ�µ�һ����Ŀ�ʼ�ź�
always@(posedge CLOCK_50M or negedge RST_n)
	if(!RST_n)
	begin
		is_first_ZERO_pulse<=1'b1;
		is_measure_start<=1'b0;
		group_measure_again<=1'b0;
	end
	else if(iRESR_signalZ)//������0λ�ź�ʱ��һ�����ݿ�ʼ����
	begin
		if(is_first_ZERO_pulse)//�Ƿ��ǵ�һ��0λ�ź�
		begin
			is_first_ZERO_pulse<=1'b0;
			is_measure_start<=1'b1;//��⿪ʼ��һ��ϵͳʱ�ӵĸ������źţ�
		end			
		group_measure_again<=1'b1;//��Ϊ�µ�һ����Ŀ�ʼ�ź�
	end
	else if(is_group_measure_start)
		group_measure_again<=1'b1;
	else
		group_measure_again<=1'b0;

/*******************************************************************************/
reg [15:0]group_count;//������¼һת�ڷ��͵����ݴ�������һת���ж���������
reg [15:0]RESR_pulse_count0;//���ڼ���೤ʱ�䷢��һ�����ݵ��źţ��������ۻ��Ĵ���
reg [15:0]RESR_pulse_count1;//��Բ��դ��ʼһ�μ���������һ�ι�դ�ߵ������ص�Բ��դ���������
reg [15:0]RESR_pulse_count2;//��Բ��դ�ս���һ�μ���������һ�ι�դ�ߵ������ص�Բ��դ���������
reg is_group_measure_start;
always@(posedge CLOCK_50M)
  if(!RST_n || !is_measure_start)//��λ�źŻ��߻�û�п�ʼ�������
  begin
	group_count<=16'd0;
    RESR_pulse_count0<=16'd0;
	RESR_pulse_count1<=16'd0;
	RESR_pulse_count2<=16'd0;
	is_group_measure_start<=1'b0;
  end
  else if(is_measure_start)//��ʼ���в������ź�  
  begin
	if(iRESR_signalZ)//��⵽0λ�ź�
	begin
		group_count<=16'd0;		
	end//group_measure_again�źŻ��iRESR_signalZ�ź���һ��ϵͳʱ�ӣ�������else
	else if(group_measure_again)//��ʼ�µ�һ������ź�
	begin
		is_group_measure_start<=1'b0;
		if(iRESR_signalA==1'b1)//����������ź�ͬ���أ�������Ϊ����ʹ���źţ����ټ���һ��Բ��դ�ź�
			RESR_pulse_count0<=16'd1;
		else
			RESR_pulse_count0<=16'd0;
	end
	else
	begin
		if(iRESR_signalA==1'b1)
		begin							
			if(RESR_pulse_count0>=`MEASURE_RESR_NUM )//���Ƶ����һ��ʱ��ǡǡ���������ˣ�������������Ϊʲô��>=�ŵ�ԭ��
			begin
				if(group_count<`GROUP_NUM)//�п������ڵ���𶯣�ʹԲ��դת��һ�ܷ���������������Ԥ�Ƶ�,���Լ����������һ����0λ�źŴ����������ټ�һ��
				begin
					RESR_pulse_count0<=1'b0;//��������
					group_count<=group_count+16'd1;
					is_group_measure_start<=1'b1;
				end
				end
			else
				RESR_pulse_count0<=RESR_pulse_count0+16'd1;
		end					
		else
			is_group_measure_start<=1'b0;
	end
	if(detected_first_RGS_pulse)//��⵽һ��տ�ʼ��ĵ�һ����դ���źţ����ź���һ��������ϵͳʱ���ź�
	begin
		if(group_count[0]==1'b0)//�����������
			RESR_pulse_count1<=RESR_pulse_count0;
		else					//�����ż����
			RESR_pulse_count2<=RESR_pulse_count0;
	end
  end
/**************************************************************/
reg [15:0]RGS_pulse_count;
reg detected_first_RGS_pulse;//ÿ������еĵ�һ����դ�ߵ������źű�־λ
reg start_RGS_pulse_count;//��һ�����������ʼ�����й�դ������Ĳ�������
reg is_first_RGS_pulse;//����Ƿ���һ�鿪ʼ�ĵ�һ����դ���ź�
always@(posedge CLOCK_50M)
  if(!RST_n || !is_measure_start)//��λ�źŻ��߻�û�п�ʼ�������
  begin
	detected_first_RGS_pulse<=1'b0;//��һ�����ݲ�����ʼ��⵽��һ����դ�������źŵı�־λ
	start_RGS_pulse_count<=1'b0;
	RGS_pulse_count<=16'd0;
	is_first_RGS_pulse<=1'b0;//һ��ĵ�һ����դ�ߵ������־λ
  end
  else if(is_measure_start)//��ʼ���в������źţ�һ���������ϵͳʱ���źţ�  
  begin	
	if(group_measure_again)//��ʼ�µ�һ��Ĳ�����һ���������ϵͳʱ���źţ�
	begin
		start_RGS_pulse_count<=1'b1;
		detected_first_RGS_pulse<=1'b0;
		is_first_RGS_pulse<=1'b1;
		RGS_pulse_count<=16'd0;
	end
	else if(start_RGS_pulse_count)
	begin
		if(is_first_RGS_pulse)
		begin
			if(iRGS_signalA)
			begin
				is_first_RGS_pulse<=1'b0;
				detected_first_RGS_pulse<=1'b1;
			end
			else
				detected_first_RGS_pulse<=1'b0;   //������Ϊ������ź�ֻ��һ��ϵͳ����ʱ��             								
	   end
	   else
			detected_first_RGS_pulse<=1'b0;
	   if(iRGS_signalA)
			RGS_pulse_count<=RGS_pulse_count+16'd1;	
   end		
  end
 /*------------------���ͳ����ݲɼ��ź�------------------------------------*/
reg sampling_signal;
reg [1:0]count;
always@(posedge CLOCK_50M or negedge RST_n)
	if(!RST_n)
	begin
		count<=2'd0;
		sampling_signal<=1'b0;
	end
	else if(is_measure_start)
	begin
		if(detected_first_RGS_pulse)
		begin
			if(count>=2'd1)
				sampling_signal<=1'b1;
			else
			begin
				sampling_signal<=1'b0;
				count<=count+2'd1;
			end
		end
		else
			sampling_signal<=1'b0;
	end
	
  
  

/*******************************�����Ƕ����ݽ��д���Ĳ���****************************************************/

/*----------------------------------------------------
���浱ǰ����ֵ���Ĵ����У��ȴ�����
------------------------------------------------------*/
reg rFrame_Start_Sig;
reg [15:0]RESR_pulse_value;
reg [15:0]RGS_pulse_value;
always@(posedge CLOCK_50M or negedge RST_n)
	if(!RST_n)
	begin
		rFrame_Start_Sig<=1'b0;		
		RESR_pulse_value<=16'd0;
		RGS_pulse_value<=16'd0;
	end
	else 
	begin
		if(group_measure_again)
			RGS_pulse_value<=RGS_pulse_count;
			
		if(sampling_signal)
		begin
			rFrame_Start_Sig<=1'b1;				
			RESR_pulse_value<=RESR_pulse_count1-RESR_pulse_count2;
		end	
		else
			rFrame_Start_Sig<=1'b0;
	end
/*****************************************************************
�Ѳ������ݷ��͵���һģ�飬�������ݷ���
*****************************************************************/
reg [7:0]rData;
reg rData_Send_Sig;
reg [7:0]num;
reg start_send;
always@(posedge CLOCK_50M or negedge RST_n)
		if(!RST_n)
		begin
			start_send<=1'b0;
			rData_Send_Sig<=1'b0;
			num<=8'd0;
		end
		else if(rFrame_Start_Sig)
		begin
			start_send<=1'b1;
			rData_Send_Sig<=1'b0;
			num<=8'd0;
		end
		else if(start_send)
		begin
			case(num)
			8'd0:begin rData<=RESR_pulse_value[15:8];num<=num+8'd1;rData_Send_Sig<=1'b1;end
			8'd2:begin rData<=RESR_pulse_value[7:0];num<=num+8'd1;rData_Send_Sig<=1'b1;end
			8'd4:begin rData<=RGS_pulse_value[15:8];num<=num+8'd1;rData_Send_Sig<=1'b1;end
			8'd6:begin rData<=RGS_pulse_value[7:0];num<=num+8'd1;rData_Send_Sig<=1'b1;end
			default:
				if(num<8'd6)
				begin num<=num+8'd1;rData_Send_Sig<=1'b0;end
			   else if(num==8'd7)
				begin start_send<=1'b0;rData_Send_Sig<=1'b0;end
			endcase
		end

	assign Data=rData;
	assign Data_Send_Sig=rData_Send_Sig;
	assign Frame_Start_Sig=rFrame_Start_Sig;
endmodule