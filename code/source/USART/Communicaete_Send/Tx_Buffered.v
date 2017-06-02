module Tx_Buffered(CLOCK_50M,RST_n,Frame_Start_Sig,Data_Send_Sig,Data,Tx_Done_Sig,Tx_Data,Tx_En_Sig);

 input CLOCK_50M;
 input RST_n;
 input Frame_Start_Sig;//一个时钟的高电平脉冲，代表一帧数据开始到来
 input Data_Send_Sig;//一个脉冲信号，表示一个8位数据到来
 input [7:0]Data;//定义一个8x8的数据缓冲区，用来暂存圆光栅和光栅尺的脉冲计数 个数	 
 input Tx_Done_Sig;//代表一个字节数据发送完成，
 output [7:0]Tx_Data;//发送的字节
 output Tx_En_Sig;//发送时钟使能信号，可以在不发送数据时，让发送时钟停止

/***************************************************************/
`define FRAME_HEAD0_INDEX      		8'd0
`define FRAME_HEAD1_INDEX      		8'd1
`define FRAME_TYPE_INDEX       		8'd2
`define FRAME_DATA_LEN_INDEX   		8'd3
`define FRAME_DATA_INDEX       		8'd4
`define FRAME_DATA_END_INDEX       	(`FRAME_DATA_INDEX+`FRAME_DATA_LEN-8'd1)
`define FRAME_CHECK_SUM0_INDEX 		8'd8
`define FRAME_CHECK_SUM1_INDEX 		8'd9
`define FRAME_TAIL0_INDEX			   8'd10
`define FRAME_TAIL1_INDEX			   8'd11
`define FRAME_END_INDEX			      8'd12

`define FRAME_HEAD0                 8'hff
`define FRAME_HEAD1                 8'hfe
`define FRAME_TYPE                  8'h01   //表示是数据，0x00表示是命令，0x02表示是错误信息
`define FRAME_DATA_LEN              8'd4
//数据内容
//16位校验和
`define FRAME_TAIL0                 8'hfe
`define FRAME_TAIL1                 8'hff
/**************************************************************/
    /*************************************
	接收数据，保存在缓冲中，当结束完毕，rec_complete高电平
	****************************************************/
	reg rec_start;//开始接收一字节数据
	reg rec_complete;//一帧数据全部接收完成
	reg [7:0]data_count;
	reg [7:0]rData[20:0];
	reg [15:0]check_sum;

	always @(posedge CLOCK_50M or negedge RST_n)
		if(!RST_n)
		begin			
			data_count<=8'd0;
			rec_start<=1'b0;
			rec_complete<=1'b0;
			check_sum<=16'd0;
		end
		else if(Frame_Start_Sig)
		begin
			rec_start<=1'b1;
			data_count<=8'd0;
			rec_complete<=1'b0;
			check_sum<=16'd0;
		end
		else if(rec_start)
		begin
			if(Data_Send_Sig)
			begin
				check_sum<=check_sum+Data;//校验和
				rData[data_count]<=Data;//数据缓冲
				data_count<=data_count+8'd1;
				if(data_count>=(`FRAME_DATA_LEN-1'd1))
				begin
					rec_complete<=1'b1;
					rec_start<=1'b0;
				end				 
			end			
		end
/******************************************************************
Tx_Done_Sig信号，因为在Tx_Control_Module模块中，它的默认状态是低电平，只有在接收到一个字节的
数据后才会拉高一个系统脉冲时钟，所以在发送第一个字节时，不能通过Tx_Done_Sig信号，判断，不然
就会陷入互斥，死等的状态，
而理论上第一个字节发送时，发送绝对是空闲的，所以就不用判断Tx_Done_Sig信号了，不过之后的字节要判断，
以保证发送缓冲区中的字节不会被覆盖掉。
********************************************************************/
reg [7:0]i;
reg tx_enable;
reg [7:0]rTx_Data;
reg frame_send_complete;
	always @(posedge CLOCK_50M or negedge RST_n)
		if(!RST_n)
		begin
			tx_enable<=1'b0;
			rTx_Data<=8'h00;
			frame_send_complete=1'b0;
			i=8'd0;
		end
		else if(!rec_complete)//等待一帧数据全部接收
		begin
			tx_enable<=1'b0;
			rTx_Data<=8'h00;
			frame_send_complete=1'b0;
			i=8'd0;
		end
		else if(frame_send_complete==1'b0)//一帧数据全部接收完成，开始发送
		begin
			tx_enable<=1'b1;
			if(i==8'd0)
			begin rTx_Data<=`FRAME_HEAD0; i<=i+8'd1;end//发送第一字节数据
			if(Tx_Done_Sig )//上一字节数据是否发送完成，Tx_Done_Sig是反馈的一个系统时钟的高脉冲信号
			begin				
				case (i)
				//	`FRAME_HEAD0_INDEX: 
					`FRAME_HEAD1_INDEX:      begin rTx_Data<=`FRAME_HEAD1; i<=i+8'd1;end
					`FRAME_TYPE_INDEX:       begin rTx_Data<=`FRAME_TYPE; i<=i+8'd1;end
					`FRAME_DATA_LEN_INDEX:   begin rTx_Data<=`FRAME_DATA_LEN; i<=i+8'd1;end
	
					`FRAME_CHECK_SUM0_INDEX: begin rTx_Data<=check_sum[15:8]; i<=i+8'd1;end
					`FRAME_CHECK_SUM1_INDEX: begin rTx_Data<=check_sum[7:0]; i<=i+8'd1;end
					`FRAME_TAIL0_INDEX:      begin rTx_Data<=`FRAME_TAIL0; i<=i+8'd1;end
					`FRAME_TAIL1_INDEX:      begin rTx_Data<=`FRAME_TAIL1; i<=i+8'd1;end
					`FRAME_END_INDEX: frame_send_complete=1'b1;//一帧数据传输完成
					default:begin
									if(i>=`FRAME_DATA_INDEX && i<=`FRAME_DATA_END_INDEX)
									begin
										rTx_Data<=rData[i-`FRAME_DATA_INDEX];
										i<=i+8'd1;
									end
									else if(i!=8'd0)
										frame_send_complete=1'b1; 
							  end
				endcase			
			end			
		end
		else //if(frame_send_complete==1'b1)
			tx_enable<=1'b0;//开始发送数据

		
    /*************************************/
	 
	 assign Tx_En_Sig = tx_enable;
	 assign Tx_Data = rTx_Data;
	 
	 /*************************************/
	 

endmodule
