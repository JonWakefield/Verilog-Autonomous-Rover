/*
    Jon Wakefield
    About: Module takes an input and counts the frequency (hz) 
    coming off the input. Uses a counter to count pulses and timer
    to determine unit of time. Module determines if anything has
    changed, increments counter. 
    Timing is key.
    Based off of:
    https://github.com/ricerodriguez/ttu-lab1-code-examples/blob/master/part1-clocks-and-counters/example5_freq_counter.v
    */


`timescale 1ns / 1ps
module FrequencyCounter (

    input clock, // clock on basys
    input input_pulse, // input frequency from color sensor
    input CS_state,
    input done_flag,

    //outputs
    output reg[17:0] frequency = 0,
    output reg flag_done = 0
    


);

/* Use timer to count postive edges of BASYS clock to determine length of time that has passed */
reg[30:0] timer = 0 ;
reg[17:0] PosEdge_Counter = 0;
reg last_freq = 0;

always @ (posedge clock )
    last_freq <= input_pulse;


always @ (posedge clock ) begin

    // 1 / 20 of a second ( 20th of a frequency)
    if ((CS_state) && (!done_flag)) begin
        if (timer < 500000) begin
            timer <= timer + 1;
            flag_done = 0;

            if ( ~last_freq & input_pulse)
                PosEdge_Counter <= PosEdge_Counter + 1;
        end
        else begin
            // reset values
            frequency = 0;
            frequency = PosEdge_Counter * 20; // gives us our value in hertz (1second)
            PosEdge_Counter = 0;
            timer = 0;
            flag_done = 1;
        end
    end
    else begin
        PosEdge_Counter = 0;
        timer = 0;
        frequency = 0;
    end

end
endmodule