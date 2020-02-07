`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2018 10:47:48
// Design Name: 
// Module Name: sevenSegmentDecoder
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


module sevenSegmentDecoder(
    input wire [3:0] bcd,
    input wire eight,
    output reg [7:0] ssd
    );
    
    always @(*) begin
        if (eight == 1) begin        //when parameter eight is 1, the bcd is for HSB, it has dot.Otherwise, the bcd does not have dot. 
            case(bcd)
                4'd0 : ssd = 8'b00000010;
                4'd1 : ssd = 8'b10011110;
                4'd2 : ssd = 8'b00100100;
                4'd3 : ssd = 8'b00001100;
                4'd4 : ssd = 8'b10011000;
                4'd5 : ssd = 8'b01001000;
                4'd6 : ssd = 8'b01000000;
                4'd7 : ssd = 8'b00011110;
                4'd8 : ssd = 8'b00000000;
                4'd9 : ssd = 8'b00001000;
                default : ssd = 8'b11111110;
            endcase
        end else  begin
            case(bcd)
                4'd0 : ssd = 8'b00000011;
                4'd1 : ssd = 8'b10011111;
                4'd2 : ssd = 8'b00100101;
                4'd3 : ssd = 8'b00001101;
                4'd4 : ssd = 8'b10011001;
                4'd5 : ssd = 8'b01001001;
                4'd6 : ssd = 8'b01000001;
        4'd7 : ssd = 8'b00011111;
        4'd8 : ssd = 8'b00000001;
        4'd9 : ssd = 8'b00001001;
        4'd10: ssd = 8'b01110001;
        4'd11: ssd = 8'b00010001;
        4'd12: ssd = 8'b11110011;
        4'd13: ssd = 8'b11100011;
        4'd14: ssd = 8'b11111101;
        4'd15: ssd = 8'b11111111;
        default : ssd = 8'b11111111;
      endcase
      end
    end
endmodule
