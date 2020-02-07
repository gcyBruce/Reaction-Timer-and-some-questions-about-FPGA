`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2018 09:31:39
// Design Name: 
// Module Name: edgeDetector
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


module edgeDetector(
    input wire clk,
    input wire signalIn,
    output wire signalOut,
    output reg risingEdge,
    output reg fallingEdge
    );
    reg [1:0] pipeline;
    
    
    always @(posedge clk) begin
     pipeline[0] <= signalIn;
      pipeline[1] <= pipeline[0];
    end
    
always @(*) begin
    if (pipeline ==  2'b01) begin
        risingEdge = 1'b1;
    end else if (pipeline ==  2'b10) begin
        fallingEdge = 1'b1;
    end else begin
        risingEdge = 1'b0;
        fallingEdge = 1'b0;
    end
end
      
     assign signalOut = pipeline[1];
endmodule
