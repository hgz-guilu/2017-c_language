`default_nettype none 
module SEG7_DISPLAY (
    input wire  	   iClk,
	 input wire       Reset,
    input wire   [6:0] iSEG0,
    input wire   [6:0] iSEG1,
    input wire   [6:0] iSEG2,
    input wire   [6:0] iSEG3,
	 input wire   [6:0] iSEG4,
	 input wire   [6:0] iSEG5,
	 input wire   [6:0] iSEG6,
	 input wire   [6:0] iSEG7,
	
	 output  reg[7:0] oSEL,
    output  reg[7:0] oSEG
); 


	reg[2:0]counter;
	reg[19:0]counter2;
	parameter max_n = 20'd150_000;  //500hZ
	parameter NIXIE_TUBE_NUM=3'd7;  //点亮几个数码管的个数
	always@(posedge iClk or negedge Reset)
	if(!Reset)
	begin
		counter<=0;
		counter2<=0;
	end
	else
	begin
			
		if(counter2 >= max_n )
		begin
			counter2 <= 0;
			if(counter==NIXIE_TUBE_NUM)
				counter<=0;
			else
				counter <= counter+3'd1;
		end
		else counter2 <= counter2+20'd1;
	
			case(counter)
			3'd0: 	begin
					oSEG <= {1'b1,iSEG0};	
					oSEL  <= 8'b11111110;
					end
			3'd1: 	begin
					oSEG <= {1'b1,iSEG1};	
					oSEL  <= 8'b11111101;
					end
			3'd2: 	begin
					oSEG <= {1'b1,iSEG2};	
					oSEL  <= 8'b11111011;
					end
			3'd3: 	begin
					oSEG <= {1'b1,iSEG3};	
					oSEL  <= 8'b11110111;
					end
			3'd4: 	begin
					oSEG <= {1'b1,iSEG4};	
					oSEL  <= 8'b11101111;
					end
			3'd5: 	begin
					oSEG <= {1'b1,iSEG5};	
					oSEL  <= 8'b11011111;
					end
			3'd6: 	begin
					oSEG <= {1'b1,iSEG6};	
					oSEL  <= 8'b10111111;
					end					
			3'd7: 	begin
					oSEG <= {1'b1,iSEG7};	
					oSEL  <= 8'b01111111;
					end
			default:begin
					oSEG <= {1'b1,iSEG7};	
					oSEL  <= 8'b01111111;
					end
		endcase
	end
	
endmodule