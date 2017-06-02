module Signal_Source
						(
						CLOCK_50M,RST_n,RESR_signalA,RESR_signalB,RGS_signalA,RGS_signalB,RESR_signalZ
						);
input CLOCK_50M;
input RST_n;
output RESR_signalA;    //圆光栅信号
output RESR_signalB;	//圆光栅滞后90°
output RESR_signalZ;          //圆光栅0位信号
output RGS_signalA;		//光栅尺信号
output RGS_signalB;		//光栅尺滞后90°的信号


/***********************************************************************/
parameter CLK=32'd50_000_000;//系统时钟

parameter RESR_FRE=32'd324_000;//圆光栅输出时钟频率
parameter RESR_K = 32'd155;//CLK/RESR_FRE+1
parameter RESR_HARF=32'd77;//RESR_K/2
parameter RESR_QUARTER=32'd38;
parameter RESR_KF=32'd50_220_000;//RESR_K*RESR_FRE
/*---------------------------------------------------------------------*/
parameter RGS_FRE=32'd10_000;//光栅尺输出时钟频率
parameter RGS_K = 32'd5000;//CLK/RGS_FRE
parameter RGS_KF=32'd50_000_000;
parameter RGS_HARF=32'd1250;
parameter RGS_QUARTER=32'd625;

parameter T_1s=32'd49_999_999;
/**********************************************************************/
reg rRESR_signalZ; 
reg [31:0]count_time;

always @(posedge CLOCK_50M or negedge RST_n)
	if(!RST_n)
	begin
		rRESR_signalZ<=1'b0;
		count_time<=32'd0;
	end
	else if(count_time==T_1s)
	begin
		count_time<=32'd0;
	end
	else if(count_time<32'd49_999_900)
	begin
		rRESR_signalZ<=1'b0;
		count_time<=count_time+32'd1;
	end
	else
	begin
		rRESR_signalZ<=1'b1;
		count_time<=count_time+32'd1;
	end
	

assign RESR_signalZ=rRESR_signalZ;

/*********************************************************************/
reg [31:0]resr_a;
reg [31:0]resr_b;
reg [31:0]rgs_a;
reg [31:0]rgs_b;
always @(posedge CLOCK_50M or negedge RST_n)
  if(!RST_n)
  begin
    resr_a=32'd0;
	 resr_b=32'd0;
	 rgs_a=32'd0;
	 rgs_b=32'd0;
  end
  else
  begin
    resr_b=((resr_a+RESR_KF)/CLK+resr_b)%RESR_K;
	 resr_a=(resr_a+RESR_KF)%CLK;	 
	 rgs_b=((rgs_a+RGS_KF)/CLK+rgs_b)%RGS_K;
	 rgs_a=(rgs_a+RGS_KF)%CLK;
  end
reg rRESR_signalA;
reg rRGS_signalA;
always@(posedge CLOCK_50M or negedge RST_n)
  if(!RST_n)
  begin
    rRESR_signalA<=1'b0;
	 rRGS_signalA<=1'b0;
  end
  else
  begin
    if(resr_b>=RESR_HARF && rRESR_signalA==1'b0)
	   rRESR_signalA<=1'b1;
	 else if(resr_b<RESR_HARF && rRESR_signalA==1'b1)
	   rRESR_signalA<=1'b0;
		
	 if(rgs_b>=RGS_HARF && rRGS_signalA==1'b0)
	   rRGS_signalA<=1'b1;
	 else if(rgs_b<RGS_HARF && rRGS_signalA==1'b1)
	   rRGS_signalA<=1'b0;
  end
assign RESR_signalA=rRESR_signalA;
assign RGS_signalA=rRGS_signalA;
/**********************************************************/

reg [31:0]count0;
reg [31:0]count1;
reg is_RESR_start;
reg is_RGS_start;
always@(posedge CLOCK_50M or negedge RST_n)
  if(!RST_n)
  begin
    count0<=32'd0;
	 count1<=32'd0;
	 is_RESR_start<=1'b0;
	 is_RGS_start<=1'b0;
  end
  else 
  begin
    if(count0>=RESR_QUARTER)
      is_RESR_start<=1'b1;
	 else 
	   count0<=count0+32'd1;
	 if(count1>=RGS_QUARTER)
      is_RGS_start<=1'b1;
	 else 
	   count1<=count1+32'd1;
  end 
reg [31:0]resr_a1;
reg [31:0]resr_b1;
reg [31:0]rgs_a1;
reg [31:0]rgs_b1;
always@(posedge CLOCK_50M or negedge RST_n)
  if(!RST_n)
  begin
    resr_a1=32'd0;
	 resr_b1=32'd0;
	 rgs_a1=32'd0;
	 rgs_b1=32'd0;
  end
  else
  begin
    if(is_RESR_start==1'b1)
	 begin
	   resr_b1=((resr_a1+RESR_KF)/CLK+resr_b1)%RESR_K;
	   resr_a1=(resr_a1+RESR_KF)%CLK;	 
	 end
    if(is_RGS_start==1'b1)
	 begin
	   rgs_b1=((rgs_a1+RGS_KF)/CLK+rgs_b1)%RGS_K;
	   rgs_a1=(rgs_a1+RGS_KF)%CLK;
	 end	 
  end
reg rRESR_signalB;
reg rRGS_signalB;
always@(posedge CLOCK_50M or negedge RST_n)
  if(!RST_n)
  begin
    rRESR_signalB<=1'b0;
	 rRGS_signalB<=1'b0;
  end
  else
  begin
    if(resr_b1>=RESR_HARF && rRESR_signalB==1'b0)
	   rRESR_signalB<=1'b1;
	 else if(resr_b1<RESR_HARF && rRESR_signalB==1'b1)
	   rRESR_signalB<=1'b0;
		
	 if(rgs_b1>=RGS_HARF && rRGS_signalB==1'b0)
	   rRGS_signalB<=1'b1;
	 else if(rgs_b1<RGS_HARF && rRGS_signalB==1'b1)
	   rRGS_signalB<=1'b0;
  end
assign RESR_signalB=rRESR_signalB;
assign RGS_signalB=rRGS_signalB;

endmodule