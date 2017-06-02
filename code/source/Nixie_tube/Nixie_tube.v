`default_nettype none
module Nixie_tube(
    //////////// CLOCK //////////
    input               CLOCK_50,
	 input					RESET,
	 input             [31:0]num,
    //////////// SEG7 //////////
    output       [7:0]  DISP_SEG,
    output       [7:0]  DISP1_SEG,
    output       [7:0]  DISP_SEL
);

	//	All inout port turn to tri-state
assign  DISP1_SEG=DISP_SEG;

//--------------计数�----------------------------------------------//	
	wire [3:0]num1;
	wire [3:0]num2;
	wire [3:0]num3;
	wire [3:0]num4;
	wire [3:0]num5;
	wire [3:0]num6;
	wire [3:0]num7;
	wire [3:0]num8;

	Count Count_inst(
		.reg_num(num),
		.num1(num1),
		.num2(num2),
		.num3(num3),
		.num4(num4),
		.num5(num5),
		.num6(num6),
		.num7(num7),
		.num8(num8)
		);

//--------------数码�-----------------------------------------------//	
	wire [6:0] HEX0;
	wire [6:0] HEX1;
	wire [6:0] HEX2;
	wire [6:0] HEX3;
	wire [6:0] HEX4;
	wire [6:0] HEX5;
	wire [6:0] HEX6;
	wire [6:0] HEX7;



    // 七段数码管译�
    SEG7_LUT u7(.oSEG(HEX7),.iDIG(num8));
    SEG7_LUT u6(.oSEG(HEX6),.iDIG(num7));
    SEG7_LUT u5(.oSEG(HEX5),.iDIG(num6));
    SEG7_LUT u4(.oSEG(HEX4),.iDIG(num5));
    SEG7_LUT u3(.oSEG(HEX3),.iDIG(num4));
    SEG7_LUT u2(.oSEG(HEX2),.iDIG(num3));
    SEG7_LUT u1(.oSEG(HEX1),.iDIG(num2));
    SEG7_LUT u0(.oSEG(HEX0),.iDIG(num1));
    
   // 七段数码管静态显示转动态显�
   SEG7_DISPLAY SEG7_DISPLAY_inst0(
   
        .iClk(CLOCK_50),
		  .Reset(RESET),
        .iSEG0(HEX0),      
        .iSEG1(HEX1),         
        .iSEG2(HEX2),      
        .iSEG3(HEX3),
		  .iSEG4(HEX4),
		  .iSEG5(HEX5),
		  .iSEG6(HEX6),
		  .iSEG7(HEX7),
        .oSEL(DISP_SEL[7:0]),       
        .oSEG(DISP_SEG)      
   );

//------------------ ---------------------------------------------------------//
	

//---------------------------------------------------------------------------//	
	
endmodule
