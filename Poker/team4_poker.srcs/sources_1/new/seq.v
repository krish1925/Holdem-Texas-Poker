module seq (/*AUTOARG*/
   // Outputs
   o_tx_data, o_tx_valid,
   // Inputs
   i_tx_busy, i_inst, i_inst_valid, clk, rst
   );

`include "seq_definitions.v"
   
   // UART interface
   output [seq_dp_width-1:0] o_tx_data;
   output                    o_tx_valid;
   input                     i_tx_busy;

   // Instruction interface
   input [seq_in_width-1:0]  i_inst;
   input                     i_inst_valid;

   input                     clk;
   input                     rst;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [alu_width-1:0] alu_data;               // From alu_ of seq_alu.v
   wire                 alu_valid;              // From alu_ of seq_alu.v
   wire [alu_width-1:0] rf_data_a;              // From rf_ of seq_rf.v
   wire [alu_width-1:0] rf_data_b;              // From rf_ of seq_rf.v
   // End of automatics

   wire [seq_im_width-1:0] inst_const;
   wire [seq_op_width-1:0] inst_op;
   wire [seq_rn_width-1:0] inst_ra;
   wire [seq_rn_width-1:0] inst_rb;
   wire [seq_rn_width-1:0] inst_rc;

   wire                    inst_op_push;
   wire                    inst_op_send;
   wire                    inst_op_add;
   wire                    inst_op_mult;

   wire [seq_rn_width-1:0] rf_wsel;
   wire                    rf_wstb;

   wire                    alu_valid_in;
   
   // ===========================================================================
   // Instruction Decoding
   // ===========================================================================

   assign inst_const = i_inst[seq_im_width-1:0];
   assign inst_op    = i_inst[seq_in_width-1:seq_in_width-seq_op_width];
   assign inst_rc    = i_inst[seq_rn_width*1-1:seq_rn_width*0];
   assign inst_rb    = i_inst[seq_rn_width*2-1:seq_rn_width*1];
   assign inst_ra    = i_inst[seq_rn_width*3-1:seq_rn_width*2];

   assign inst_op_push = (inst_op == seq_op_push);
   assign inst_op_add  = (inst_op == seq_op_add);
   assign inst_op_mult = (inst_op == seq_op_mult);
   assign inst_op_send = (inst_op == seq_op_send);

   // ===========================================================================
   // Register File
   // ===========================================================================

   assign rf_wsel = inst_op_push ? inst_ra : inst_rc;
   assign rf_wstb = alu_valid;
      
   seq_rf rf_ (// Outputs
               .o_data_a                (rf_data_a[alu_width-1:0]),
               .o_data_b                (rf_data_b[alu_width-1:0]),
               // Inputs
               .i_sel_a                 (inst_ra[seq_rn_width-1:0]),
               .i_sel_b                 (inst_rb[seq_rn_width-1:0]),
               .i_wstb                  (rf_wstb),
               .i_wdata                 (alu_data[alu_width-1:0]),
               .i_wsel                  (rf_wsel[seq_rn_width-1:0]),
               /*AUTOINST*/
               // Inputs
               .clk                     (clk),
               .rst                     (rst));

   // ===========================================================================
   // ALU
   // ===========================================================================

   assign alu_valid_in = i_inst_valid & (inst_op_push | inst_op_add | inst_op_mult);
   
   seq_alu alu_ (// Outputs
                 .o_data                (alu_data[alu_width-1:0]),
                 .o_valid               (alu_valid),
                 // Inputs
                 .i_data_a              (rf_data_a[alu_width-1:0]),
                 .i_data_b              (rf_data_b[alu_width-1:0]),
                 .i_op                  (inst_op[seq_op_width-1:0]),
                 .i_const               (inst_const[seq_im_width-1:0]),
                 .i_valid               (alu_valid_in),
                 /*AUTOINST*/
                 // Inputs
                 .clk                   (clk),
                 .rst                   (rst));
   
   // ===========================================================================
   // Send Instruction
   // ===========================================================================

   assign o_tx_data  = 16'b1010101010101010;//rf_data_a[seq_dp_width-1:0];
   assign o_tx_valid = i_inst_valid & inst_op_send & ~i_tx_busy;
   
endmodule // seq
