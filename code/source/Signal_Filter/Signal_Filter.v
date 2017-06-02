module Signal_Filter #(parameter FILTER_NUM = 10)(CLK,RST_n,iSignal,oSignal);

input CLK;//使用时钟为PLL倍频后的100MHz作为延时过滤时钟，
input RST_n;
input iSignal;
output oSignal;

/**************************************************************/
wire H2L_Sig;
wire L2H_Sig;

         Detect  U0
		 (
		     .CLK(CLK),
			  .RST_n(RST_n),
			  .Signal(iSignal),//input from top
			  .H2L_Sig(H2L_Sig),//output to U1
			  .L2H_Sig(L2H_Sig)//output to U1
		 );
wire signal;		 
		 Delay_Filter  #(.NUM(FILTER_NUM)) U1
		 (
		     .CLK(CLK),
			  .RST_n(RST_n),
			  .H2L_Sig(H2L_Sig),//from U0
			  .L2H_Sig(L2H_Sig),//from U0
			  .oSignal(signal)//output to U2
		 );
		 Detect  U2
		 (
		     .CLK(CLK),
			  .RST_n(RST_n),
			  .Signal(signal),//input from U1
			  .L2H_Sig(oSignal)//output to top
		 );


endmodule
