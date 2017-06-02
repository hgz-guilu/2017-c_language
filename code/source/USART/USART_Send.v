
module USART_Send(CLOCK_50M,RST_n,Frame_Start_Sig,Data_Send_Sig,Data,Tx_Pin);
input CLOCK_50M;
input RST_n;
input Frame_Start_Sig;
input Data_Send_Sig;
input [7:0]Data;
output Tx_Pin;
	
	Communicate_Send U1
	(
		.CLOCK_50M(CLOCK_50M),
		.RST_n(RST_n),
		.Frame_Start_Sig(Frame_Start_Sig),
		.Data_Send_Sig(Data_Send_Sig),
		.Data(Data),
		.Tx_Pin(Tx_Pin)
	);
	
	
endmodule 
