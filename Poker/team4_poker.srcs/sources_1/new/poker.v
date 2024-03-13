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
    valid,
    busy
    );
    output[23:0] playerout;
    //reg[7:0] out;
    
    input        clk;
    input valid;
    input busy;



    input [15:0] sw;


    
    reg [51:0] card_array;
    integer p1 [1:0];
    integer p2 [1:0];
    integer currp [2:0];
    reg player;
    integer bet_player1;
    integer bet_player2;
    integer money_p1;
    integer money_p2;
    integer pot;


    integer winner;
    
     // Winner determination logic
      integer winner_value = 0;
      integer p1_hand_value = 20;
      integer p2_hand_value = 20;
    
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






//function integer sortcards;
//            input integer cards [6:0];
//           // input integer [6:0] cards;
//            integer i, j, temp;

//            begin
//                // Sort cards in ascending order
//                for (i = 0; i < 4; i = i + 1) begin
//                    for (j = 0; j < 4 - i; j = j + 1) begin
//                        if (cards[j] > cards[j + 1]) begin
//                            temp = cards[j];
//                            cards[j] = cards[j + 1];
//                            cards[j + 1] = temp;
//                        end
//                    end
//                end
//            end
//            sortcards = cards
//    endfunction
    
// function to check if there is a royal flush return 20 if not found 
    function integer checkroyalflush;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer straightflush;
        integer i;

        begin
            // Call checkstraightflush function
            straightflush = checkstraightflush(playercard1, playercard2, community1, community2, community3);

            // Check if it's a straight flush and if any card is an ace (card % 13 = 12)
            if (straightflush != 20) begin
                integer cards[5];
                cards[0] = playercard1;
                cards[1] = playercard2;
                cards[2] = community1;
                cards[3] = community2;
                cards[4] = community3;

                for (i = 0; i < 5; i = i + 1) begin
                    if ((cards[i] % 13) == 12) begin
                        checkroyalflush = 12; // Royal flush found
                        return;
                    end
                end
            end

            checkroyalflush = 20; // Not a royal flush
        end
    endfunction


//    //function to check if there is a straight flush
    function integer checkstraightflush;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer straight;
        integer flush;

        begin
            // Call checkstraight function
            straight = checkstraight(playercard1, playercard2, community1, community2, community3);
            // Call checkflush function
            flush = checkflush(playercard1, playercard2, community1, community2, community3);

            // Check if it's both a straight and a flush
            if (straight != 20 && flush != 20) begin
                checkstraightflush = straight; // Straight flush found
            end 
            else begin
                checkstraightflush = 20; // Not a straight flush
            end
        end
    endfunction


//    // Function to check if there is a 4 of a kind 20 if not found, returns value of 4 of a kind
    function integer check4ofakind;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer cards[5];
        integer i, j, temp;

        begin
            // Merge player and community cards
            cards[0] = playercard1 % 13;
            cards[1] = playercard2 % 13;
            cards[2] = community1 % 13;
            cards[3] = community2 % 13;
            cards[4] = community3 % 13;

            // Perform simple sorting of the cards
            for (i = 0; i < 5; i = i + 1) begin
                for (j = 0; j < 4 - i; j = j + 1) begin
                    if (cards[j] > cards[j + 1]) begin
                        // Swap values
                        temp = cards[j];
                        cards[j] = cards[j + 1];
                        cards[j + 1] = temp;
                    end
                end
            end

            // Check if last 4 cards are equal
            if ((cards[1] == cards[2]) && (cards[2] == cards[3]) && (cards[3] == cards[4])) begin
                check4ofakind = cards[2]; // 4 of a kind found
                return;
            end

            // Check if first 4 cards are equal
            if ((cards[0] == cards[1]) && (cards[1] == cards[2]) && (cards[2] == cards[3])) begin
                check4ofakind = cards[2]; // 4 of a kind found
                return;
            end
            check4ofakind = 20; // No 4 of a kind
        end
    endfunction



//    // Function to check if there is a full house, returns the low 2 cards value else 20
    function integer checkfullhouse;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer cards[5];
        integer i, j, temp;

        begin
            // Merge player and community cards
            cards[0] = playercard1 % 13;
            cards[1] = playercard2 % 13;
            cards[2] = community1 % 13;
            cards[3] = community2 % 13;
            cards[4] = community3 % 13;

            // Perform simple sorting of the cards
            for (i = 0; i < 5; i = i + 1) begin
                for (j = 0; j < 4 - i; j = j + 1) begin
                    if (cards[j] > cards[j + 1]) begin
                        // Swap values
                        temp = cards[j];
                        cards[j] = cards[j + 1];
                        cards[j + 1] = temp;
                    end
                end
            end

            // Check if first three cards and then the other two cards are equal
            if ((cards[0] == cards[1]) && (cards[1] == cards[2]) && (cards[3] == cards[4])) begin
                checkfullhouse = cards[3]; // Full house found
                return;
            end

            // Check if first two cards and then the last three cards are equal
            if ((cards[0] == cards[1]) && (cards[2] == cards[3]) && (cards[3] == cards[4])) begin
                checkfullhouse = cards[1]; // Full house found
                return;
            end

            checkfullhouse = 20; // No full house
        end
    endfunction



   //function to check for a flush
    function integer checkflush;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer suit[5];
        integer i;
        begin
            suit[0] = playercard1 / 13;
            suit[1] = playercard2 / 13;
            suit[2] = community1 / 13;
            suit[3] = community2 / 13;
            suit[4] = community3 / 13;

            // Check for flush
            if ((suit[0] == suit[1]) && (suit[1] == suit[2]) && (suit[2] == suit[3]) && (suit[3] == suit[4])) begin
                checkflush = highcardnum(playercard1, playercard2, community1, community2, community3); // Flush found
            end else begin
                checkflush = 20; // No flush
            end
        end
    endfunction

//    //function to check if there is a straight, 20 if no straight found, else return highest value
    function integer checkstraight;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer cards[5];
        integer i, j, temp;

        begin
            // Merge player and community cards
            cards[0] = playercard1 % 13;
            cards[1] = playercard2 % 13;
            cards[2] = community1 % 13;
            cards[3] = community2 % 13;
            cards[4] = community3 % 13;

            // Bubble Sort cards
            for (i = 0; i < 5 - 1; i = i + 1) begin
                for (j = 0; j < 5 - i - 1; j = j + 1) begin
                    if (cards[j] > cards[j + 1]) begin
                        // Swap cards[j] and cards[j+1]
                        temp = cards[j];
                        cards[j] = cards[j + 1];
                        cards[j + 1] = temp;
                    end
                end
            end

            // Check if cards are in ascending order
            for (i = 0; i < 4; i = i + 1) begin
                if (cards[i] + 1 != cards[i + 1]) begin
                    checkstraight = 20; // Not in ascending order
                    return;
                end
            end

            checkstraight = cards[4]; // In ascending order
        end
    endfunction



//    // Function to check if there is a three of a kind, return card value if found, else 20
    function integer checkthreeofakind;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer cards[5];
        integer i, j, temp;

        begin
            // Merge player and community cards
            cards[0] = playercard1 % 13;
            cards[1] = playercard2 % 13;
            cards[2] = community1 % 13;
            cards[3] = community2 % 13;
            cards[4] = community3 % 13;

            // Bubble Sort cards
            for (i = 0; i < 5 - 1; i = i + 1) begin
                for (j = 0; j < 5 - i - 1; j = j + 1) begin
                    if (cards[j] > cards[j + 1]) begin
                        // Swap cards[j] and cards[j+1]
                        temp = cards[j];
                        cards[j] = cards[j + 1];
                        cards[j + 1] = temp;
                    end
                end
            end

            // Check if first three cards are equal
            if ((cards[0] == cards[1]) && (cards[1] == cards[2])) begin
                checkthreeofakind = cards[2]; // Three of a kind found
                return;
            end
            // Check if middle three cards are equal
            if ((cards[1] == cards[2]) && (cards[2] == cards[3])) begin
                checkthreeofakind = cards[2]; // Three of a kind found
                return;
            end
            // Check if end three cards are equal
            if ((cards[2] == cards[3]) && (cards[3] == cards[4])) begin
                checkthreeofakind = cards[2]; // Three of a kind found
                return;
            end
            checkthreeofakind = 20; // No three of a kind
        end
    endfunction


//        // Function to check if there is a two pair returns highest value of that pair, else 20
  function integer checktwopair;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer cards[5];
        integer high1;
        integer high2;
        integer i, j, temp;

        begin
            // Merge player and community cards
            cards[0] = playercard1 % 13;
            cards[1] = playercard2 % 13;
            cards[2] = community1 % 13;
            cards[3] = community2 % 13;
            cards[4] = community3 % 13;

            // Bubble Sort cards
            for (i = 0; i < 5 - 1; i = i + 1) begin
                for (j = 0; j < 5 - i - 1; j = j + 1) begin
                    if (cards[j] > cards[j + 1]) begin
                        // Swap cards[j] and cards[j+1]
                        temp = cards[j];
                        cards[j] = cards[j + 1];
                        cards[j + 1] = temp;
                    end
                end
            end

            // Check if the first pair exists
            if ((cards[0] == cards[1]) || (cards[1] == cards[2])) begin
                high1 = cards[1];
                // Check if there's a second pair
                if ((cards[0] == cards[1] && (cards[2] == cards[3] || cards[3] == cards[4])) ||
                    (cards[1] == cards[2] && cards[3] == cards[4])) begin
                    high2 = cards[3];
                    if (high1 > high2)
                        checktwopair = high1; // Two pair found
                    else
                        checktwopair = high2;
                    return;
                end
            end

            checktwopair = 20; // No two pair
        end
    endfunction


    //Function to check if there is a two of a kind. 20 if not found
    function integer checktwoofakind;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer cards[5];
        integer i, j, temp;

        begin
            // Merge player and community cards
            cards[0] = playercard1 % 13;
            cards[1] = playercard2 % 13;
            cards[2] = community1 % 13;
            cards[3] = community2 % 13;
            cards[4] = community3 % 13;

            // Bubble Sort cards
            for (i = 0; i < 5 - 1; i = i + 1) begin
                for (j = 0; j < 5 - i - 1; j = j + 1) begin
                    if (cards[j] > cards[j + 1]) begin
                        // Swap cards[j] and cards[j+1]
                        temp = cards[j];
                        cards[j] = cards[j + 1];
                        cards[j + 1] = temp;
                    end
                end
            end

            // Check adjacent cards for two of a kind
            for (i = 0; i < 4; i = i + 1) begin
                if (cards[i] == cards[i + 1]) begin
                    checktwoofakind = cards[i]; // Two of a kind found
                    return;
                end
            end

            checktwoofakind = 20; // No two of a kind
        end
    endfunction



   function integer highcardnum;
    input integer playercard1;
    input integer playercard2;
    input integer community1;
    input integer community2;
    input integer community3;
    integer cards[5];
    integer max_card;
    integer i;

    begin
        // Merge player and community cards
        cards[0] = playercard1 % 13;
        cards[1] = playercard2 % 13;
        cards[2] = community1 % 13;
        cards[3] = community2 % 13;
        cards[4] = community3 % 13;

        // Initialize max_card with the first card value
        max_card = cards[0];

        // Loop through the cards to find the highest value
        for (i = 1; i < 5; i = i + 1) begin
            if (cards[i] > max_card) begin
                max_card = cards[i];
            end
        end

        // Return the highest card value
        highcardnum = max_card; // Add 1 to convert back to original card value
    end
endfunction




    
    // function integer randCard;
        input integer s;
        input [51:0] card_array;
        integer card, count;
        begin
            count = 0;
            //card = $random(s) % 52; // Pick a random card
            card = s % 52;
//            while ((card_array[card] == 1) && (count < 52)) begin
//                card = s % 52; // Pick another if already chosen
//                count = count + 1;
//            end
//            if (count < 52) begin
//                card_array[card] = 1; // Mark card as chosen
//            end
//            else begin
//                card = 1; // Indicate failure to find a unique card
//            end
    //         randCard = card;
    //     end
    // endfunction   



    //new randcard function: 
    function integer randCard;
        input integer s;
        input [51:0] card_array;
        output [51:0] card_array_out;
        integer card, count;
        reg [51:0] card_array_temp;
        begin
            count = 0;
            card = s % 52; // Initial card selection attempt
            card_array_temp = card_array; // Copy input card_array to a temporary variable for modification

            // Loop until an unselected card is found or we've attempted all cards
            while ((card_array_temp[card] == 1) && (count < 52)) begin
                card = (card + 1) % 52; // Try the next card
                count = count + 1; // Increment the attempt count
            end

            if (count < 52) begin
                card_array_temp[card] = 1; // Mark card as chosen in the temporary array
                randCard = card; // Return the chosen card
            end else begin
                randCard = -1; // Indicate failure to find a unique card
            end
            card_array_out = card_array_temp; // Output the updated card array
        end
    endfunction
   
    
    function [7:0] cardConvert;
        input integer card;
        integer value, suit;
        begin
        if (card != -1) begin
            value = card % 13;
            suit = card / 13;
            cardConvert = {value[3:0], suit[3:0]};
        end
        else
            cardConvert = 8'b11111111;
        end
    endfunction
     
    initial begin
        card_array = 0;
        seed = 12345;
        counter = 0;
        player = 0;
        money_p1 = 100;
        money_p2 = 100;
    end
    
    always @ (posedge valid) begin
        if (rndStart == 6)
            rndStart = 0;
        //if (rndStart != 0)
                    //rndStart = rndStart + 1;
        if(rndStart == 0) begin
            p1[0] = randCard(counter, card_array);
            p1[1] = randCard(counter + 1, card_array);
            
            p2[0] = randCard(counter + 2, card_array);
            p2[1] = randCard(counter + 3, card_array);
            
            community[0] = randCard(counter + 4, card_array);
            community[1] = randCard(counter + 5, card_array);
            community[2] = randCard(counter + 6, card_array);
            //community[3] = randCard(counter + 7, card_array);
            //community[4] = randCard(counter + 8, card_array);
            //rndStart = 1;
        end
        
        case (rndStart)
            0: begin
                currp[0] = community[0];
                currp[1] = community[1];
                currp[2] = community[2];
            end
            1: begin
                currp[0] = p1[0];
                currp[1] = p1[1];
                currp[2] = -1;
            end
            2: begin
                currp[0] = community[0];
                currp[1] = community[1];
                currp[2] = community[2];
            end
            3: begin
                currp[0] = p2[0];
                currp[1] = p2[1];
                currp[2] = -1;
            end
            4 : begin
                currp[0] = -1;
                currp[1] = -1;
                currp[2] = -1;
            end
            5:
                begin 
                    //initial bet round
                    pot = 0;
                    bet_player1 = 0;
                    bet_player2 = 0;
                    money_p1 = money_p1 - 5; //min bet
                    money_p2 = money_p2 - 5; //min bet
                    pot = pot + 10;

                    while(money_p1 != money_p2)
                    //make it go through the loop until both players have the same amount of money,a dnit sohuld go through this once
                    
                end
            6:
            begin 

               winner = 1; // winner detection here
            end

        endcase
        rndStart = rndStart + 1;
//        if (rndStart < 2) begin
//            if (rndStart == 0) begin 
//                currp[0] = community[0];
//                currp[1] = community[1];
//                currp[2] = community[2];
//            end
//            else if ()
//                currp[0] = p1[0];
//                currp[1] = p1[1];
//                currp[2] = -1;
//            end
//            //currp[2] = 24;
//        end
//        else begin
//            if (rndStart == 2) begin 
//                currp[0] = community[0];
//                currp[1] = community[1];
//                currp[2] = community[2];
//            end
//            else begin
//                currp[0] = p2[0];
//                currp[1] = p2[1];
//                currp[2] = -1;
//            end
//        end
        
        //currp[1] = player ? p1[1] : p2[1]; 
        //currp[0] = player ? p1[0] : p2[0];
        //player = ~player;
        
//         if(rndStart == 5) begin
              
               
//               // Check royal flush first
//               p1_hand_value = checkroyalflush(p1, community);
//               p2_hand_value = checkroyalflush(p2, community);
               
//               if (p1_hand_value != 20 || p2_hand_value != 20) begin
//                   if (p1_hand_value == 20) winner_value = 2;
//                   else if (p2_hand_value == 20) winner_value = 1;
//                   else if (p1_hand_value > p2_hand_value) winner_value = 1;
//                   else if (p1_hand_value < p2_hand_value) winner_value = 2;
//                   else winner_value = $random % 2 == 0 ? 1 : 2; // Randomly assign if values are equal
//               end
//               else begin
//                   // Check straight flush
//                   p1_hand_value = checkstraightflush(p1, community);
//                   p2_hand_value = checkstraightflush(p2, community);
                   
//                   if (p1_hand_value != 20 || p2_hand_value != 20) begin
//                       if (p1_hand_value == 20) winner_value = 2;
//                       else if (p2_hand_value == 20) winner_value = 1;
//                       else if (p1_hand_value > p2_hand_value) winner_value = 1;
//                       else if (p1_hand_value < p2_hand_value) winner_value = 2;
//                       else winner_value = $random % 2 == 0 ? 1 : 2; // Randomly assign if values are equal
//                   end
//                   else begin
//                       // Add similar checks for other hands...
//                   end
//               end
               
//               // Update winner output
//               winner = winner_value;
//               end
               
        
       end
       
       always @ (posedge clk) begin
        counter = counter + 1;
        if (counter + 10 < 0) begin
            counter = 0;
        end
       end
       
       assign playerout = {cardConvert(currp[0]), cardConvert(currp[1]), cardConvert(currp[2])};
       
endmodule
