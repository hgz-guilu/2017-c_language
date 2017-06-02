module Ball_Screw(
						CLOCK_50M,RST_n,USART_TX_Pin,USART_RX_Pin,LEDG
						);

input CLOCK_50M;
input RST_n;
input USART_RX_Pin;
output USART_TX_Pin;
output [8:0]LEDG;
/***************************************************************/
wire RESR_signalA;
wire RESR_signalB;
wire RESR_signalZ;
wire RGS_signalA;
wire RGS_signalB;
	Signal_Source U0
	(
		.CLOCK_50M(CLOCK_50M),
		.RST_n(RST_n),
		.RESR_signalA(RESR_signalA),
		.RESR_signalB(RESR_signalB),
		.RESR_signalZ(RESR_signalZ),
		.RGS_signalA(RGS_signalA),
		.RGS_signalB(RGS_signalB)
	);
wire oRESR_signalA;
wire oRESR_signalZ;
wire oRGS_signalA;
wire Signal_Corotation;
   Signal_Filter_Top  U1
	(
		.CLOCK_50M(CLOCK_50M),
		.RST_n(RST_n),
		.iRESR_signalA(RESR_signalA),
		.iRESR_signalB(RESR_signalB),
		.iRESR_signalZ(RESR_signalZ),
		.iRGS_signalA(RGS_signalA),
		.iRGS_signalB(RGS_signalB),
		.oRESR_signalA(oRESR_signalA),
		.oRESR_signalZ(oRESR_signalZ),
		.oRGS_signalA(oRGS_signalA),
		.Signal_Corotation(Signal_Corotation)
	);
wire Frame_Start_Sig;
wire Data_Send_Sig;
wire [7:0]Data;

	Measure U2
	(
		.CLOCK_50M(CLOCK_50M),
		.RST_n(RST_n),
		.iRESR_signalA(oRESR_signalA),//from U1
		.iRESR_signalZ(oRESR_signalZ),//from U1
		.iRGS_signalA(oRGS_signalA),//from U1
		.Signal_Corotation(Signal_Corotation),//from U1
		.Frame_Start_Sig(Frame_Start_Sig), //to U3
		.Data_Send_Sig(Data_Send_Sig),   //to U3
		.Data(Data),						//to U3		
		.LED(LEDG)
	);
	USART_Send U3
	(
		.CLOCK_50M(CLOCK_50M),
		.RST_n(RST_n),
		.Frame_Start_Sig(Frame_Start_Sig),//from U2
		.Data_Send_Sig(Data_Send_Sig),//from U2
		.Data(Data),						//from U2
		.Tx_Pin(USART_TX_Pin) //to TOP
	);

endmodule