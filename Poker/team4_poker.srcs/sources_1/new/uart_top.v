module uart_top (/*AUTOARG*/
   // Outputs
   o_tx, o_tx_busy, o_rx_data, o_rx_valid,
   // Inputs
   i_rx, i_tx_data, i_tx_stb, clk, rst
   );
   
   output                   o_tx; // asynchronous UART TX
   input                    i_rx; // asynchronous UART RX
   
   output                   o_tx_busy;
   output [7:0]             o_rx_data;
   output                   o_rx_valid;
   
   input [23:0] i_tx_data;
   input                    i_tx_stb;
   
   input                    clk;
   input                    rst;
    

   parameter stIdle = 0;
   parameter stNib1 = 1;
   parameter stSPC = 3;
   parameter stSPC2 = 6;
   parameter stNL   = 9;
   parameter stCR   = 10;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 tfifo_empty;            // From tfifo_ of uart_fifo.v
   wire                 tfifo_full;             // From tfifo_ of uart_fifo.v
   wire [7:0]           tfifo_out;              // From tfifo_ of uart_fifo.v
   // End of automatics

   reg [7:0]            tfifo_in;
   wire                 tx_active;
   wire                 tfifo_rd;
   reg                  tfifo_rd_z;
   reg [23:0]  tx_data;
   integer               state;
   integer               clear_screen_state = 0;

   assign o_tx_busy = (state!=stIdle);
   
   always @ (posedge clk)
     if (rst) begin
       state <= stIdle;
       clear_screen_state <= 0;
     end else
       case (state)
         stIdle:
           if (i_tx_stb)
             begin
                state   <= stNib1;
                tx_data <= i_tx_data;
                clear_screen_state <= 0;
             end
         stSPC:
           if (~tfifo_full) state <= state + 1;
         stSPC2:
           if (~tfifo_full) state <= state + 1;
         stCR:
           if (~tfifo_full) state <= stIdle;
         default:
           if (~tfifo_full)
             begin
                if (state == stNib1 && tx_data[7:0] != 8'b11111111 && clear_screen_state < 22) //not stateIdls
                    clear_screen_state <= clear_screen_state + 1;
                else begin
                    state   <= state + 1;
                    tx_data <= {tx_data,4'b0000};
                end
             end
       endcase // case (state)

reg [3:0] suit;
reg [3:0] card_val;

function [7:0] fnNib2ASCII;
      input [3:0] suit;
      begin
         case (suit)
            4'b0000: fnNib2ASCII = "H"; //Hearts
            4'b0001: fnNib2ASCII = "D"; //Diamonds
            4'b0010: fnNib2ASCII = "C"; //Clubs
            4'b0011: fnNib2ASCII = "S"; //Spades
            4'b1110: fnNib2ASCII = "P"; //Player
            4'b1111: fnNib2ASCII = " ";
            default: fnNib2ASCII = "?"; //Invalid Value
         endcase // case (suit)
      end
   endfunction

   // Function to convert card value to card name
   function [7:0] fnCardValueToName;
      input [3:0] card_val;
      begin
         case (card_val)
            4'b0000: fnCardValueToName = "2";
            4'b0001: fnCardValueToName = "3";
            4'b0010: fnCardValueToName = "4";
            4'b0011: fnCardValueToName = "5";
            4'b0100: fnCardValueToName = "6";
            4'b0101: fnCardValueToName = "7";
            4'b0110: fnCardValueToName = "8";
            4'b0111: fnCardValueToName = "9";
            4'b1000: fnCardValueToName = "T"; //10
            4'b1001: fnCardValueToName = "J"; //Jack
            4'b1010: fnCardValueToName = "Q"; //Queen
            4'b1011: fnCardValueToName = "K"; //King
            4'b1100: fnCardValueToName = "A"; //Ace
            4'b1110: fnCardValueToName = "1";
            4'b1111:fnCardValueToName = " ";
            default: fnCardValueToName = "?"; //Invalid Value
         endcase
      end
   endfunction

   always @*
     case (state)
       stSPC:   tfifo_in = " ";
       stSPC2: tfifo_in = " ";
       stNL:    tfifo_in = "\n";
       stCR:    tfifo_in = "\r";
       default: 
       begin
           if (state == stNib1 && tx_data[7:0] != 8'b11111111 && clear_screen_state < 22)
             tfifo_in = "\n";
           else if (state % 3 == 1)
            tfifo_in = fnCardValueToName(tx_data[23:20]);
           else 
            tfifo_in = fnNib2ASCII(tx_data[23:20]);
       end
     endcase // case (state)
   
   assign tfifo_rd = ~tfifo_empty & ~tx_active & ~tfifo_rd_z;

   assign tfifo_wr = ~tfifo_full & (state!=stIdle);
   
   uart_fifo tfifo_ (// Outputs
                     .fifo_cnt          (),
                     .fifo_out          (tfifo_out[7:0]),
                     .fifo_full         (tfifo_full),
                     .fifo_empty        (tfifo_empty),
                     // Inputs
                     .fifo_in           (tfifo_in[7:0]),
                     .fifo_rd           (tfifo_rd),
                     .fifo_wr           (tfifo_wr),
                     /*AUTOINST*/
                     // Inputs
                     .clk               (clk),
                     .rst               (rst));

   always @ (posedge clk)
     if (rst)
       tfifo_rd_z <= 1'b0;
     else
       tfifo_rd_z <= tfifo_rd;

   uart uart_ (// Outputs
               .received                (o_rx_valid),
               .rx_byte                 (o_rx_data[7:0]),
               .is_receiving            (),
               .is_transmitting         (tx_active),
               .recv_error              (),
               .tx                      (o_tx),
               // Inputs
               .rx                      (i_rx),
               .transmit                (tfifo_rd_z),
               .tx_byte                 (tfifo_out[7:0]),
               /*AUTOINST*/
               // Inputs
               .clk                     (clk),
               .rst                     (rst));
   
endmodule // uart_top
// Local Variables:
// verilog-library-flags:("-y ../../osdvu/")
// End:

