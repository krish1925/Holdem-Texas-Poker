module seq_rf (/*AUTOARG*/
   // Outputs
   o_data_a, o_data_b,
   // Inputs
   i_sel_a, i_sel_b, i_wstb, i_wdata, i_wsel, clk, rst
   );
   
`include "seq_definitions.v"
   
   output [alu_width-1:0]   o_data_a;
   output [alu_width-1:0]   o_data_b;

   input [seq_rn_width-1:0] i_sel_a;
   input [seq_rn_width-1:0] i_sel_b;

   input                    i_wstb;
   input [alu_width-1:0]    i_wdata;
   input [seq_rn_width-1:0] i_wsel;
   
   input                    clk;
   input                    rst;

   reg [alu_width-1:0]      rf [0:seq_num_regs-1];
   integer                  i;
   
   always @ (posedge clk)
     if (rst)
       begin
          for (i=0;i<seq_num_regs;i=i+1)
            rf[i] <= 0;
       end
     else if (i_wstb)
       rf[i_wsel] <= i_wdata;

   assign o_data_a = rf[i_sel_a];
   assign o_data_b = rf[i_sel_b];
   
endmodule // seq_rf
