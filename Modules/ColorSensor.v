/*
    Author: Jon Wakefield
    About: Module to determine the color using a frequency counter
        Module reads in the frequency from FrequencyCounter.v stores in register
        changes input, then repeats process. 
        If the color detected (R,G,B) is > counterpart + counterpart == true
        else color not detected.
        Module links many other modules together.
        Timing is key.
    */



`timescale 1ns / 1ps
module ColorSensor (

    input clock,
    input reset,
    input[17:0] frequency, //connected to out on Color sensor
    input begin_flag,
    input man_reset,
    input CS_state, // if -> 0 dont look for color // if -> 1 look for color
    input GoSwitch,
    input Switch15,
    input Switch16,
    input Switch14,
    input _noGreen,


    output S0, S1, // set the frequency (0 , 2 , 20 , 100)
    // sets the color (R,B,G,C)
    output reg S2 = 1,
    output reg S3 = 0,
    output reg LED13, 
    output reg LED14,
    output reg LED15,
    output reg LED16,

    output reg G_feedback = 0,
    output reg B_feedback = 0,
    output reg R_feedback = 0
    
    

);

assign S0 = 1;
assign S1 = 1;

reg reset_b = 0;
reg[1:0] state = 0;
reg[17:0] clear_freq = 0;
reg[17:0] red_freq = 0;
reg[17:0] blue_freq = 0;
reg[17:0] green_freq = 0;
reg[2:0] red_counter = 0;
reg[2:0] blue_counter = 0;
reg[2:0] green_counter = 0;
reg reset_flag = 0;
reg done_flag = 0;



always @ (posedge clock) begin

    if(CS_state) begin
            if((reset) || (reset_b)) begin
                clear_freq <= 0;   
                red_freq <= 0; 
                blue_freq <= 0; 
                green_freq <= 0;  
                state <= 0;
                done_flag <= 0;
                S2 <= 1;
                S3 <= 0;
                reset_b <= 0;
            end
            if(man_reset) begin // if button is pressed --> reset all (test purposes)
                clear_freq <= 0;   
                red_freq <= 0; 
                blue_freq <= 0; 
                green_freq <= 0;  
                state <= 0;
                done_flag <= 0;
                red_counter <= 0;
                blue_counter <= 0;
                green_counter <= 0;
                LED13 <= 0;
                LED14 <= 0;
                LED15 <= 0;
                LED16 <= 0;
                G_feedback <= 0;
                B_feedback <= 0;
                R_feedback <= 0;
            end
            
            // begin looking for colors
            if ((CS_state) && (!done_flag)) begin
                case(state) 
                    0: begin //clear
                        if(begin_flag) begin
                            clear_freq <= frequency;
                            S2 <= 0; S3 <= 0;
                            state <= 1;
                        end                
                    end
                    1: begin //red
                        if(begin_flag) begin
                            red_freq <= frequency;
                            S2 <= 0; S3 <= 1;
                            state <= 2;
                        end
                    end
                    2: begin //blue
                        if(begin_flag) begin
                            // if (!_noGreen) begin
                            //     blue_freq <= frequency - 2000;
                            // end
                            // else
                            blue_freq <= frequency;
                            S2 <= 1; S3 <= 1;
                            state <= 3;
                        end
                    end
                    3: begin //green
                        if (begin_flag) begin
                         // maybe fix numbers
                        if (Switch16)
                            green_freq <= frequency + 3000;
                        else if (Switch15)
                            green_freq <= frequency + 9000;
                        else if (Switch14)
                            green_freq <= frequency + 50000;
                        else 
                            green_freq <= frequency;
                        S2 <= 1; S3 <= 0; // change diode back to clear
                        state <= 0; // reload state machine
                        done_flag <= 1;
                        end
                    end
            endcase
            end
            
            if (done_flag) begin
                if (red_freq > blue_freq + green_freq + 1500) begin
                        R_feedback <= 1;
                        B_feedback <= 0;
                        G_feedback <= 0;
                        LED13 <= 1;
                        LED14 <= 0;
                        LED15 <= 0;
                        LED16 <= 0;
                        reset_b <= 1;
                end
                else if (blue_freq > red_freq + green_freq) begin
                        B_feedback <= 1;
                        R_feedback <= 0;
                        G_feedback <= 0;
                        LED13 <= 0;
                        LED14 <= 1;
                        LED15 <= 0;
                        LED16 <= 0;
                        reset_b <= 1;
                end
                else if ((green_freq > blue_freq) && (green_freq > red_freq) ) begin
                        G_feedback <= 1; // send feedback saying green was detected.
                        R_feedback <= 0;
                        B_feedback <= 0;
                        LED13 <= 0;
                        LED14 <= 0;
                        LED15 <= 1;
                        LED16 <= 0;
                        reset_b <= 1;
                end
                else begin
                    LED13 <= 0;
                    LED14 <= 0;
                    LED15 <= 0;
                    LED16 <= 1;
                    reset_b <= 1;
                end
            end
        end
        else begin
                clear_freq <= 0;   
                red_freq <= 0; 
                blue_freq <= 0; 
                green_freq <= 0;  
                state <= 0;
                done_flag <= 0;
                S2 <= 1;
                S3 <= 0;
                R_feedback <= 0;
                B_feedback <= 0;
                G_feedback <= 0;
            end
end
endmodule


/* get clear frequency:
    1. get red freq perform calc with red and clear. 
    once calculations are finished move onto green color.
    2. green color w/ clear -> perform calculations
    3. blue color w/ clear -> perform calculations
    4. compare values for largest number. */


    /* will need way to lower feedback wires.
    I think green color is finished */