`timescale 1ns/1ps

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
    wire program_done;
    wire soap_warning;
    wire soap_in;

    // Clock generation
    always #5 clk = ~clk; // 10ns clock period

    // Instantiate FSMW
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
        .program_done(program_done),
        .soap_warning(soap_warning),
        .soap_in(soap_in)
    );

    // Test scenarios
    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;
        power = 0;
        start = 0;
        doorclosed = 0;
        soap = 0;
        program_selection = 3'b000;

        // Apply reset
        #10 rst = 0;

        // Test 1: Idle state
        power = 1;
        #20;

        // Test 2: Start COLD_WASH program
        soap = 1;
        start = 1;
        doorclosed = 1;
        program_selection = 3'b001; // COLD_WASH
        #1000;

        // Test 3: No soap added, transition to WAIT_FOR_SOAP
        // soap = 0;
        // #20;
        // soap = 1;
        // #50;

        // // Test 4: Start HOT_WASH program
        // rst = 1;
        // #10 rst = 0;
        // start = 1;
        // program_selection = 3'b001; // HOT_WASH
        // #100;

        // // Test 5: Start RINSING_DRY program
        // rst = 1;
        // #10 rst = 0;
        // start = 1;
        // program_selection = 3'b010; // RINSING_DRY
        // #100;

        // // Test 6: Start ONLY_DRY program
        // rst = 1;
        // #10 rst = 0;
        // start = 1;
        // program_selection = 3'b011; // ONLY_DRY
        // #100;

        // // Test 7: Random transitions and inputs
        // repeat (5) begin
        //     #50;
        //     start = $random % 2;
        //     soap = $random % 2;
        //     doorclosed = $random % 2;
        //     program_selection = $random % 4;
        // end

        // // Test 8: Invalid program selection
        // rst = 1;
        // #10 rst = 0;
        // start = 1;
        // program_selection = 3'b111; // Invalid program
        // #50;

        // // Test 9: Reset during operation
        // rst = 1;
        // #10 rst = 0;

        // // End simulation
        // #200;
        $stop;
    end

    // Monitor signals
    initial begin
        $monitor($time, 
            " Power=%b Start=%b DoorClosed=%b Soap=%b Program=%b | ValveCold=%b ValveHot=%b ValveOut=%b Motor=%b Done=%b Warning=%b SoapIn=%b",
            power, start, doorclosed, soap, program_selection, 
            valve_in_cold, valve_in_hot, valve_out, motor, program_done, 
            soap_warning, soap_in);
    end
endmodule