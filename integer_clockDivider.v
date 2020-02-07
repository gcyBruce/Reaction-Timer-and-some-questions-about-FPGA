`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2018 11:13:32
// Design Name: 
// Module Name: integer_clockDivider
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


module integer_clockDivider  
#(parameter integer THRESHOLD=50000)
(
    input wire clk,
    input wire enable,
    input wire reset,
    output reg dividedClk
    );
    
    reg [31:0] counter;
    always @(posedge clk) begin
    counter = counter + 1;
     if (reset == 1) begin
     dividedClk = 0;
     counter = 0;
     end else if (counter >= THRESHOLD-1) begin
     dividedClk = ~dividedClk;
     counter = 0;
     end
     end
    
endmodule
