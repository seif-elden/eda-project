`timescale 1ns / 1ps

module FSMW_tb;

// Inputs
reg power;
reg clk;
reg rst;
reg [2:0] program_selection;
reg start;
reg doorclosed;
reg soap;

// Outputs
wire valve_in_cold;
wire valve_in_hot;
wire valve_out;
wire motor;
wire [7:0] timer_display;
wire program_done;
wire soap_warning;

// Instantiate the FSMW module
FSMW uut (
    .power(power),
    .clk(clk),
    .rst(rst),
    .program_selection(program_selection),
    .start(start),
    .doorclosed(doorclosed),
    .soap(soap),
    .valve_in_cold(valve_in_cold),
    .valve_in_hot(valve_in_hot),
    .valve_out(valve_out),
    .motor(motor),
    .timer_display(timer_display),
    .program_done(program_done),
    .soap_warning(soap_warning)
);

// Clock generation
always #5 clk = ~clk;  // 10 ns clock period

// Task to initialize and reset
task initialize;
begin
    power = 1;
    clk = 0;
    rst = 1;
    start = 0;
    doorclosed = 1;
    soap = 0;
    program_selection = 3'b000;
    #10 rst = 0;
end
endtask

// Task to select a program and start FSM
task select_program(input [2:0] prog_sel);
begin
    program_selection = prog_sel;
    start = 1;
    #10 start = 0;
end
endtask

// Task to simulate soap addition
task add_soap;
begin
    #10 soap = 1;
end
endtask

// Main test sequence
initial begin
    $display("Starting FSM Test Bench");
    initialize;

    // Test COLD_WASH program WITH SOAP
    add_soap;
    select_program(3'b000);  // COLD_WASH
    #2000;  // Wait for the program to complete
    soap = 0;

    // // Test COLD_WASH program WITHOUT SOAP
    // select_program(3'b000);  // COLD_WASH
    // #10 add_soap;
    // #200;  // Wait for the program to complete


    // // Test HOT_WASH program
    // add_soap;
    // select_program(3'b001);  // HOT_WASH
    // #200;


    // // Test RINSING_DRY program
    // select_program(3'b010);  // RINSING_DRY
    // #150;

    // // Test ONLY_DRY program
    // select_program(3'b011);  // ONLY_DRY
    // #150;

    // Finish simulation
    $stop;
end

// Monitor outputs
initial begin
    $monitor("Time=%0t | State=%b | Valve_in_cold=%b | Valve_in_hot=%b | Valve_out=%b | Motor=%b | Timer_display=%d | Program_done=%b | Soap_warning=%b", 
        $time, uut.current_state, valve_in_cold, valve_in_hot, valve_out, motor, timer_display, program_done, soap_warning);
end

endmodule
