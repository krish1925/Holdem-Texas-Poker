module uart_fifo (/*AUTOARG*/
   // Outputs
   fifo_cnt, fifo_out, fifo_full, fifo_empty,
   // Inputs
   fifo_in, fifo_rd, fifo_wr, clk, rst
   );

   parameter size  = 1024;
   parameter sizew = 10;

   output [sizew-1:0] fifo_cnt;
   output [7:0]       fifo_out;
   output             fifo_full;
   output             fifo_empty;
   
   input [7:0]        fifo_in;
   input              fifo_rd;
   input              fifo_wr;
   
   input              clk;
   input              rst;
   
   (* ram_style = "block" *) reg [7:0] mem [0:size-1];

   reg [sizew-1:0] wp;
   reg [sizew-1:0] rp;
   
   reg [sizew-1:0] fifo_cnt;
   reg             fifo_full;
   reg             fifo_empty;   
   reg [7:0]       fifo_out;

   wire            wr;
   wire            rd;

   assign wr = (fifo_wr & ~fifo_full);
   assign rd = (fifo_rd & ~fifo_empty);
   
   always @ (posedge clk)
     if (rst)
       begin
          wp[sizew-1:0]       <= {(sizew){1'b0}};
          rp[sizew-1:0]       <= {(sizew){1'b0}};
          fifo_cnt[sizew-1:0] <= {(sizew){1'b0}};
          fifo_full           <= 1'b0;
          fifo_empty          <= 1'b1;
       end
     else
       begin
          wp[sizew-1:0]  <= wp[sizew-1:0] + wr;
          rp[sizew-1:0]  <= rp[sizew-1:0] + rd;
          case ({wr,rd})
            2'b10: 
              begin
                 fifo_cnt   <= fifo_cnt + 1;
                 fifo_full  <= (fifo_cnt==(size-2));
                 fifo_empty <= 1'b0;
              end
            2'b01:
              begin
                 fifo_cnt   <= fifo_cnt - 1;
                 fifo_full  <= 1'b0;
                 fifo_empty <= (fifo_cnt==1);
              end
          endcase // case ({wr,rd})
       end // else: !if(rst)

   always @ (posedge clk)
     if (fifo_wr & ~fifo_full)
       mem[wp] <= fifo_in[7:0];

   always @ (posedge clk)
     fifo_out[7:0] <= mem[rp];
   
endmodule // uart_fifo

