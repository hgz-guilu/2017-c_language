module Signal_Filter_Top (CLOCK_50M,RST_n,
			iRESR_signalA,iRESR_signalB,iRGS_signalA,iRGS_signalB,iRESR_signalZ,
			oRESR_signalA,oRGS_signalA,oRESR_signalZ,
			Signal_Corotation
);

input CLOCK_50M;
input RST_n;
input iRESR_signalA;    //圆光栅信号
input iRESR_signalB;	//圆光栅滞后90°
input iRESR_signalZ;          //圆光栅0位信号
input iRGS_signalA;		//光栅尺信号
input iRGS_signalB;		//光栅尺滞后90°的信号
output oRESR_signalA;    //圆光栅信号
output oRESR_signalZ;          //圆光栅0位信号
output oRGS_signalA;		//光栅尺信号
output Signal_Corotation;  //正转
/***************************************************************/
wire RESR_signalA;    //圆光栅信号
wire RESR_signalB;	//圆光栅滞后90°
wire RESR_signalZ;          //圆光栅0位信号
wire RGS_signalA;		//光栅尺信号
wire RGS_signalB;		//光栅尺滞后90°的信号
/**************************************************************/
		Signal_Filter #(.FILTER_NUM (10))U0		//此信号设置10个系统脉冲时钟滤波
         (
			.CLK(CLOCK_50M),
			.RST_n(RST_n),
			.iSignal(iRESR_signalA),
			.oSignal(RESR_signalA)
		 );
		 Signal_Filter #(.FILTER_NUM (10))U1		//此信号设置10个系统脉冲时钟滤波
         (
			.CLK(CLOCK_50M),
			.RST_n(RST_n),
			.iSignal(iRESR_signalB),
			.oSignal(RESR_signalB)
		 );
		 Signal_Filter #(.FILTER_NUM (10))U2		//此信号设置10个系统脉冲时钟滤波
         (
			.CLK(CLOCK_50M),
			.RST_n(RST_n),
			.iSignal(iRESR_signalZ),
			.oSignal(RESR_signalZ)
		 );
		 Signal_Filter #(.FILTER_NUM (10))U3		//此信号设置10个系统脉冲时钟滤波
         (
			.CLK(CLOCK_50M),
			.RST_n(RST_n),
			.iSignal(iRGS_signalA),
			.oSignal(RGS_signalA)
		 );
		 Signal_Filter #(.FILTER_NUM (10))U4		//此信号设置10个系统脉冲时钟滤波
         (
			.CLK(CLOCK_50M),
			.RST_n(RST_n),
			.iSignal(iRGS_signalB),
			.oSignal(RGS_signalB)
		 );
wire RESR_signalA_H2L;
wire RESR_signalB_H2L;		 
wire RGS_signalA_H2L;
wire RGS_signalB_H2L;
wire RESR_signalA_L2H;
wire RESR_signalB_L2H;
wire RESR_signalZ_L2H;		 
wire RGS_signalA_L2H;
wire RGS_signalB_L2H;

		Detect  U5
		 (
		     .CLK(CLOCK_50M),
			  .RST_n(RST_n),
			  .Signal(RESR_signalA),//input from top
			  .H2L_Sig(RESR_signalA_H2L),//output to U1
			  .L2H_Sig(RESR_signalA_L2H)//output to U1
		 ); 
		Detect  U6
		 (
		     .CLK(CLOCK_50M),
			  .RST_n(RST_n),
			  .Signal(RESR_signalB),//input from top
			  .H2L_Sig(RESR_signalB_H2L),//output to U1
			  .L2H_Sig(RESR_signalB_L2H)//output to U1
		 ); 
 		Detect  U7
		 (
		     .CLK(CLOCK_50M),
			  .RST_n(RST_n),
			  .Signal(RESR_signalZ),//input from top
//			  .H2L_Sig(RESR_signalZ_H2L),//output to U1
			  .L2H_Sig(RESR_signalZ_L2H)//output to U1
		 );  		 
		Detect  U8
		 (
		     .CLK(CLOCK_50M),
			  .RST_n(RST_n),
			  .Signal(RGS_signalA),//input from top
			  .H2L_Sig(RGS_signalA_H2L),//output to U1
			  .L2H_Sig(RGS_signalA_L2H)//output to U1
		 ); 
		Detect  U9
		 (
		     .CLK(CLOCK_50M),
			  .RST_n(RST_n),
			  .Signal(RGS_signalB),//input from top
			  .H2L_Sig(RGS_signalB_H2L),//output to U1
			  .L2H_Sig(RGS_signalB_L2H)//output to U1
		 ); 
reg rRESR_signalA;
reg rRGS_signalA;
reg rRESR_signalZ;
always@(posedge CLOCK_50M)
begin
	rRESR_signalA=RESR_signalA_H2L | RESR_signalA_L2H | RESR_signalB_H2L | RESR_signalB_L2H;	
	rRGS_signalA=RGS_signalA_H2L | RGS_signalA_L2H | RGS_signalB_H2L | RGS_signalB_L2H;	
	rRESR_signalZ=RESR_signalZ_L2H;
end	
reg rSignal_Corotation;
always@(posedge RESR_signalA)
begin
	if(RESR_signalB==0)
		rSignal_Corotation=1'b1;
	else
		rSignal_Corotation=1'b0;
end 
assign oRESR_signalA=rRESR_signalA;
assign oRESR_signalZ=rRESR_signalZ;
assign oRGS_signalA=rRGS_signalA;

assign Signal_Corotation=rSignal_Corotation;
endmodule



