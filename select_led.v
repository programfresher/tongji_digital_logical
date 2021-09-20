module select_led
(
input [3:0] iData,
input [2:0] iSel,
output [6:0] oData,
output [7:0] oSel
);
    
    assign oSel[7]=~(iSel[2] & iSel[1] & iSel[0]);
    assign oSel[6]=~(iSel[2] & iSel[1] & (~iSel[0]));
    assign oSel[5]=~(iSel[2] & (~iSel[1]) & iSel[0]);
    assign oSel[4]=~(iSel[2] & (~iSel[1]) & (~iSel[0]));
    assign oSel[3]=~((~iSel[2]) & iSel[1] & iSel[0]);
    assign oSel[2]=~((~iSel[2]) & iSel[1] & (~iSel[0]));
    assign oSel[1]=~((~iSel[2]) & (~iSel[1]) & iSel[0]);
    assign oSel[0]=~((~iSel[2]) & (~iSel[1]) & (~iSel[0]));

    display7 dis(iData,oData);
endmodule
