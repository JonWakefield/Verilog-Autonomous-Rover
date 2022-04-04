/*  Authors: Jon Wakefield

    Large state machine that connects every module together like a symphony.

    About: module will tell the color sensor when to begin looking to
        set the color / change speed. 
        1. Begin looking for first color if Switch X has been flipped.
        2. stopped looking for color after detection
        3. Begin looking for color once ARM_flag is raised
        3. stopped looking for color after detection
        4. begin looking for red color after ___???
        5. stop looking for color (rover should not be moving anymore)
*/

`timescale 1ns / 1ps
module ColorSensorStateMachine (

    //inputs
    input clock,
    input GoSwitch,
    input Green_Feedback_wire, // make sure green is detected
    input Blue_feedback_wire,
    input Red_feedback_wire,
    input arm_flag,
    input Obj_detect,
    input left_arm,
    

    //outputs
    output reg[1:0] color = 0,
    output reg color_state = 0,
    output reg CS_reset = 0,
    output reg[3:0] counter = 0,
//    output reg road_detect = 0,
    output reg direction = 0,
    output reg[2:0] state = 0,
    output reg LED1 = 0,
    output reg _noGreen = 0

);



reg[30:0] timer = 0;
reg start_timer = 0;


always @ (posedge clock) begin
    
    case(state)

        // wait for switch X to be true -> color sensor looks.
        3'b000: begin
            if(GoSwitch) begin
                    color_state <= 1;
                    state <= 3'b001;
                end
            end
        // stop looking for color set next state
        3'b001: begin
            if(Green_Feedback_wire) begin //lets make sure green is detected before we move to state 3
                start_timer <= 0;
                color_state <= 0; // stop looking for color
                color <= 2'b10; // set speed to fast
                state <= 3'b010; //3b'010
                direction <= 1;
                _noGreen <= 1;
            end
            else begin
                start_timer <= 1;
                if (counter > 2) begin
                    color_state <= 0;
                    if (counter > 3) begin
                        start_timer <= 0;
                        state <= 3'b000;
                    end
                end
            end
        end
        3'b010: begin // road detection state
            // start_timer <= 1;
            // if (counter > 3 ) begin
            //     road_detect <= 1;
            //     color_state <= 1;
            //     start_timer <= 0;
            // end
            if (arm_flag) begin
                color_state <= 0;
               // road_detect <= 0;
                state <= 3'b011;
                direction <= 0;
            end
            
        end
        // Wait for ARM_flag true -> begin looking for color.
        3'b011: begin
            if (!left_arm) begin //when the rover has made most of the turn
                color_state <= 1; //look for blue now
                state <= 3'b100;
                direction = 1;
            end
        end
        // stop looking for color, set next state
        3'b100: begin
            if(Blue_feedback_wire) begin //lets make sure blue is detected before we move on
                color_state <= 0; // stop looking for color
                color <= 2'b01; // set speed to sloww
                state <= 3'b101;
            end
            else begin
                state <= 3'b100; // re-look for color. make sure its green first.    
            end
        end
        // begin looking for red color once __ happens 
        3'b101: begin
            start_timer <= 1;
            if ( counter > 10) begin
                start_timer <= 0;
                color_state <= 1;
                state <= 3'b110;
            end
            else state <= 3'b101;
            
        end
        // rover is shut down (probably un-needed state)
        3'b110: begin
           if(Red_feedback_wire) begin //lets make sure blue is detected before we move on
                color_state <= 0; // stop looking for color
                color <= 2'b00; // set speed to fast
                state <= 3'b110;
            end
            state <= 3'b110;
           end
    endcase
end


always @ (posedge clock) begin
    
    if (start_timer) begin
        if ( timer > 100000000) begin // after 1 sec, increment counter
            counter <= counter + 1;
            timer <= 0;
            end
        else begin
            timer <= timer + 1;
        end

    end
    else begin
        timer = 0;
        counter = 0;
    end
end

always @(posedge clock) begin
    
    if(Obj_detect)
        LED1 <= 1;
    else
        LED1 <= 0;

end


endmodule

