# Reaction-Timer-and-some-questions-about-FPGA

# Part 1: Fundamentals
1. Explain the difference between blocking and non-blocking statements in Verilog. Use code and gate-level schematics to illustrate your answer.
Hint: Consider the code required to implement a shift-register in Verilog, and how its behaviour may be influenced by the use of blocking instead of non-blocking statements.

2. Explain how a D-type flip-flop works. Include a clearly labelled diagram in your response. Why are D-type flip flops so important in sequential logic designs?

3. Determine the minimum size of the resultant (output) signal required to:
a. Multiply two signed 18-bit numbers together
b. Subtract two signed 3-bit numbers
c. Count to 17,000
d. Divide a 10-bit number by 32
Hint: Consider signed operations very carefully.

4. Explain the difference between synchronous and asynchronous resets. Use code to demonstrate how they are described in a procedural block.
What might be an undesirable consequence of using an asynchronous reset that is driven by a physical push button? Can you think of a reason why you’d ever not use a synchronous reset?

5. What is the difference between combinatorial and sequential logic circuits?
State whether a sequential logic element is required to perform the following operations. Provide example Verilog code that could be used to perform them.
a. 32-bit adder
b. 6-element shift-register
c. 10-bit overflow counter
d. 16-bit signed multiplier
e. 7-input multiplexer
Advice: check that your code for each operation works in simulation or hardware.

# Part 2: Reaction Timer
Design a reaction timer for the Nexys4-DDR or Basys3 that will display the time it takes for a test-subject to react to an event on the board’s seven-segment displays. The subject’s reaction time is the time it takes for them to press a push button after a visual event occurred.

# States of operation
The reaction timer may have at least four states that broadly describe its behaviour at different times during the test. They could be:
• Idle, which is the default state when no reaction test is being performed.
• Preparation, which will inform the user that a new reaction test is about to begin (for example, the user could be notified of an impending reaction test by counting down from 3, 2, 1 on the seven segment displays.
• Test, which becomes active as soon as the preparation ends and will terminate as soon as the reaction test ends when the subject presses the push-button.
• Result, which will display the subject’s reaction time on the seven-segment displays for some period of time before reverting back into idle mode.
Hint: You should use a finite state machine to control the dynamic behaviour of your reaction timer.

# Operational description
A user may initiate a new test by pressing a push-button. The subject will then be notified that a new test is about to begin for example displaying a countdown timer on the seven segment displays. Once the test begins, the seven-segment displays will be turned off and, after a specific period of time (e.g., 1 second), an LED will turn on. The subject will then react to the LED becoming illuminated and end the test by pressing the push-button. Once a reaction test has been completed, the user’s reaction time will be displayed on the seven-segment displays. The reaction test can then be reset back to an idle state using a reset button.
An optional advanced feature would be to automatically return the test to an idle state 10 seconds after the previous test was completed if it is not reset manually.

# Reaction ‘event’
The event that the test-subject responds to must be visual and should not involve the seven- segment displays. On the Nexys4-DDR, the options are the 16 LEDs and two tri-colour LEDs. On the Basys3, the only option short of a peripheral module is the array of 16 LEDs. As an example, the event could be the sudden activation of all 16 LEDs to produce a strong visual queue for the test-subject.
The period of time between the test beginning (i.e., as soon as the preparation state ends) and the event occurring must be at least one second and at most five seconds.
 4 | Assignment One © Lyle Roberts 2018
 If the wait time for the reaction test is always constant, then the test-subject will eventually adapt and anticipate the event following repeated tests. An optional advanced feature would be to randomise the time after which the event occurs. One way to do this is to use a linear feedback shift-register to generate a random number that can be used to set a random event time. Information will be provided on Wattle describing how linear feedback shift-registers work and how they can be implemented on an FPGA.

# Reaction time measurement and display
A subject’s reaction time is equal to the period of time that passes between the LED being illuminated and the push-button being pressed. This means that a timer must be engaged as soon as the LED becomes illuminated and stopped as soon as a button-press is registered on the push- button. If the subject presses the push-button before the LED is illuminated, then they fail the test. You could indicate this to the subject by displaying the word ‘FAIL’ on the seven-segment display instead of a valid reaction time.
The reaction time must be measured with 1 millisecond precision, and the total reaction time should be displayed on the four seven-segment displays. This limits the subject’s maximum reaction time to 9.999 seconds.
A dot point should be displayed on the left-most seven-segment display to indicate which digit represents seconds.
An optional advanced feature would be to flash the most recent reaction time if it is the fastest recorded time since the FPGA was programmed with your design. There is no need to store the fastest reaction time permanently.
Be creative with your design. You may be awarded bonus marks for being clever or exceeding our expectations, so don’t be afraid to impress us!

