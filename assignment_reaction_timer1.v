`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/07 13:07:25
// Design Name: 
// Module Name: assignment_reaction_timer
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


module assignment_reaction_timer(
    input clk, reset, start,stop, switch,   //reset is used reset the system; start button is used to change state from idle to preparation; stop is used to test the rection.
    output reg [15:0] LED,
    output reg [3:0] ssdAnode,
	output wire [7:0] ssdCathode
    );

	wire clk_1HZ, clk_1kHZ;
	wire clk_1HZ_risingEdge,clk_1kHZ_risingEdge;
	reg [3:0] bcd;
	reg [1:0] activeDisplay;
	reg eight = 1'd0;

 //using integer clock Divider source to get 1Hz clock signal.      
    integer_clockDivider #(
         .THRESHOLD(50_000_000)
         ) onehz (
         .clk(clk),
         .reset(reset),
         .enable(1'd1),
         .dividedClk(clk_1HZ)
         );
 
 //using integer clock Divider source to get 1kHz clock signal.       
	integer_clockDivider #(
			.THRESHOLD(50_000)
			) onekhz (
              .clk(clk),
              .reset(reset),
              .enable(1'd1),
              .dividedClk(clk_1kHZ)
              );  
              
//using edge detector to get the rising edge of 1hz clock signal.                  
       edgeDetector CLOCK_1HZ_EDGE(
        .clk(clk),
        .signalIn(clk_1HZ),
        .signalOut(),
         .risingEdge(clk_1HZ_risingEdge),
         .fallingEdge()
       );
//using edge detector to get the rising edge of 1khz clock signal.        
      edgeDetector CLOCK_1kHZ_EDGE(
        .clk(clk),
        .signalIn(clk_1kHZ),
        .signalOut(),
         .risingEdge(clk_1kHZ_risingEdge),
         .fallingEdge()
         );
 //using sevensegment detector to show the number in sevensegment.        
      sevenSegmentDecoder seven(
        .eight(eight),
        .ssd(ssdCathode),
        .bcd(bcd)
       );         

	
 //identify each state of FSM.                
    parameter Idle = 2'b00;
    parameter Preparation = 2'b01;
    parameter Test= 2'b10;
    parameter Result= 2'b11;
    
    reg [1:0] state, nextState;
	reg [1:0]counter1 ;       //counter1 is used to count down from 3, 2, 1 in preparation state.
	reg [15:0]counter2;    //used to count the reaction time. 14-bit is enough for decimal 9999. the extra bits are used to count over 10s to display "FAIL".	
	reg [3:0]counter3;        //counter3 is used to count 10 seconds in result state, if no action, the state will be changed to idle state automatically.
	reg [35:0]counter_random;       //counter_random is used to count the a specific period time which is randomly generated. 
	reg able;                  //when counter_random has finished counting, able changes from 0 to 1 to start next step.
	reg [15:0] action_time;    //the result of reaction time.
	reg [15:0] mini_action_time;  //the minimum reaction time since the FPGA was programmed. 
	reg [3:0] a,b,c,d;          //the divided four decimal bits of action_time.
	reg [7:0] rand_num;         //the randomly generated number.
  
 //change the display of ssdAnode every 0.001s.       
        always @ (posedge clk_1kHZ) begin    
                activeDisplay = activeDisplay + 1;
        end
 
 //change the current state to next state    
	always @(posedge clk) begin
        if (reset) begin
            state <= Idle;
        end else begin
            state <= nextState;
        end
    end

//identify the conditions for each state to the nextstate.          
    always @(*) begin
        case(state)
            Idle : begin
				if (start == 1)           //when pushing start button, idle changes to preparation state.
                nextState = Preparation;           
				else
                nextState =  Idle;
			end
         
			Preparation : begin
				if (counter1 == 0)    //when the countdown to 0, preparation changes to test state.
				nextState = Test;
                else if (stop == 1)   //if push stop button early, change to result state directly, and dispaly "FAIL".
					nextState = Result;
                else
					nextState = Preparation;
			end

			Test : begin
				if (action_time > 1 )       //when the result raction time has been saved, test changes to result state.
					nextState = Result;
                else if (reset == 1)       //if push reset button, go back to idle state.
					nextState = Idle;
				else
					nextState = Test;
			end
			
         
			Result : begin
				if (reset == 1 || counter3 > 10)    //if push reset button or over 10s no action, change to idle state.
					nextState = Idle;                 
                else if(reset == 0)
					nextState = Result;
			end
      
			default : nextState = Idle;
        
        endcase
    end    
 
 //using Linear Feedback Shift Register (LFSR) to generate a pseudo-random number.
     always @(posedge clk_1HZ) begin
     if (switch ==0) begin        //if switch is off, it is a constant period, if switch is on. the period is random.
         rand_num <=8'b11111001;    //set the initial number.
      end else begin
          rand_num[0] <= rand_num[7];   //shift bit.
          rand_num[1] <= rand_num[0];
          rand_num[2] <= rand_num[1];
          rand_num[3] <= rand_num[2];
          rand_num[4] <= rand_num[3]^rand_num[7];   //feedback from rand_num[7]. exclusive or with the shifted bit. create randomness, but it is pseudo, the next number can be predicted.
          rand_num[5] <= rand_num[4]^rand_num[7];
          rand_num[6] <= rand_num[5]^rand_num[7];
          rand_num[7] <= rand_num[6];
      end          
  end     
         
 //the actions in four states.    
    always @(posedge clk) begin
        case(state) 
    //initialize the variable in idle state.          
			Idle: begin           
                counter3 <= 4'd0;
                LED <= 16'd0;
                ssdAnode <= 4'b0000;  
                bcd <= 4'd14; 
                counter1 <= 2'd3;
                eight <= 0;
                action_time<=0;              
            end
            
            Preparation: begin
                if (clk_1HZ_risingEdge == 1)    //using 1Hz clock signal to countdowm 3, 2. 1.
					counter1 <= counter1 -1;
                else
					counter1 <= counter1;
               
                counter_random <= 0;    //initialize the variables for text state.
                able <= 0;   
				LED <= 16'd0;
                case (counter1)          //dispaly the countdown number.
					2'd0: bcd <= 4'd0; 
					2'd1: bcd <= 4'd1;
                    2'd2: bcd <= 4'd2;
					2'd3: bcd <= 4'd3; 
                    default : bcd <= 4'd14;                    
                endcase                              
            end
            
            Test: begin        
				ssdAnode <= 4'b1111;     //turn off the sevensegment.
				bcd <= 4'd15;
				counter_random = counter_random + 1;
				if (counter_random >= (rand_num*784_314 + 49_999_999)) begin   //using clk (100 MHz) to count a random number between 1s and 5s. rand_num ranges 0 to 255, nutiple 784_314,apprpximate 200_000_000.  
					able <= 1;
					counter_random <= 0;
				end
            
				if (reset) 
					counter2 <= 0;
				else if (able ==1) begin    //when the counter_random finishes counting, turnning on the LED. means starting timing.
					LED <= 16'b1111111111111111;
					if (clk_1kHZ_risingEdge ==1)begin    //using 1kHz clock signal to count the reaction time, each rising edge means 0.001s.
						counter2 <= counter2 + 1;
						if (stop == 1) begin    //when the stop button is pushed, get the current value from counter2.
							action_time <= counter2;
							counter2 <= 0;  //reset counter2 for next reaction test.
						end
					end
				end
			end
           
            Result: begin
                //judge whether the current action_time is the fastest, if it is, change the LED and save it in mini_action_time.
                     if (mini_action_time >= action_time || mini_action_time == 0) begin
                             mini_action_time <= action_time;
                             LED <= 16'b0101_0101_0101_0101;
                       end else begin
                             mini_action_time <= mini_action_time;
                             LED <= 16'd0;
                       end

             //using 1 Hz cllock signal to count 10s. 
				if (clk_1HZ_risingEdge == 1)
					counter3 <= counter3+1;
				else
					counter3 <= counter3;
            
				if (counter3>10)begin   //if over 10s, reset it and change to idle state.
					action_time<=0;
					counter3<=0;
				end else if (reset) begin  //if push reset, the variables will be reseted.
                    counter2 <= 0;
                    action_time<=0;
                    ssdAnode <= 4'b1111;
                    LED <= 16'd0;
				end else  if(action_time > 14'd9999 || counter1 !== 0) begin   //if the reaction time is over 9.999s or pushing stop when in preparation state.
                    LED <= 16'd0;
                    case (activeDisplay)   //dispaly "FAIL" in sevensegment.
						2'd0 : begin
							ssdAnode <= 4'b0111;
							bcd <= 4'd10;   //"F"
						end
						2'd1 : begin
							ssdAnode <= 4'b1011;
							bcd <= 4'd11;   //"A"
						end
						2'd2 : begin
							ssdAnode <= 4'b1101;
							bcd <= 4'd12;    //"I"
						end
						2'd3 : begin
							ssdAnode <= 4'b1110;
							bcd <= 4'd13;    //"L"
						end 
						default : begin
							ssdAnode <= 4'b1111;
							bcd <= 4'd15; 
						end                    
					endcase
					
				end else begin               //dividing the four decimal bits of action_time into a, b, c, d.
					a <= action_time%10;
					b <= (action_time/10)%10;
					c <= (action_time/100)%10;
					d <= (action_time/1000)%10; 
					case (activeDisplay)      //display the four decimal number in sevensegment.
						2'd0 : begin
							eight <= 1;      //if the sevensegment is the HSB, the variable eight is 1, in souce sevensegment decoder, it will display dot.otherwise, no dot.
							ssdAnode <= 4'b0111;
							bcd <=d;
						end
						2'd1 : begin
							eight <=0;
							ssdAnode <= 4'b1011;
							bcd <= c;
						end
						2'd2 : begin
							eight <= 0;
							ssdAnode <= 4'b1101;
							bcd <= b;
						end
						2'd3 : begin
							eight <= 0;
							ssdAnode <= 4'b1110;
							bcd <= a;
						end 
						default : begin
							eight <= 0;
							ssdAnode <= 4'b1111;
							bcd <= 4'd15; 
						end                    
					endcase                                                             
				end                   
			end            
        endcase
    end
	
endmodule
