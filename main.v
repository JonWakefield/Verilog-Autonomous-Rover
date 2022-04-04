/* Author: Jon Wakefield  */
/* Included withing the main module are many sub-modules that are called upon
   when neccassary. All modules are named in accordance with the functions they
   contribute too.  */ 

/* Main statement used to call functions */


`timescale 1ns / 1ps
module main(

    //inputs
    input clock, // 100Mg clock
    input Switch1, // Good-to-go switch (starts case machine)
    input Switch15, Switch16, Switch14, Switch7, // Handicaps used for color sensor (not used on demo day)
    //IPS Sensor inputs
    input JB0, JB1, JB2, JB3, JB4, // input p-mod pins connected to 5 IPS sensors
    input Switch5, //plaid 

    input ButtonDown, // color sensor reset
    
    // Overcurrent protection pins
    input JB9, JB10,
    
    // obj detected pin 
    input JB8,
    
    
    input JC3, // input frequency from color sensor
    input Button_Up , // over current reset

    
    //ouputs
    output PWM_ENA, // sets speed of motors
    output PWM_ENB,
    output[3:0] Display_Anodes, // Ouput what display turns out ( 0 0 0 0 )
    output a, b, c, d, e, f, g, dp, // tradition 8-bit display configuration

    // outputs motor direction to H-bridge
    output JA1, JA2, //backwards pins
    output JA3, JA4, //forwards pins
    output LED13, LED14, LED15, LED16, // LEDS for color sensor R -> B -> G -> U
    output LED1, // distance sensor LED
    output LED3, LED4, //overcurrent LEDS
    output LED6, LED7, LED8, LED9, LED10, // IPS LEDs left - right

    // S0 - S4 color sensor pins
    output JC7, JC8, 
    output JC9, JC10
    


);

/* Listed below are the wires used to connect various modules together
    Most wires names are self-explained. Others will be explained */

wire[17:0] CS_freq;
wire done_flag; // flag used with color sensor.
wire[1:0] color_speed; // sets speed based on color seen
wire CS_state; // current state of rover
wire arm_wire; // connect this to module using arm sensor
wire[3:0] display_count;
wire[2:0] State_Machine;

// these ensure correct color has been detected.
wire G_feedback;
wire B_feedback;
wire R_feedback;
wire CS_reset;
wire frequency_wire;
wire flag;
wire _noGreen; // Don't accept green (not used)


Display Seven_Seg(

    //inputs
    .clock(clock),
    .arm_flag(arm_wire),
    .counter(display_count),
    .Green(G_feedback),
    .Red(B_feedback),
    .Blue(R_feedback),
//    .Green_Track(G_Track),
//    .Blue_Track(B_Track),
//    .Red_Track(R_Track),
    .Switch7(Switch7),
    //.Switch2(Switch2),
    //.Switch3(Switch3),
    //.Switch4(Switch4),
    //.Switch5(Switch5),
    .State(State_Machine),

    //outputs
    .an(Display_Anodes),
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .e(e),
    .f(f),
    .g(g),
    .dp(dp)

);

IPS_Sensors Direction(

    //inputs
    .flag(flag),
    .clock(clock),
    .left_sensor(JB2),
    .right_front_sensor(JB0),
    .middle_sensor(JB1),
    .left_front_sensor(JB4),
    .ARM(JB3),     //change these numbers?
    .Obj_detect(JB8),
    //.Switch3(Switch3),
    //.Switch4(Switch4),
    //.Switch5(Switch5),

    //outputs direction to H-bridge
    .Backward_left(JA1),  //IN2
    .Backward_right(JA2), //IN3
    .Forward_left(JA3),   //IN4
    .Forward_right(JA4),   //IN1
    .arm_flag(arm_wire),
    .LED6(LED6),
    .LED7(LED7),
    .LED8(LED8),
    .LED9(LED9),
    .LED10(LED10)

);

PWM Motor_Speed(

        //inputs
        .clock(clock),
        .speed(color_speed),
        .Pin_JB9(JB9),
        .Pin_JB10(JB10),
        .Obj_detect(JB8),
        .ARM(JB3),
        .ButtonDown(ButtonDown),
        .Plaid(Switch5),

        //outputs
        .PWM_ENA(PWM_ENA),
        .PWM_ENB(PWM_ENB),
        .LED3(LED3),
        .LED4(LED4)
        
);

FrequencyCounter FrequencyCounter (

    // inputs
    .clock(clock),
    .input_pulse(JC3),
    .CS_state(CS_state),
    .done_flag(frequency_wire),

    //outputs /// wire
    .frequency(CS_freq),
    .flag_done(done_flag)

);

ColorSensor ColorSensor (

    // inputs
    .clock(clock),
    .frequency(CS_freq),
    .man_reset(Button_Up),
    .begin_flag(done_flag),
    .CS_state(CS_state),
    .GoSwitch(Switch1),
    .reset(CS_reset),
    .Switch16(Switch16),
    .Switch15(Switch15),
    .Switch14(Switch14),
//    .road_detect(road_detect),
    ._noGreen(_noGreen),

    //outputs 
    .S0(JC7),
    .S1(JC8),
    .S2(JC9),
    .S3(JC10),
    .LED13(LED13),
    .LED14(LED14),
    .LED15(LED15),
    .LED16(LED16),
    .G_feedback(G_feedback),
    .B_feedback(B_feedback),
    .R_feedback(R_feedback)
    
//    .G_RoadFB(G_Track),
//    .B_RoadFB(B_Track),
//    .R_RoadFB(R_Track)

);

ColorSensorStateMachine ColorMachine (

    //inputs
    .clock(clock),
    .GoSwitch(Switch1),
    .Green_Feedback_wire(G_feedback),
    .Blue_feedback_wire(B_feedback),
    .Red_feedback_wire(R_feedback),
    .arm_flag(arm_wire),
    .Obj_detect(JB8),
    .left_arm(JB2),
    
    //outputs
    .color_state(CS_state), // ran thru wire and inputed into colorsensor
    .color(color_speed),
    .CS_reset(CS_reset),
    .counter(display_count),
//    .road_detect(road_detect),
    .state(State_Machine),
    .direction(flag),
    .LED1(LED1),
    ._noGreen(_noGreen)



);



endmodule
