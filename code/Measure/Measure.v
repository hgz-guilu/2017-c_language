`timescale 1 ps/ 1 ps

module Measure(
				);



/***************************************************************************/
`define MEASURE_RESR_NUM  15   //16-1
`define GROUP_NUM         9    //10-1

/******************************************************************************/
reg CLOCK_50M;
reg RST_n;
    initial                                                
    begin                                                  
       RST_n = 0; #10; RST_n = 1;
       CLOCK_50M = 0; forever #10 CLOCK_50M = ~CLOCK_50M;		 
    end 
reg iRESR_signalA;    //??????????????????????
reg iRESR_signalZ;          //????????????0???
reg iRGS_signalA;		//????????????????????
reg [15:0]count1;
reg [15:0]count2;
reg [15:0]count3;    
reg [15:0]group_count;//?????????????????????????
reg [15:0]RESR_pulse_count0;//??????????????????????????
reg [15:0]RESR_pulse_count1;//???????????????????????????????
reg [15:0]RESR_pulse_count2;//????????????????????????????????
reg is_group_measure_start;
reg is_measure_start;//???????0??????????
reg is_first_ZERO_pulse;//???0??????
reg group_measure_again;//?????????????
reg [15:0]RGS_pulse_count;
reg detected_first_RGS_pulse;//????????????????????
reg start_RGS_pulse_count;//??????????????????????
reg is_first_RGS_pulse;//??????????????????

/****************************************************************************/
always@(posedge CLOCK_50M or negedge RST_n)
	if(!RST_n)
	begin
		count1<=16'd0;
		count2<=16'd0;
		count3<=16'd0;
		iRESR_signalA<=1'b0;
		iRESR_signalZ<=1'b0;
		iRGS_signalA<=1'b0;
	end
	else 
	begin
		if(count1==16'd4)
		begin
			count1<=16'd0;
			iRESR_signalA<=1'b1;
		end
		else
		begin
			count1<=count1+16'd1;
			iRESR_signalA<=1'b0;
		end
		if(count2==16'd800)
		begin
			count2<=16'd0;
			iRESR_signalZ<=1'b1;
		end
		else
		begin
			count2<=count2+16'd1;
			iRESR_signalZ<=1'b0;
		end
		if(count3==16'd15)
		begin
			count3<=16'd0;
			iRGS_signalA<=1'b1;
		end
		else
		begin
			count3<=count3+16'd1;
			iRGS_signalA<=1'b0;
		end
	end

/***************************************************************************
-----------------------------------------------------------


******************************************************************************/


always@(posedge CLOCK_50M or negedge RST_n)
	if(!RST_n)
	begin
		is_first_ZERO_pulse<=1'b1;
		is_measure_start<=1'b0;
		group_measure_again<=1'b0;
	end
	else 
	begin
		if(iRESR_signalZ)//???0?????????????
		begin
			if(is_first_ZERO_pulse)//??????0???
			begin
				is_first_ZERO_pulse<=1'b0;
				is_measure_start<=1'b1;//??????????????????
			end			
			group_measure_again<=1'b1;//?????????????
		end
		else if(is_group_measure_start )	
			group_measure_again<=1'b1;
		else
			group_measure_again<=1'b0;
	end

/*******************************************************************************/

always@(posedge CLOCK_50M)
  if(!RST_n || !is_measure_start)//???????????????
  begin
	group_count<=16'd0;
    RESR_pulse_count0<=16'd0;
	RESR_pulse_count1<=16'd0;
	RESR_pulse_count2<=16'd0;
  end
  else if(is_measure_start)//?????????  
  begin
	if(iRESR_signalZ)//???0???
	begin
		group_count<=16'd0;
		is_group_measure_start<=1'b0;
	end//group_measure_again????iRESR_signalZ?????????????else
	else if(group_measure_again)//???????????
	begin
		is_group_measure_start<=1'b0;
		if(iRESR_signalA==1'b1)//?????????????????????????????????
			RESR_pulse_count0<=16'd1;
		else
			RESR_pulse_count0<=16'd0;
	end
	else 
	begin
		if(iRESR_signalA==1'b1)
		begin							
			if(RESR_pulse_count0==`MEASURE_RESR_NUM )//当计到最后一组时，恰恰脉冲数多了，则继续，这就是为什么用>=号的原因
			begin
				if(group_count<`GROUP_NUM)//有可能由于电机震动，使圆光栅转动一周发出的脉冲数多于预计的
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
	if(detected_first_RGS_pulse)//??????????????????????????????????
	begin
		if(group_count[0]==1'b0)//??????
			RESR_pulse_count1<=RESR_pulse_count0;
		else					//??????
			RESR_pulse_count2<=RESR_pulse_count0;
	end
  end
/**************************************************************/

always@(posedge CLOCK_50M)
  if(!RST_n || !is_measure_start)//???????????????
  begin
	detected_first_RGS_pulse<=1'b0;//??????????????????????????
	start_RGS_pulse_count<=1'b0;
	RGS_pulse_count<=16'd0;
	is_first_RGS_pulse<=1'b0;//???????????????
  end
  else if(is_measure_start)//???????????????????????  
  begin	
	if(group_measure_again)//???????????????????????
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
				detected_first_RGS_pulse<=1'b0;     //             								
	    end
	    else
			detected_first_RGS_pulse<=1'b0;
	    if(iRGS_signalA)
			RGS_pulse_count<=RGS_pulse_count+16'd1;		
   end		
  end

endmodule