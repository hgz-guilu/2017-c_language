module Communicate_Send
(
    CLOCK_50M, RST_n,
	 Frame_Start_Sig,Data_Send_Sig,Data,
	 Tx_Pin
);
 
     input CLOCK_50M;
	  input RST_n;
	  input Frame_Start_Sig;
	  input Data_Send_Sig;
	  input [7:0]Data;
	  output Tx_Pin;
	  

wire [7:0]Tx_Data;
wire Tx_En_Sig;
wire Tx_Done_Sig;	  

	  Tx_Buffered U0
	(
		.CLOCK_50M(CLOCK_50M),
		.RST_n(RST_n),
		.Frame_Start_Sig(Frame_Start_Sig),
		.Data_Send_Sig(Data_Send_Sig),
		.Data(Data),
		.Tx_Done_Sig(Tx_Done_Sig),
		.Tx_Data(Tx_Data),
		.Tx_En_Sig(Tx_En_Sig)		
	); 
	
	 /********************************************************/	  
	  wire BPS_CLK;
	 FrequencyGenerator #(.FREQUENCY_NUM(921600)) U1//���ʱ��Ƶ������
	(
			.CLOCK_50M(CLOCK_50M),
			.RST_n(RST_n),
			.Enable(Tx_En_Sig), 
			.CLK(BPS_CLK)
	);	  
  /**************************************************/  
	  Tx_Control_Module U2
	  (
	      .CLOCK_50M(CLOCK_50M),
			.RST_n(RST_n),
			.Tx_En_Sig( Tx_En_Sig ),    // input - from U0
			.Tx_Data( Tx_Data ),        // input - from U0
			.BPS_CLK( BPS_CLK ),        // input - from U1
			.Tx_Done_Sig( Tx_Done_Sig ),  // output - to U0
			.Tx_Pin( Tx_Pin)     // output - to top
	  );
	  
	  /***********************************/

endmodule

