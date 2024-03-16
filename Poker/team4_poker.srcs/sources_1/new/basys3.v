module basys3 (/*AUTOARG*/
   // Outputs
   RsTx, an, seg, led,
   // Inputs
   RsRx, sw, btnS, btnR, clk//, led//btnD
   );

`include "constants.v"
   
   wire [23:0] playerout;
   
   // USB-UART
   input        RsRx;
   output       RsTx;
   //output reg [3:0] an;
   //output reg [6:0] seg;

   // Misc.
   input  [7:0] sw;
   output [15:0] led;
   //output [7:0] led;
   input        btnS;                 // single-step instruction
   input        btnR;                 // arst
  
  
  // input       btnD;                 // input for bet  //new
   
   // Logic
   input        clk;                  // 100MHz
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [seq_width-1:0] seq_tx_data;         // From seq_ of seq.v
   wire                 seq_tx_valid;           // From seq_ of seq.v
   wire [7:0]           uart_rx_data;           // From uart_top_ of uart_top.v
   wire                 uart_rx_valid;          // From uart_top_ of uart_top.v
   wire                 uart_tx_busy;           // From uart_top_ of uart_top.v
   // End of automatics
   
   wire        rst;
   wire        arst_i;
   wire [17:0] clk_dv_inc;
   wire [31:0] display_value;


//   wire validation;  //new
//   wire  arst_ii; //new 
//   reg [1:0] arst_foo; //new



   reg [1:0]   arst_ff;
   reg [16:0]  clk_dv;
   reg         clk_en;
   reg         clk_en_d;
      
   reg [7:0]   inst_wd;
   reg         inst_vld;
   reg [2:0]   step_d;

   reg [7:0]   inst_cnt;
   
   reg [1:0] inst_vld_d;
   //reg btn;
   
   // ===========================================================================
   // Asynchronous Reset
   // ===========================================================================

   assign arst_i = btnR;
   assign rst = arst_ff[0];
   
   always @ (posedge clk or posedge arst_i)
     if (arst_i)
       arst_ff <= 2'b11;
     else
       arst_ff <= {1'b0, arst_ff[1]};


  // ===========================================================================
   // Asynchronous Bet Amount Signal validation
   // ===========================================================================

//   assign arst_ii = btnD;  //new 
//   assign validation = arst_foo[0]; //new
   
//   always @ (posedge clk or posedge arst_i) //new
//     if (arst_ii) //new
//       arst_foo <= 2'b11; //new
//     else //new
//       arst_foo <= {1'b0, arst_foo[1]}; //new

   // ===========================================================================
   // 763Hz timing signal for clock enable
   // ===========================================================================

   assign clk_dv_inc = clk_dv + 1;
   
   always @ (posedge clk)
     if (rst)
       begin
          clk_dv   <= 0;
          clk_en   <= 1'b0;
          clk_en_d <= 1'b0;
       end
     else
       begin
          clk_dv   <= clk_dv_inc[16:0];
          clk_en   <= clk_dv_inc[17];
          clk_en_d <= clk_en;
       end
   
   // ===========================================================================
   // Instruction Stepping Control
   // ===========================================================================

   always @ (posedge clk)
     if (rst)
       begin
          inst_wd[7:0] <= 0;
          step_d[2:0]  <= 0;
       end
     else if (clk_en)
       begin
          inst_wd[7:0] <= sw[7:0];
          step_d[2:0]  <= {btnS, step_d[2:1]};
       end

   always @ (posedge clk) begin
     if (rst)
       inst_vld <= 1'b0;
     else
       inst_vld <= ~step_d[0] & step_d[1] & clk_en_d;
     inst_vld_d[1] = inst_vld_d[0];
     inst_vld_d[0] <= inst_vld;
   end
   
   always @ (posedge clk)
     if (rst)
       inst_cnt <= 0;
     else if (inst_vld)
       inst_cnt <= inst_cnt + 1;

    //if (btn == 1)
    //    btn <= 0;

   //assign led[7:0] = inst_cnt[7:0];
   
   
//always @ (posedge step_d[0]) begin
//     btn <= 1;
//   end
   // ===========================================================================
   // Sequencer
   // ===========================================================================

//   seq seq_ (// Outputs
//             .o_tx_data                 (seq_tx_data[seq_dp_width-1:0]),
//             .o_tx_valid                (seq_tx_valid),
//             // Inputs
//             .i_tx_busy                 (uart_tx_busy),
//             .i_inst                    (inst_wd[seq_in_width-1:0]),
//             .i_inst_valid              (inst_vld),
//             /*AUTOINST*/
//             // Inputs
//             .clk                       (clk),
//             .rst                       (rst));
   
   // ===========================================================================
   // UART controller
   // ===========================================================================

   poker (
   //Outputs
   .playerout (playerout),
   .display_value (display_value),
   //Inputs
   .clk (clk),
   .valid (inst_vld_d[0]),
   //bet_valid (validation), //new
   .busy (uart_tx_busy),
   ._led (led)
   );
   
   uart_top uart_top_ (// Outputs
                       .o_tx            (RsTx),
                       .o_tx_busy       (uart_tx_busy),
                       //.o_rx_data       (uart_rx_data[7:0]),
                       //.o_rx_valid      (uart_rx_valid),
                       // Inputs
                       .i_rx            (RsRx),
                       .i_tx_data       (playerout),
                       .i_tx_stb        (inst_vld_d[1]),
                       /*AUTOINST*/
                       // Inputs
                       .clk             (clk),
                       .rst             (rst));

   output reg [3:0] an;
   output reg [6:0] seg;
   
    reg [1:0]   clk_display;
    
    reg [3:0] LED_BCD;
    
    //Segment Patterns
    always @* begin
        case(LED_BCD)
            4'b0000: seg = 7'b0000001; // "0"  
            4'b0001: seg = 7'b1001111; // "1" 
            4'b0010: seg = 7'b0010010; // "2" 
            4'b0011: seg = 7'b0000110; // "3" 
            4'b0100: seg = 7'b1001100; // "4" 
            4'b0101: seg = 7'b0100100; // "5" 
            4'b0110: seg = 7'b0100000; // "6" 
            4'b0111: seg = 7'b0001111; // "7" 
            4'b1000: seg = 7'b0000000; // "8"  
            4'b1001: seg = 7'b0000100; // "9" 
            default: seg = 7'b1111111; // " "
        endcase
    end
       
   always @ (posedge clk) begin
      clk_display   <= clk_display + clk_dv_inc[17]; //381 Hz //not
   end
    
    always @* begin
        case(clk_display)
            2'b00: begin
                an = 4'b0111; 
                LED_BCD = (display_value / 1000) % 10;  
            end
            2'b01: begin
                an = 4'b1011; 
                LED_BCD = (display_value / 100) % 10;  
            end
            2'b10: begin
                an = 4'b1101; 
                LED_BCD = (display_value / 10) % 10;  
            end
            2'b11: begin
                an = 4'b1110; 
                LED_BCD = display_value % 10;  
            end             
        endcase
    end
endmodule // basys3
// Local Variables:
// verilog-library-flags:("-f ../input.vc")
// End:
