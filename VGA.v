module VGA
(
input CLK,
input init , 
input [2:0]num , 
output reg[3:0]red,
output reg[3:0]green,
output reg[3:0]blue,
output H_sync,
output V_sync
    );
    wire clk;
Divider #(.N(4))CLKD(CLK,clk);
    localparam H_SYNC_PULSE      =   96  , 
              H_BACK_PORCH      =   48  ,
              H_ACTIVE_TIME     =   640 ,
              H_FRONT_PORCH     =   16  ,
              H_LINE_PERIOD     =   800 ;
    
                 
    localparam V_SYNC_PULSE      =   2   , 
               V_BACK_PORCH      =   33  ,
               V_ACTIVE_TIME     =   480 ,
               V_FRONT_PORCH     =   10  ,
               V_FRAME_PERIOD    =   525 ;
               
    localparam IMAGE_WIDTH=320,
               IMAGE_HEIGHT=240,
               IMAGE_PIX_NUM=76800;
               
    reg [11:0]     h_cnt; 
    reg [11:0]     v_cnt;
    
    wire           flag   ; 

    
    
    always @(posedge clk or negedge init)
    begin
        if(!init)
            h_cnt <=  12'd0   ;
        else if(h_cnt == H_LINE_PERIOD - 1'b1)
            h_cnt <=  12'd0   ;
        else
            h_cnt <=  h_cnt + 1'b1  ;                
    end                
    assign H_sync =   (h_cnt < H_SYNC_PULSE) ? 1'b0 : 1'b1    ; 
    
   always @(posedge clk or negedge init)
    begin
        if(!init)
            v_cnt <=  12'd0   ;
        else if(v_cnt == V_FRAME_PERIOD - 1'b1)
            v_cnt <=  12'd0   ;
        else if(h_cnt ==H_LINE_PERIOD - 1'b1)
            v_cnt <= v_cnt + 1'b1  ;
        else
            v_cnt <=v_cnt ;                        
    end                
    assign V_sync =   (v_cnt < V_SYNC_PULSE) ? 1'b0 : 1'b1    ; 
 
    reg     [16:0]      addr      ;
    reg     [11:0]      data      ;
    wire    [11:0]      data0      ;
    wire    [11:0]      data1      ;
    wire    [11:0]      data2      ;
    //wire    [11:0]      data3      ;
    //wire    [11:0]      data4      ;
    blk_mem_gen_0 image0 (.clka(clk),.addra(addr),.douta(data0));
    blk_mem_gen_1 image1 (.clka(clk),.addra(addr),.douta(data1));
    blk_mem_gen_2 image2 (.clka(clk),.addra(addr),.douta(data2));
   // blk_mem_gen_3 image3 (.clka(clk),.addra(addr),.douta(data3));
    //blk_mem_gen_3 image4 (.clka(clk),.addra(addr),.douta(data4));
    //blk_mem_gen_5 image5 (.clka(clk),.addra(addr),.douta(data5));
    always@(num)
    begin
    case(num)
    0:data=data0;
    1:data=data1;
    2:data=data2;
    //3:data=data3;
   // 4:data=data4;
    //5:data=data5;
    default:data=data0;
    endcase
    end
    localparam H_OFFSET=160,V_OFFSET=120;
    assign flag =  (h_cnt >= (H_SYNC_PULSE +H_BACK_PORCH+H_OFFSET                ))  &&
                            (h_cnt <= (H_SYNC_PULSE +H_BACK_PORCH + H_ACTIVE_TIME+H_OFFSET))  && 
                            (v_cnt >= (V_SYNC_PULSE +V_BACK_PORCH+V_OFFSET                  ))  &&
                            (v_cnt <= (V_SYNC_PULSE +V_BACK_PORCH +V_OFFSET+V_ACTIVE_TIME))  ; 
    
   always @(posedge clk or negedge init)
                            begin
                                if(!init) 
                                    addr  <=  17'd0 ;
                                else if(flag)     
                                    begin
                                        if(h_cnt >= (H_SYNC_PULSE +H_BACK_PORCH+H_OFFSET                       )  && 
                                           h_cnt <= (H_SYNC_PULSE +H_BACK_PORCH+H_OFFSET +IMAGE_WIDTH  - 1'b1)  &&
                                           v_cnt >= (V_SYNC_PULSE +V_BACK_PORCH+V_OFFSET                        )  && 
                                           v_cnt <= (V_SYNC_PULSE +V_BACK_PORCH+V_OFFSET +IMAGE_HEIGHT - 1'b1)  )
                                            begin
                                                red       <=data[11:8]    ;
                                                green     <=data[7:4]     ; 
                                                blue      <= data[3:0]      ; 
                                                if(addr ==IMAGE_PIX_NUM - 1'b1)
                                                    addr  <=  17'd0 ;
                                                else
                                                    addr  <= addr  +  1'b1 ;        
                                            end
                                        else
                                           begin
                                               red<=4'b1111;
                                               green<=4'b0000;
                                               blue<=4'b0000;
                                               addr<=addr;
                                           end                        
                                    end
                                else
                                    begin
                                      red<=4'b1111;
                                      green<=4'b0000;
                                      blue<=4'b0000;
                                      addr<=addr;
                                    end          
                            end
                            

endmodule
