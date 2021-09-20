module mp3(
    input clk,
    input DREQ,
    input init,
    input[15:0]volume,
    input[1:0]num,
    output reg XRSET,
    output reg XCS,
    output reg XDCS,
    output reg SI,
    output reg SCLK
);
parameter  start_end = 0;
parameter  start_con = 1;
parameter  reset = 2;
parameter  data_start = 3;
parameter  data_end = 4;

wire clk_mp3;
Divider #(100)mp3_div(clk, clk_mp3);


reg[2:0]rem_num = 0;
reg rst=0;
reg[12:0]address;
reg[31:0] data;
wire[31:0] data0;
wire[31:0] data1;
wire[31:0] data2;
//wire[31:0] data3;
//wire[31:0] data4;
//wire[31:0] data5;
reg[31:0] Data;
blk_mem_gen_7 music0(clk, address, data0);
blk_mem_gen_8 music1(clk, address, data1);
blk_mem_gen_9 music2(clk, address, data2);
//blk_mem_gen_8 music3(.clka(clk), .addra(address), .douta(data3));
//blk_mem_gen_9 music4(.clka(clk), .addra(address), .douta(data4));
//blk_mem_gen_5 music5(.clka(clk),.addra(addr),.douta(data5));
always@(*)
case(num)
0:data = data0;
1:data = data1;
2:data = data2;
//3:data = data3;
//4:data = data4;
//5:data=data5;
default:data = data0;
endcase

    reg[63:0]initial_cmd = { 32'h02000800,32'h020B6666 };
    integer state = start_end;
    integer count = 0;
    integer cmd_count = 0;

    always @(posedge clk_mp3)
    begin
    rem_num <= num;
    if (~init || rem_num != num||rst)
        begin
        rst<=0;
        SCLK <= 0;
        count <= 0;
        address <= 0;
        cmd_count <= 0;
        state <= reset;
        XCS <= 1;
        XDCS <= 1;
        XRSET <= 0;
        end
    else 
    begin
        case(state)
        
        start_end:
        begin
        SCLK <= 0;
        if (cmd_count >= 2)
            state <= data_start;
        else if (DREQ)
            begin
            SI <= initial_cmd[63];
            state <= start_con;
            count <= 1;
            initial_cmd <= {initial_cmd[62:0], initial_cmd[63]};
            XCS <= 0;
            end
        end

        start_con :
        begin
        if (DREQ)
            begin
            if (SCLK)
                begin
                if (count >= 32)
                    begin
                    cmd_count <= cmd_count + 1;
                    state <= start_end;
                    count <= 0;
                    XCS <= 1;
                    end
                else
                    begin
                    SI <= initial_cmd[63];
                    count <= count + 1;
                    initial_cmd <= {initial_cmd[62:0], initial_cmd[63]};
                    end
                end
                SCLK <= ~SCLK;
            end
        end

        reset :
        begin
        if (count < 1000)
            count <= count + 1;
        else
            begin
            count <= 0;
            XRSET <= 1;
            state <= start_end;
            end
        end

        data_start :
        begin
        if (volume[15:0]!= initial_cmd[15:0])
            begin
            initial_cmd[63:0] <= {16'h020B,volume[15:0],initial_cmd[63:32]};
            state <= start_end;
            cmd_count<= 1;
            XCS<=1;
            rst<=1;
            end
        else if (DREQ)
            begin
            SCLK <= 0;
            SI <= data[31];
            Data <= {data[30:0], data[31]};
            XDCS <= 0;
            XCS <= 0;
            count <= 1;
            state <= data_end;
            end
            end

        data_end :
        begin
        if (SCLK)
            begin
            if (count >= 32)
                begin
                state <= data_start;
                XDCS <= 1;
                address <= address + 1;
                end
            else
            begin
            SI <= Data[31];
            count <= count + 1;
            Data <= {Data[30:0], Data[31]};
            end
            end
            SCLK <= ~SCLK;
            end
        default:;
        endcase
    end
    end
endmodule