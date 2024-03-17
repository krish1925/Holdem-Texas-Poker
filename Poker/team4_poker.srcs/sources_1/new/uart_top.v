module uart_top (/*AUTOARG*/
   // Outputs
   o_tx, o_tx_busy, o_rx_data, o_rx_valid,
   // Inputs
   i_rx, i_tx_data, i_tx_stb, clk, rst
   );

`include "constants.v"
   
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
   
   //SV SV SV
   //SV SV
   
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
   
//      reg [7:0]            card1, card2;
//      reg                  pick_card;
//      reg [51:0]           card_array;


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
                //if (!clear_screen_state || clear_screen_state >= 20) begin
                    state   <= stNib1;
                    tx_data <= i_tx_data;
                    clear_screen_state <= 0;
                //end
                //else if (~tfifo_full) clear_screen_state <= clear_screen_state + 1;
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

//   function [7:0] fnNib2ASCII;
//      input [5:0] din;
      
//      begin
//            suit = din[5:4];
//            card_val = din[3:0];
//         case (suit)
         
////           8'h0: fnNib2ASCII = " ";
////           8'h1: fnNib2ASCII = "1";
////           8'h2: fnNib2ASCII = "2";
////           8'h3: fnNib2ASCII = "3";
////           8'h4: fnNib2ASCII = "4";
////           8'h5: fnNib2ASCII = "5";
////           8'h6: fnNib2ASCII = "6";
////           8'h7: fnNib2ASCII = "7";
////           8'h8: fnNib2ASCII = "8";
////           8'h9: fnNib2ASCII = "9";
////           8'hA: fnNib2ASCII = "T";
////           8'hB: fnNib2ASCII = "J";
////           8'hC: fnNib2ASCII = "Q";
////           8'hD: fnNib2ASCII = "K";
////           8'hE: fnNib2ASCII = "A";
////           8'hF: fnNib2ASCII = "F";
//         endcase // case (char)
//      end
//   endfunction // fnNib2ASCII

function [7:0] fnNib2ASCII;
      input [3:0] suit;
      begin
            //suit = din[5:4];
            //card_val = din[3:0];
         case (suit)
            4'b0000: fnNib2ASCII = "H"; //Hearts
            4'b0001: fnNib2ASCII = "D"; //Diamonds
            4'b0010: fnNib2ASCII = "C"; //Clubs
            4'b0011: fnNib2ASCII = "S"; //Spades
           4'b0100: fnNib2ASCII = "a"; //Hearts
            4'b0101: fnNib2ASCII = "P"; //Diamonds
            4'b0110: fnNib2ASCII = "c"; //Clubs
            4'b0111: fnNib2ASCII = "d";
            4'b1000: fnNib2ASCII = "e"; //Hearts
           4'b1001: fnNib2ASCII = "f"; //Diamonds
            4'b1010: fnNib2ASCII = "g"; //Clubs
            4'b1011: fnNib2ASCII = "h"; //Spades
            4'b1100: fnNib2ASCII = "i"; //Hearts
            4'b1101: fnNib2ASCII = "j"; //Diamonds
            4'b1110: fnNib2ASCII = "k"; //Clubs
            4'b1111: fnNib2ASCII = " ";
            default: fnNib2ASCII = "?";
         endcase // case (suit)
      end
   endfunction
//01000011 00100001
   // Function to convert card value to card name
   function [7:0] fnCardValueToName;
      input [3:0] card_val;
      begin
         case (card_val)
            4'b0000: fnCardValueToName = "2";//8'b00110010; // "2"
            4'b0001: fnCardValueToName = "3";//8'b00110100; // "3"
            4'b0010: fnCardValueToName = "4";//8'b00110101; // "4"
            4'b0011: fnCardValueToName = "5";// 8'b00110110; // "5"
            4'b0100: fnCardValueToName = "6";//8'b00110111; // "6"
            4'b0101: fnCardValueToName = "7";//8'b00111000; // "7"
            4'b0110: fnCardValueToName = "8";// 8'b00111001; // "8"
            4'b0111: fnCardValueToName = "9";//8'b00111010; // "9"
            4'b1000: fnCardValueToName = "T";// 8'b00110001; // "10"
            4'b1001: fnCardValueToName = "J";//8'b00101010; // "J" (Jack)
            4'b1010: fnCardValueToName = "Q";//8'b00100011; // "Q" (Queen)
            4'b1011: fnCardValueToName = "K";// 8'b01001011; // "K" (King)
            4'b1100: fnCardValueToName = "A";//8'b01000001; // "A" (Ace)
            4'b1101: fnCardValueToName = "1";//8'b01000001; // "A" (Ace)
            4'b1111:fnCardValueToName = " ";
            default: fnCardValueToName = "0";//8'b00110000; // "0" (Invalid value)
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

//module uart_top (
//   // Outputs
//   o_tx, o_tx_busy, o_rx_data, o_rx_valid,
//   // Inputs
//   i_rx, i_tx_data, i_tx_stb, clk, rst
//);

//   output                   o_tx; // asynchronous UART TX
//   input                    i_rx; // asynchronous UART RX
   
//   output                   o_tx_busy;
//   output [7:0]             o_rx_data;
//   output                   o_rx_valid;
   
//   input [seq_width-1:0] i_tx_data;
//   input                    i_tx_stb;
   
//   input                    clk;
//   input                    rst;
   
//   // Define parameters for state machine
//   parameter stIdle = 0;
//   parameter stNib1 = 1;
//   parameter stNL   = num_nib+1;

//   // Define internal registers and wires
//   reg [7:0]            tfifo_in;
//   reg [2:0]            state;
//   reg [1:0]            suit;
//   reg [3:0]            card_val;
//   reg [7:0]            card1, card2;
//   reg                  pick_card;
//   reg [51:0]           card_array;

//wire                 tfifo_empty;            // From tfifo_ of uart_fifo.v
//   wire                 tfifo_full;             // From tfifo_ of uart_fifo.v
//   wire [7:0]           tfifo_out;              // From tfifo_ of uart_fifo.v
//   // End of automatics

//   //reg [7:0]            tfifo_in;
//   wire                 tx_active;
//   wire                 tfifo_rd;
//   reg                  tfifo_rd_z;
//   reg [seq_width-1:0]  tx_data;
//   //reg [2:0]               state;

//   // Output the busy signal based on the current state
//   assign o_tx_busy = (state!=stIdle);

//   // State machine to handle UART communication
//   always @ (posedge clk)
//     if (rst)
//       state <= stIdle;
//     else
//       case (state)
//         stIdle:
//           if (i_tx_stb)
//             begin
//                state   <= stNib1;
//                pick_card <= 1'b1;
//             end
//         stNL:
//           begin
//              pick_card <= 1'b0;
//              state <= stIdle;
//           end
//         default:
//           if (~tfifo_full)
//             begin
//                state   <= state + 1;
//             end
//       endcase
   

//function [7:0] fnNib2ASCII;
//      input [5:0] din;
//      begin
//            suit = din[5:4];
//            card_val = din[3:0];
//         case (suit)
//            2'b00: fnNib2ASCII = 8'b00000000; //Hearts
//            2'b01: fnNib2ASCII = 8'b00000001; //Diamonds
//            2'b10: fnNib2ASCII = 8'b00000010; //Clubs
//            2'b11: fnNib2ASCII = 8'b00000011; //Spades
//         endcase // case (suit)
//      end
//   endfunction

//   // Function to convert card value to card name
//   function [7:0] fnCardValueToName;
//      input [3:0] card_val;
//      begin
//         case (card_val)
//            4'b0000: fnCardValueToName = 8'b00110010; // "2"
//            4'b0001: fnCardValueToName = 8'b00110100; // "3"
//            4'b0010: fnCardValueToName = 8'b00110101; // "4"
//            4'b0011: fnCardValueToName = 8'b00110110; // "5"
//            4'b0100: fnCardValueToName = 8'b00110111; // "6"
//            4'b0101: fnCardValueToName = 8'b00111000; // "7"
//            4'b0110: fnCardValueToName = 8'b00111001; // "8"
//            4'b0111: fnCardValueToName = 8'b00111010; // "9"
//            4'b1000: fnCardValueToName = 8'b00110001; // "10"
//            4'b1001: fnCardValueToName = 8'b00101010; // "J" (Jack)
//            4'b1010: fnCardValueToName = 8'b00100011; // "Q" (Queen)
//            4'b1011: fnCardValueToName = 8'b01001011; // "K" (King)
//            4'b1100: fnCardValueToName = 8'b01000001; // "A" (Ace)
//            default: fnCardValueToName = 8'b00110000; // "0" (Invalid value)
//         endcase
//      end
//   endfunction

//   // Update tfifo_in based on the current state
//   always @*
//     case (state)
//       stNL:    tfifo_in = " ";
//       default: tfifo_in = fnNib2ASCII(tx_data[seq_width-1:0]);
//     endcase
   
//   // Pick two random numbers from 1 to 52 and remove them from the array
//   always @ (posedge clk) begin
//      if (pick_card) begin
//         card1 = $random % 52 + 1;
//         card2 = $random % 52 + 1;
//         card_array[card1 - 1] = 0;
//         card_array[card2 - 1] = 0;
//      end
//   end

//   // Transmit the suit and rank of the picked cards over UART
//   always @ (posedge clk) begin
//      if (state == stNib1) begin
//         tfifo_in = card1;
//      end
//      if (state == stNL) begin
//         tfifo_in = card2;
//      end
//   end

//   // Instantiate UART FIFO and UART modules
//   uart_fifo tfifo_ (// Outputs
//                     .fifo_cnt          (),
//                     .fifo_out          (tfifo_out[7:0]),
//                     .fifo_full         (tfifo_full),
//                     .fifo_empty        (tfifo_empty),
//                     // Inputs
//                     .fifo_in           (tfifo_in[7:0]),
//                     .fifo_rd           (tfifo_rd),
//                     .fifo_wr           (tfifo_wr),
//                     /*AUTOINST*/
//                     // Inputs
//                     .clk               (clk),
//                     .rst               (rst));

//   always @ (posedge clk)
//     if (rst)
//       tfifo_rd_z <= 1'b0;
//     else
//       tfifo_rd_z <= tfifo_rd;

//   uart uart_ (// Outputs
//               .received                (o_rx_valid),
//               .rx_byte                 (o_rx_data[7:0]),
//               .is_receiving            (),
//               .is_transmitting         (tx_active),
//               .recv_error              (),
//               .tx                      (o_tx),
//               // Inputs
//               .rx                      (i_rx),
//               .transmit                (tfifo_rd_z),
//               .tx_byte                 (tfifo_out[7:0]),
//               /*AUTOINST*/
//               // Inputs
//               .clk                     (clk),
//               .rst                     (rst));
   
//endmodule // uart_top
