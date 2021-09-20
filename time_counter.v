module time_counter
(
    input clk,
    input init,
    input stay,
    output [7:0] oSel,
    output [6:0] oData
 );
    reg [2:0] iSel=3'b000;
    reg [3:0] iData;
    wire sel_frequency;
    Divider #(100000) sel_divider(clk,sel_frequency); 
    reg [3:0] sec_l=4'b0000, sec_h=4'b0000, min_l=4'b0000, min_h=4'b0000, hon_l=4'b0000, hon_h=4'b0000;
    reg [2:0]count=3'b000;
    always@(posedge sel_frequency)
    begin
      case(count)
            3'b000:
            begin
            iData<=sec_l;
            count<=count+1;
            end
            3'b001:
            begin
            iData<=sec_h;
            count<=count+2;
            end
            3'b011:
            begin
            iData<=min_l;
            count<=count+1;
            end
            3'b100:
            begin
            iData<=min_h;
            count<=count+2;
            end
            3'b110:
            begin
            iData<=hon_l;
            count<=count+1;
            end
            3'b111:
            begin
            iData<=hon_h;
            count<=count+1;
            end
            default:
            begin
            iData<=sec_l;
            count<=0;
            end
       endcase
       iSel<=count;    
    end
    
    wire cnt_fre;
    Divider #(100000000) div1(clk,cnt_fre);
    always @(posedge cnt_fre or negedge init)
    begin
        if(!init)
        begin
            sec_l<=4'b0000;
            sec_h<=4'b0000;
            min_l<=4'b0000;
            min_h<=4'b0000;
            hon_l<=4'b0000;
            hon_h<=4'b0000;         
        end
        else if(!stay)
        begin
             if(sec_l==4'b1001)//秒的低位=9
                    begin
                        sec_l<=4'b0000;
                        if(sec_h==4'b0101)//秒的高位=5
                        begin
                            sec_h<=4'b0000;
                            if(min_l==4'b1001)//分的低位=9
                            begin
                                min_l<=4'b0000;
                                if(min_h==4'b0101)//分的高位=5
                                begin
                                    min_h<=4'b0000;
                                    if(hon_l==4'b0011)//时的高位=2
                                    begin
                                        if(hon_h==4'b0010)//时的低位=3
                                        begin
                                            hon_h<=4'b0000;
                                            hon_l<=4'b0000;
                                        end
                                        else
                                            hon_h<=hon_h+4'b0001;
                                    end
                                    else
                                    begin
                                    hon_l<=hon_l+4'b0001;
                                    end
                                end
                                else
                                min_h<=min_h+4'b0001;
                                end
                    else
                    min_l<=min_l+4'b0001;
                end
                else
                    sec_h=sec_h+4'b0001;
            end
            else
                sec_l<=sec_l+4'b0001;
        end
  end
select_led sel(iData,iSel,oData,oSel);
endmodule
