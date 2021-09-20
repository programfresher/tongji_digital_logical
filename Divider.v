module Divider #(parameter N=10000)(
input clk,
output reg clk_n
    );
integer count=0;
always@(posedge clk)
begin
if(count==N/2-1)
begin
clk_n=~clk_n;
count=0;
end
else
count=count+1;
end
endmodule


