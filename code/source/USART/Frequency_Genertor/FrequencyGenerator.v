module FrequencyGenerator #(parameter FREQUENCY_NUM=32'd1_000_000)//输出时钟频率设置
						(
						CLOCK_50M,RST_n,Enable,CLK
						);
input CLOCK_50M;
input RST_n;
input Enable;
output CLK;


/***********************************************************************/
`define CLOCK   32'd50_000_000 //系统时钟
`define CLK_K  (`CLOCK/FREQUENCY_NUM)
`define CLK_HARF (`CLK_K>>1)
`define CLK_KF (`CLK_K*FREQUENCY_NUM)
`define ENABLE 1'b1
`define DISABLE 1'b0
/**********************************************************************/

reg [31:0]reg_a;
reg [31:0]reg_b;
always @(posedge CLOCK_50M or negedge RST_n)
  if(!RST_n)
  begin
    reg_a=32'd0;
	 reg_b=32'd0;
  end
  else if(Enable==`DISABLE)
  begin
    reg_a=32'd0;
	 reg_b=32'd0;
  end
  else
  begin
    reg_b=((reg_a+`CLK_KF)/`CLOCK+reg_b)%`CLK_K;
	 reg_a=(reg_a+`CLK_KF)%`CLOCK;	 	 
  end
reg rCLK;
//占空比50%
always@(posedge CLOCK_50M or negedge RST_n)
  if(!RST_n)
  begin
    rCLK<=1'b0;
  end
  else 
  begin
    if(reg_b>=`CLK_HARF && rCLK==1'b0)
	 begin
	   rCLK<=1'b1;
	 end
	 else if(reg_b<`CLK_HARF && rCLK==1'b1)
	   rCLK<=1'b0;
  end
  //占空比一个系统时钟
reg [1:0]rCLK_L2H;
always@(posedge CLOCK_50M or negedge RST_n)
  if(!RST_n)
  begin
    rCLK_L2H=2'b00;
  end
  else
  begin
	 rCLK_L2H[0]<=rCLK;
	 rCLK_L2H[1]<=rCLK_L2H[0];
  end
assign CLK=(rCLK_L2H==2'b01)?1'b1:1'b0;
/**********************************************************/

endmodule