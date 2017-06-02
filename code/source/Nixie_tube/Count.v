module Count(

input [31:0]reg_num,
output [3:0]num1,
output [3:0]num2,
output [3:0]num3,
output [3:0]num4,
output [3:0]num5,
output [3:0]num6,
output [3:0]num7,
output [3:0]num8
);
reg [31:0]reg_num1;
reg [31:0]reg_num2;
always@(reg_num)
begin
  reg_num1=reg_num%10000;
  reg_num2=reg_num/10000;
end
assign num1=(reg_num1%10);
assign num2=(reg_num1/10)% 10;
assign num3=(reg_num1/100)% 10;
assign num4=(reg_num1/1000);

assign num5=reg_num2% 10;
assign num6=(reg_num2 /10)% 10;
assign num7=(reg_num2/100)% 10;
assign num8=(reg_num2 /1000);


endmodule