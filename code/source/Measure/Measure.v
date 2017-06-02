module Measure(CLOCK_50M,RST_n,iRESR_signalA,iRESR_signalZ,iRGS_signalA,Signal_Corotation,
				Frame_Start_Sig,Data_Send_Sig,Data,LED
				);


input CLOCK_50M;
input RST_n;
input iRESR_signalA;    //圆光栅脉冲信号，高电平为一个系统时钟脉冲信号
input iRESR_signalZ;          //一个系统时钟脉冲的圆光栅0位信号
input iRGS_signalA;		//光栅尺信号，高电平为一个系统时钟脉冲信号
input Signal_Corotation;  //电机正反转信号，信号为1，电机正转，信号为0，电机反转
 output Frame_Start_Sig;//一个时钟的高电平脉冲，代表一帧数据开始到来
 output Data_Send_Sig;//一个脉冲信号，表示一个8位数据到来
 output [7:0]Data;//定义一个8x8的数据缓冲区，用来暂存圆光栅和光栅尺的脉冲计数 个数	
 output [8:0]LED;//用来测试用，
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
	else if(iRESR_signalZ)//当遇见0位信号时，一组数据开始测量	
		rLED<=~rLED;	
assign LED=rLED;
/***************************************************************************
-----------------------------------------------------------
iSignal_A | 
---------------------------------------------------------------
0位信号，要考虑到一转内圆光栅的脉冲个数多于或少于设置的个数？
少了：直接补齐脉冲数
方法：此时0位信号会早于圆光栅脉冲计数满信号，由0位信号开始一组新的计数值
多了：直接扔掉
方法：此时，由计组计数器统计一转内已经发送了多少组数据，如果多于设置的组数时，
	  等待0位信号出现，而不再由圆光栅脉冲计数满信号来进行来使能下一组测量的开始；
	  
总的原因，圆光栅实际的输出脉冲个数不会与预计的脉冲个数相差很大，几个最多几十个
与一组内统计个数1696相比，应该能接受。
--------------------------------------------------------------
本检测模块的开始于，当检测到第一个0位信号时进行
本模块设置在丝杠一转内上传1000组数据；由于圆光栅脉冲信号的1296000/转，所以
一组设置计数脉冲大小为1296，组数设置为1000，当计组寄存器大于1000，说明一转内圆光栅个数
多了。
--------------------------------------------------------------
注意：在总的这块程序编写时，不能因为任何信号而少统计圆光栅的脉冲个数。
******************************************************************************/

reg is_measure_start;//当检测到第一个0位信号时，检测开始，
reg is_first_ZERO_pulse;//第一个0位信号的标志
reg group_measure_again;//作为新的一组检测的开始信号
always@(posedge CLOCK_50M or negedge RST_n)
	if(!RST_n)
	begin
		is_first_ZERO_pulse<=1'b1;
		is_measure_start<=1'b0;
		group_measure_again<=1'b0;
	end
	else if(iRESR_signalZ)//当遇见0位信号时，一组数据开始测量
	begin
		if(is_first_ZERO_pulse)//是否是第一个0位信号
		begin
			is_first_ZERO_pulse<=1'b0;
			is_measure_start<=1'b1;//检测开始（一个系统时钟的高脉冲信号）
		end			
		group_measure_again<=1'b1;//作为新的一组检测的开始信号
	end
	else if(is_group_measure_start)
		group_measure_again<=1'b1;
	else
		group_measure_again<=1'b0;

/*******************************************************************************/
reg [15:0]group_count;//用来记录一转内发送的数据次数，即一转内有多少组数据
reg [15:0]RESR_pulse_count0;//用于计算多长时间发送一次数据的信号，即定长累积寄存器
reg [15:0]RESR_pulse_count1;//在圆光栅开始一次计数，到第一次光栅尺的上升沿的圆光栅的脉冲计数
reg [15:0]RESR_pulse_count2;//在圆光栅刚结束一次计数，到第一次光栅尺的上升沿的圆光栅的脉冲计数
reg is_group_measure_start;
always@(posedge CLOCK_50M)
  if(!RST_n || !is_measure_start)//复位信号或者还没有开始计算测量
  begin
	group_count<=16'd0;
    RESR_pulse_count0<=16'd0;
	RESR_pulse_count1<=16'd0;
	RESR_pulse_count2<=16'd0;
	is_group_measure_start<=1'b0;
  end
  else if(is_measure_start)//开始进行测量的信号  
  begin
	if(iRESR_signalZ)//检测到0位信号
	begin
		group_count<=16'd0;		
	end//group_measure_again信号会比iRESR_signalZ信号晚一个系统时钟，所以用else
	else if(group_measure_again)//开始新的一组检测的信号
	begin
		is_group_measure_start<=1'b0;
		if(iRESR_signalA==1'b1)//如果这两个信号同边沿，不能因为测量使能信号，而少计了一个圆光栅信号
			RESR_pulse_count0<=16'd1;
		else
			RESR_pulse_count0<=16'd0;
	end
	else
	begin
		if(iRESR_signalA==1'b1)
		begin							
			if(RESR_pulse_count0>=`MEASURE_RESR_NUM )//当计到最后一组时，恰恰脉冲数多了，则继续，这就是为什么用>=号的原因
			begin
				if(group_count<`GROUP_NUM)//有可能由于电机震动，使圆光栅转动一周发出的脉冲数多于预计的,所以计数组数最后一组有0位信号触发，这里少计一组
				begin
					RESR_pulse_count0<=1'b0;//计数清零
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
	if(detected_first_RGS_pulse)//检测到一组刚开始后的第一个光栅尺信号，此信号是一个高脉冲系统时钟信号
	begin
		if(group_count[0]==1'b0)//如果是奇数组
			RESR_pulse_count1<=RESR_pulse_count0;
		else					//如果是偶数组
			RESR_pulse_count2<=RESR_pulse_count0;
	end
  end
/**************************************************************/
reg [15:0]RGS_pulse_count;
reg detected_first_RGS_pulse;//每组测量中的第一个光栅尺的脉冲信号标志位
reg start_RGS_pulse_count;//在一组脉冲测量开始，进行光栅尺脉冲的测量计数
reg is_first_RGS_pulse;//标记是否是一组开始的第一个光栅尺信号
always@(posedge CLOCK_50M)
  if(!RST_n || !is_measure_start)//复位信号或者还没有开始计算测量
  begin
	detected_first_RGS_pulse<=1'b0;//在一组数据测量开始检测到第一个光栅尺脉冲信号的标志位
	start_RGS_pulse_count<=1'b0;
	RGS_pulse_count<=16'd0;
	is_first_RGS_pulse<=1'b0;//一组的第一个光栅尺的脉冲标志位
  end
  else if(is_measure_start)//开始进行测量的信号（一个高脉冲的系统时钟信号）  
  begin	
	if(group_measure_again)//开始新的一组的测量（一个高脉冲的系统时钟信号）
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
				detected_first_RGS_pulse<=1'b0;   //这里是为了这个信号只有一个系统脉冲时长             								
	   end
	   else
			detected_first_RGS_pulse<=1'b0;
	   if(iRGS_signalA)
			RGS_pulse_count<=RGS_pulse_count+16'd1;	
   end		
  end
 /*------------------发送出数据采集信号------------------------------------*/
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
	
  
  

/*******************************下面是对数据进行传输的操作****************************************************/

/*----------------------------------------------------
保存当前测量值到寄存器中，等待传输
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
把测量数据发送到下一模块，进行数据发送
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