module controller(
input rxd,
input clk,
input init_VGA,
output [3:0]red,
output [3:0]green,
output [3:0]blue,
output H_sync,
output V_sync,
input DREQ,
input init_mp3,
output XRSET,
output XCS,
output XDCS,
output SI,
output SCLK,
input stay,
output [7:0] oSel,
output [6:0] oData
    );
//��������䲿��
wire[1:0]num;
wire[15:0]volume;
bluetooth uart(rxd,clk,num,volume);
//VGA���Ʋ���
VGA vga(clk,init_VGA,num,red,green,blue,H_sync,V_sync);
//mp3���Ʋ���
mp3 MM(clk,DREQ,init_mp3,volume,num,XRSET,XCS,XDCS,SI,SCLK);
//��ʱ����
time_counter TIME(clk,init_mp3,stay,oSel,oData);
endmodule

