module bluetooth(
    input rxd,
    input clk,
    output reg[1:0]num,
    output reg[15:0]volume
    );
    reg [7:0] data;
    localparam WAIT=0,
               START=1,
               END=2;

    reg [2:0]current,next;
    integer count;

    wire clk_9600;
    Divider #(100000000/9600)bluetooth_CLK(
    clk,
    clk_9600
        );
    always@(*)
    begin
        next=current;
      case(current)
        WAIT: if(!rxd)next=START; 
        START: if(count==7)next=END; 
        END: next=WAIT;
        default: next=WAIT;
      endcase
    end
     
    always@(posedge clk_9600)
      if(current ==START)
        count<=count+1; 
      else if(current==WAIT ||current==END)
        count<=0;

    always@(posedge clk_9600)
    begin
        current<=next;
    end
    
    always@(posedge clk_9600)
      if(current ==START)
      begin
        data[6:0]<=data[7:1]; 
        data[7]<=rxd;
      end
      
          localparam prev=50;
          localparam nex=51;
          localparam up=48;
          localparam down=49;
          
          always@(posedge clk_9600)
          if(current==END)
          begin
          if(data==nex&&num>=0&&num<2)
              num<=num+1;
          else if(data==nex)
              num<=2;
          if(data==prev&&num>0&&num<=2)
              num<=num-1;
          else if(data==prev)
              num<=0;
          end
          
          always@(posedge clk_9600)
          if(current==END)
          begin
          if(data==up)
              volume=(volume==16'h0000)?16'h0000:volume-16'h3333;
          else if(data==down)
              volume=(volume==16'hffff)?16'hffff:volume+16'h3333;
          end
         
endmodule
