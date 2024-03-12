module seq_alu (/*AUTOARG*/
   // Outputs
   o_data, o_valid,
   // Inputs
   i_data_a, i_data_b, i_op, i_const, i_valid, clk, rst
   );
`include "seq_definitions.v"
   
   output [alu_width-1:0]    o_data;
   output                    o_valid;

   input [alu_width-1:0]     i_data_a;
   input [alu_width-1:0]     i_data_b;
   input [seq_op_width-1:0]  i_op;
   input [seq_im_width-1:0]  i_const;
   input                     i_valid;
   
   input                     clk; // only used if alu is pipelined
   input                     rst; // only used if alu is pipelined

   reg [alu_width-1:0]       o_data;
   reg                       o_valid;
   
   wire [alu_width-1:0]      mult_data; 
   wire                      mult_valid;

   wire [alu_width-1:0]      add_data;
   wire                      add_valid;
   
   always @* // Verilog-2001 style
     case (i_op)
       seq_op_push: o_data = {i_data_a, i_const}; // upper bits truncated
       seq_op_add:  o_data = add_data;
       seq_op_mult: o_data = mult_data;
       default:     o_data = i_data_a;
     endcase // case (i_op)

   always @* // Verilog-2001 style
     case (i_op)
       seq_op_push: o_valid = i_valid;
       seq_op_add:  o_valid = add_valid;
       seq_op_mult: o_valid = mult_valid;
       default:     o_valid = i_valid;
     endcase // case (i_op)

   seq_add add_ (// Outputs
                 .o_data                (add_data),
                 .o_valid               (add_valid),
                 /*AUTOINST*/
                 // Inputs
                 .i_data_a              (i_data_a[alu_width-1:0]),
                 .i_data_b              (i_data_b[alu_width-1:0]),
                 .i_valid               (i_valid),
                 .clk                   (clk),
                 .rst                   (rst));

   seq_mult mult_ (// Outputs
                   .o_data              (mult_data),
                   .o_valid             (mult_valid),
                   /*AUTOINST*/
                   // Inputs
                   .i_data_a            (i_data_a[alu_width-1:0]),
                   .i_data_b            (i_data_b[alu_width-1:0]),
                   .i_valid             (i_valid),
                   .clk                 (clk),
                   .rst                 (rst));
   
endmodule // seq_alu
