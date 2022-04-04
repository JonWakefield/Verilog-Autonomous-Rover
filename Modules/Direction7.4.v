/* Author : Megan Lehmann & Jon Wakefield
    Direction module that uses IPS sensor input to control rover.
    Large state machine has effects on module as well (pitstop)*/


//Direction module in the form of Jon's PWM with five sensors 
module IPS_Sensors(
    input clock, //100000000 every second
    input left_sensor, right_front_sensor, middle_sensor, left_front_sensor, ARM, Obj_detect,
    inout flag,
    output reg Forward_left, Forward_right,
    output reg Backward_left, Backward_right,
    output reg arm_flag,
    output reg left_flag, right_flag, count_flag,
    output reg LED6 = 0,
    output reg LED7 = 0,
    output reg LED8 = 0,
    output reg LED9 = 0,
    output reg LED10 = 0

);
    
    reg [1:0] signal;
    // set counter & flags to 0
    initial begin 
        right_flag <= 0;
        left_flag <= 0;
        count_flag <= 0;
        signal <= 0;
        arm_flag <= 0;
    end
        //output control with counter
    always @ (posedge clock) begin 
        //counter will change signal status
            case (signal)
                2'b00: begin //forward  
                    Forward_left <= 1;
                    Forward_right <= 1;
                    Backward_left <= 0;
                    Backward_right <= 0;
                end
                2'b01: begin //right
                    Forward_left <= 1;
                    Forward_right <= 0;
                    Backward_left <= 0;
                    Backward_right <= 1;
                end 
                2'b10: begin //left
                    Forward_left <= 0;
                    Forward_right <= 1;
                    Backward_left <= 1;
                    Backward_right <= 0;
                end
                2'b11: begin //shouldn't happen, backwards - no
                    Forward_left <= 1;
                    Forward_right <= 1;
                    Backward_left <= 0;
                    Backward_right <= 0;
                end
            endcase
 end
        //input control
    always @(posedge clock) begin 
        if (flag) begin
            casez({middle_sensor,left_front_sensor,right_front_sensor,left_sensor,ARM})

                5'b0????: begin //go forward
                    signal = 2'b11;
                    LED6 <= 0; LED7 <= 0; LED8 <= 1; LED9 <= 0; LED10 <= 0;
                end
                5'b101??: begin //left sensor senses metal, turn to the left
                    signal = 2'b10;
                    LED6 <= 0; LED7 <= 0; LED8 <= 0; LED9 <= 1; LED10 <= 0;
                end
                5'b110??: begin // right sensor senses metal, turn to the right
                    signal = 2'b01;
                    LED6 <= 0; LED7 <= 1; LED8 <= 0; LED9 <= 0; LED10 <= 0;
                end
                5'b100??: begin
                    signal = 2'b00;    
                    LED6 <= 0; LED7 <= 0; LED8 <= 1; LED9 <= 1; LED10 <= 0;            
                end
                5'b11101: begin
                    signal = 2'b10;
                    LED6 <= 1; LED7 <= 0; LED8 <= 1; LED9 <= 0; LED10 <= 0;
                end
                5'b11110: begin
                    signal = 2'b01;
                    LED6 <= 0; LED7 <= 0; LED8 <= 1; LED9 <= 0; LED10 <= 1;
                end
                5'b11111: begin 
                    signal = signal;
                    LED6 <= 0; LED7 <= 0; LED8 <= 1; LED9 <= 0; LED10 <= 0;
                end
                5'b11100: begin
                    signal = 2'b01;
                    LED6 <= 1; LED7 <= 0; LED8 <= 1; LED9 <= 0; LED10 <= 1;
                end
            endcase
        end
        else 
            signal = 2'b01;
    end

always @(posedge clock) begin

    if ((Obj_detect) && (!ARM))
        arm_flag <= 1;
    
end
endmodule