/* Authors: Megan Lehmann & Jon Wakefield
    Module was intially used in accordance for mini-project (Lehmann)
    Was later updated to display state, color detection, and timer (Wakefield) */

/* based off of
    https://simplefpga.blogspot.com/2012/07/seven-segment-led-multiplexing-circuit.html
*/

`timescale 1ns / 1ps

/* Display organization:
    Far Right : Current State
    Middle Right : Counter
    Middle Left : Color Detected
    Far Left : Track Color
*/




module Display (

    // inputs
    input clock,
    input arm_flag,
    input counter,
    input Green, Red, Blue,
    input Green_Track, Blue_Track, Red_Track,
    input Switch7,
    input[2:0] State,
    //input Switch2, Switch3, Switch4, Switch5,

    // outputs
    output reg [3:0] an,   // the 4 bit enable signal
    output a, b, c, d, e, f, g, dp //the individual LED output for the seven segment along with the digital point

);

localparam N = 18;
reg[N-1:0] count;
reg [6:0] seg;
reg [3:0] last_counter;

always @ (posedge clock) begin
   count <= count + 1;
end




always @ (posedge clock)
 begin
  case(count[N-1:N-2]) //using only the 2 MSB's of the counter 
   
   2'b00 :  //When the 2 MSB's are 00 enable the fourth display
    begin

        if (Switch7) begin
            seg = 4'd16;
        end
        else begin
        case(State)
            4'b0000 : seg = 4'd0;
            4'b0001 : seg = 4'd1;
            4'b0010 : seg = 4'd2;
            4'b0011 : seg = 4'd3;
            4'b0100 : seg = 4'd4;
            4'b0101 : seg = 4'd5;
            4'b0110 : seg = 4'd6;
            4'b0111 : seg = 4'd7;
            4'b1000 : seg = 4'd8;
            4'b1001 : seg = 4'd9;
            default :  seg = 4'd12;
        endcase
        end
        an = 4'b1110;
    end
   
   2'b01:  //When the 2 MSB's are 01 enable the third display
    begin
        if (Switch7)
            seg = 4'd15;
        else begin
        case(counter)
            4'b0000 : seg = 4'd0;
            4'b0001 : seg = 4'd1;
            4'b0010 : seg = 4'd2;
            4'b0011 : seg = 4'd3;
            4'b0100 : seg = 4'd4;
            4'b0101 : seg = 4'd5;
            4'b0110 : seg = 4'd6;
            4'b0111 : seg = 4'd7;
            4'b1000 : seg = 4'd8;
            4'b1001 : seg = 4'd9;
            default :  seg = 4'd12;
        endcase
        end
        an = 4'b1101;
    end

   2'b10:  //When the 2 MSB's are 10 enable the second display
    begin
        if (Switch7)
            seg = 4'd13;
        else begin
            if(Green) begin
                seg = 4'd10;
            end
            else if (Blue) begin
                seg = 4'd12;
            end
            else if (Red) begin
                seg = 4'd11;
            end
            else begin
                seg = 4'd13;
                
            end
        end
        an = 4'b1011;
     end
    
    
   2'b11:  //When the 2 MSB's are 11 enable the first display
    begin
        if (Switch7)
            seg = 4'd14;
        else begin
            if(Green_Track)
                seg = 4'd10;
            else if (Blue_Track)
                seg = 4'd12;
            else if (Red_Track)
                seg = 4'd11;
            else
                seg = 4'd13;
        end
       an = 4'b0111;
    end
  endcase
 end


reg [6:0] sseg_temp; // 7 bit register to hold the binary value of each input given

always @ (*)
 begin
  case(seg)
   4'd0 : sseg_temp = 7'b1000000; //to display 0
   4'd1 : sseg_temp = 7'b1111001; //to display 1
   4'd2 : sseg_temp = 7'b0100100; //to display 2
   4'd3 : sseg_temp = 7'b0110000; //to display 3
   4'd4 : sseg_temp = 7'b0011001; //to display 4
   4'd5 : sseg_temp = 7'b0010010; //to display 5
   4'd6 : sseg_temp = 7'b0000010; //to display 6
   4'd7 : sseg_temp = 7'b1111000; //to display 7
   4'd8 : sseg_temp = 7'b0000000; //to display 8
   4'd9 : sseg_temp = 7'b0010000; //to display 9
   4'd10 : sseg_temp = 7'b0000010; // G -> Green
   4'd11 : sseg_temp = 7'b0000011; // b -> Blue
   4'd12 : sseg_temp = 7'b1001110; // r - > Red
   4'd13 : sseg_temp = 7'b1000001; // U - > unclear
   4'd14 : sseg_temp = 7'b0001110; // F
   4'd15 : sseg_temp = 7'b1000110; // C
   4'd16 : sseg_temp = 7'b0001001; // k
   4'd17 : sseg_temp = 7'b0001001; // k
   default : sseg_temp = 7'b0111111; //dash
  endcase
 end
assign {g, f, e, d, c, b, a} = sseg_temp; //concatenate the outputs to the register, this is just a more neat way of doing this.
// I could have done in the case statement: 4'd0 : {g, f, e, d, c, b, a} = 7'b1000000; 
// its the same thing.. write however you like it

assign dp = 1'b1; //since the decimal point is not needed, all 4 of them are turned off

endmodule