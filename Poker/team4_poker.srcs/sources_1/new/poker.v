`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2024 01:04:47 PM
// Design Name: 
// Module Name: poker
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module poker(
    //Outputs
    playerout,
    
    //Inputs
    clk,
    valid
    );
    output[15:0] playerout;
    //reg[7:0] out;
    
    input        clk;
    input valid;
    
    reg [51:0] card_array;
    integer p1 [1:0];
    integer p2 [1:0];
    integer currp [1:0];
    reg player;
    
    integer community [4:0];
    integer rndStart = 0;
    
    integer counter;
    
    integer seed;
    
//    function randCard;
//        input [51:0] card_array;
//        integer card;
//        integer count;
//        begin
//            card = $random % 52 + 1;
//            //while(card_array[card] == 1 & count < 100) begin
//            //    card = $random % 52 + 1;
//            //    count = count + 1;
//            //end
//            card_array[card] = 1; 
//            randCard = card;
//        end
//    endfunction
    
//    function cardConvert;
//        input integer card;
//        integer value;
//        integer suit;
//        begin
//            value = card % 13;
//            suit = card / 13;
//            $display("%b", {4'b0011, suit[3:0]});
//            cardConvert = {4'b0011, suit[3:0]};//{4'b0001, 4'b0011};//
//        end
//    endfunction
    
    function integer randCard;
        input integer s;
        input [51:0] card_array;
        integer card, count;
        begin
            count = 0;
            //card = $random(s) % 52; // Pick a random card
            card = s % 52;
            while ((card_array[card] == 1) && (count < 52)) begin
                card = s % 52; // Pick another if already chosen
                count = count + 1;
            end
            if (count < 52) begin
                card_array[card] = 1; // Mark card as chosen
            end
            else begin
                card = 1; // Indicate failure to find a unique card
            end
            randCard = card;
        end
    endfunction      
    
    function [7:0] cardConvert;
        input integer card;
        integer value, suit;
        begin
            value = card % 13;
            suit = card / 13;
            cardConvert = {value[3:0], suit[3:0]};
        end
    endfunction
     
    assign playerout = {cardConvert(currp[0]), cardConvert(currp[1])};
    
    initial begin
        card_array = 0;
        seed = 12345;
        counter = 0;
        player = 0;
    end
    
    always @ (posedge valid) begin
        if (rndStart == 4)
                rndStart = 0;
        if (rndStart != 0)
                    rndStart = rndStart + 1;
        if(rndStart == 0) begin
            p1[0] = randCard(counter, card_array);
            p1[1] = randCard(counter + 1, card_array);
            
            p2[0] = randCard(counter + 2, card_array);
            p2[1] = randCard(counter + 3, card_array);
            
            community[0] = randCard(counter + 4, card_array);
            community[1] = randCard(counter + 5, card_array);
            community[2] = randCard(counter + 6, card_array);
            community[3] = randCard(counter + 7, card_array);
            community[4] = randCard(counter + 8, card_array);
            rndStart = 1;
        end
        
        if (player) begin 
            currp[0] = p1[0];
            currp[1] = p1[1];
        end
        else begin
            currp[0] = p2[0];
            currp[1] = p2[1];
        end
        
        //currp[1] = player ? p1[1] : p2[1]; 
        //currp[0] = player ? p1[0] : p2[0];
        player = ~player;
        
       end
       
       always @ (posedge clk) begin
        counter = counter + 1;
        if (counter + 10 < 0) begin
            counter = 0;
        end
       end
       
endmodule
