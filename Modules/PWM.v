/* Author: Jon Wakefield
    Used to control speed of rover
    Speed is set by the color sensor (through the ColorSensorStateMachine.v)
    Sets a width, when counter exceeds width size, motors are set low. */


`timescale 1ns / 1ps
module PWM (

    //inputs
    input clock,
    input [1:0] speed,
    input Pin_JB9, Pin_JB10, Obj_detect, ARM,
    input ButtonDown,
    input Plaid,
    
    //output pwm signal to motors (ENA / ENB)
    output reg PWM_ENA = 0,
    output reg PWM_ENB = 0,
    output reg LED3 = 0,
    output reg LED4 = 0
    
);

    // create counter
    reg[22:0] counter;
    reg[22:0] width; //size of pwm signal. (howm many 1s in 1 period)
    reg[22:0] distance_counter;
    reg OC_flag = 0;
    reg[21:0] OC_Counter = 0;
    reg[21:0] OC_timer = 0;
    reg OC_stop = 0;


    // set counter & PWM to 0
    initial begin 
        width = 0;
        counter = 0;
        distance_counter = 0;
    end

always @ (posedge clock) begin


        if ( counter > 1666666) //1666666
            counter <= 0;
        else
            counter <= counter + 1;

        if ((counter < width) && (!OC_stop)) begin // && (!OC_flag)
            PWM_ENA <= 1;
            PWM_ENB <= 1;
            end
        else begin
            PWM_ENA <= 0;
            PWM_ENB <= 0;
        end
    end

always @(posedge clock) begin

        //can remove down counter for simplicity
            case(speed)

                // if speed set 0, PWM set 0%;
                2'b00 : width = 0;
                // if speed set 1, check if pins read HIGH, not PWM set 10%
                2'b01 : begin
                    width = 1583332; //416666
                end
                // if speed set 2, check if pins read HIGH, PWM set 30%
                2'b10 : begin
                    if (Plaid)
                        width = 1583332; //75%
                    else
                        width = 1583332; //833333
                end

                // if speed set 3, check if pins read HIGH, PWM set 80%
                2'b11 : begin
                    width = 1333333; //1333333
                end

                default : width = 0;

            endcase
        // if((Obj_detect) && (!ARM)) begin
        //     //could delete code below to test / debug
        //     width = 966666;
        // end
        
    end

always @ (posedge clock) begin

    if ((Pin_JB10) || (Pin_JB9))
       OC_flag <= 1;
    else if ((!Pin_JB10) || (!Pin_JB9)) begin
        OC_flag <= 0;
        OC_Counter <= 0;
        OC_timer <= 0;
        OC_stop <= 0;
    end

    if (OC_flag) begin
        if (OC_timer > 100000000) begin
            OC_Counter <= OC_Counter + 1;
        end
        else begin
            OC_timer <= OC_timer + 1;
        end
        if (OC_Counter > 2) begin
            OC_stop <= 1;
        end
        
    end
    if (Pin_JB10)
        LED3 <= 1;
    else
        LED3 <= 0;
    if (Pin_JB9)
        LED4 <= 1;
    else
        LED4 <= 0;
    
end
endmodule