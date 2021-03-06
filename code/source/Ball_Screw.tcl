#------------------GLOBAL--------------------#
set_global_assignment -name FAMILY "Cyclone IV E"
set_global_assignment -name DEVICE EP4CE6F17C8
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
set_global_assignment -name ENABLE_INIT_DONE_OUTPUT OFF

set_global_assignment -name RESERVE_ALL_UNUSED_PINS_WEAK_PULLUP "AS INPUT TRI-STATED"
set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DATA0_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DATA1_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_FLASH_NCE_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DCLK_AFTER_CONFIGURATION "USE AS REGULAR IO"

#复位引脚  
# RESET 按键就是KEY1
set_location_assignment	PIN_E15	-to RST_n

#DEBIG IO
set_location_assignment	PIN_N3	-to USART_RX_Pin 
set_location_assignment	PIN_P3	-to USART_TX_Pin
set_location_assignment	PIN_N5	-to LAB_TCK 
set_location_assignment	PIN_P6	-to LAB_TMS
set_location_assignment	PIN_M6	-to LAB_TDI 
set_location_assignment	PIN_N6	-to LAB_TDO 

#时钟引脚 50M
set_location_assignment	PIN_E1	-to CLOCK_50M 



#LED对应的引脚
set_location_assignment	PIN_J14	-to LEDR[0]
set_location_assignment	PIN_J13	-to LEDR[1]
set_location_assignment	PIN_K11	-to LEDR[2]
set_location_assignment	PIN_L14	-to LEDR[3]
set_location_assignment	PIN_L13	-to LEDR[4]
set_location_assignment	PIN_M12	-to LEDR[5]
set_location_assignment	PIN_N14	-to LEDR[6]
set_location_assignment	PIN_P14	-to LEDR[7]
set_location_assignment	PIN_N13	-to LEDR[8]
set_location_assignment	PIN_N12	-to LEDR[9]
set_location_assignment	PIN_N11	-to LEDR[10]
set_location_assignment	PIN_P11	-to LEDR[11]
set_location_assignment	PIN_M11	-to LEDR[12]
set_location_assignment	PIN_M10	-to LEDR[13]
set_location_assignment	PIN_N9	-to LEDR[14]
set_location_assignment	PIN_M9	-to LEDR[15]
set_location_assignment	PIN_L9	-to LEDR[16]
set_location_assignment	PIN_K9	-to LEDR[17]

set_location_assignment	PIN_F15	-to LEDG[0]
set_location_assignment	PIN_F16	-to LEDG[1]
set_location_assignment	PIN_G15	-to LEDG[2]
set_location_assignment	PIN_G16	-to LEDG[3]
set_location_assignment	PIN_J16	-to LEDG[4]
set_location_assignment	PIN_J15	-to LEDG[5]
set_location_assignment	PIN_K16	-to LEDG[6]
set_location_assignment	PIN_K15	-to LEDG[7]
set_location_assignment	PIN_L16	-to LEDG[8]

#按键对应的引脚
set_location_assignment	PIN_E15	 -to KEY[0]
set_location_assignment	PIN_E16	 -to KEY[1]
set_location_assignment	PIN_M16  -to KEY[2]
set_location_assignment	PIN_M15  -to KEY[3]

set_location_assignment	PIN_E9   -to SW[0]
set_location_assignment	PIN_D9   -to SW[1]
set_location_assignment	PIN_C9   -to SW[2]
set_location_assignment	PIN_E10  -to SW[3]
set_location_assignment	PIN_F10  -to SW[4]
set_location_assignment	PIN_C11  -to SW[5]
set_location_assignment	PIN_D11  -to SW[6]
set_location_assignment	PIN_D12  -to SW[7]
set_location_assignment	PIN_E11  -to SW[8]
set_location_assignment	PIN_C14  -to SW[9]
set_location_assignment	PIN_D14  -to SW[10]
set_location_assignment	PIN_F11  -to SW[11]
set_location_assignment	PIN_F13  -to SW[12]
set_location_assignment	PIN_F14  -to SW[13]
set_location_assignment	PIN_F9   -to SW[14]
set_location_assignment	PIN_G11  -to SW[15]
set_location_assignment	PIN_J11  -to SW[16]
set_location_assignment	PIN_J12  -to SW[17]

#串口对应的引脚
set_location_assignment	PIN_M1	-to UART_RXD
set_location_assignment	PIN_D1	-to USART_TXD
#UART_TXD

#数码管对应的引脚
#数码管7段+小数点
set_location_assignment	PIN_C3	-to DISP0_SEG[0]
set_location_assignment	PIN_E6	-to DISP0_SEG[1]
set_location_assignment	PIN_D8	-to DISP0_SEG[2]
set_location_assignment	PIN_D6	-to DISP0_SEG[3]
set_location_assignment	PIN_C6	-to DISP0_SEG[4]
set_location_assignment	PIN_D5	-to DISP0_SEG[5]
set_location_assignment	PIN_F8	-to DISP0_SEG[6]
set_location_assignment	PIN_E8	-to DISP0_SEG[7]

set_location_assignment	PIN_G1	-to DISP1_SEG[0]
set_location_assignment	PIN_F1	-to DISP1_SEG[1]
set_location_assignment	PIN_B3	-to DISP1_SEG[2]
set_location_assignment	PIN_B1	-to DISP1_SEG[3]
set_location_assignment	PIN_C2	-to DISP1_SEG[4]
set_location_assignment	PIN_F2	-to DISP1_SEG[5]
set_location_assignment	PIN_G2	-to DISP1_SEG[6]
set_location_assignment	PIN_A2	-to DISP1_SEG[7]
#8位数码管的8个控制位
set_location_assignment	PIN_D3	-to DISP_SEL[0]
set_location_assignment	PIN_D4	-to DISP_SEL[1]
set_location_assignment	PIN_E5  -to DISP_SEL[2]
set_location_assignment	PIN_F3	-to DISP_SEL[3]
set_location_assignment	PIN_K2	-to DISP_SEL[4]
set_location_assignment	PIN_K1	-to DISP_SEL[5]
set_location_assignment	PIN_J2	-to DISP_SEL[6]
set_location_assignment	PIN_J1	-to DISP_SEL[7]


#2*16LCD液晶显示屏
set_location_assignment	PIN_A3	-to LCD_DATA[0]
set_location_assignment	PIN_B4	-to LCD_DATA[1]
set_location_assignment	PIN_A4	-to LCD_DATA[2]
set_location_assignment	PIN_B5	-to LCD_DATA[3]
set_location_assignment	PIN_A5	-to LCD_DATA[4]
set_location_assignment	PIN_B6	-to LCD_DATA[5]
set_location_assignment	PIN_A6	-to LCD_DATA[6]
set_location_assignment	PIN_B7	-to LCD_DATA[7]
set_location_assignment	PIN_A7	-to LCD_EN
set_location_assignment	PIN_B8	-to LCD_RW
set_location_assignment	PIN_A8	-to LCD_RS



