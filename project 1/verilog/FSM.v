module FSMW(
    // INPUTS
    input  wire       power,
    input  wire       clk,
    input  wire       rst,
    input  wire [2:0] program_selection,
    input  wire       start,
    input  wire       doorclosed,
    input  wire       soap,

    // OUTPUTS
    output reg        valve_in_cold,
    output reg        valve_in_hot,
    output reg        valve_out,
    output reg  [1:0] motor,
    output reg  [7:0] timer_display,
    output reg        program_done,
    output reg        soap_warning  ,
    output reg        soap_in    

);



// State Definitions
reg [3:0] current_state, next_state;
parameter IDLE                  = 4'b0000;
parameter FILLING_WATER_SOAP    = 4'b0001;
parameter WASHING               = 4'b0010;
parameter DRAINING_WASH         = 4'b0100;
parameter RINSING               = 4'b0011;
parameter DRAINING_RINSE        = 4'b0101;
parameter DRYING                = 4'b0110;
parameter WAIT_FOR_SOAP         = 4'b0111;   
parameter ONLY_DRYING           = 4'b1000;
parameter Finished              = 4'b1001;

// Program timer 
reg total_timer_start;
reg [7:0] total_duration;
wire total_timer_done;
wire [7:0]counter ;

// Instantiate Timer Module
timer total_timer_inst (
    .clk(clk),
    .rst(rst),
    .start(total_timer_start),
    .duration(total_duration),
    .done(total_timer_done),
    .counter(counter)
);
// Timer Control
reg timer_start;
reg [7:0] duration;
wire timer_done;

// Instantiate Timer Module
timer timer_inst (
    .clk(clk),
    .rst(rst),
    .start(timer_start),
    .duration(duration),
    .done(timer_done)
);

// state Timer Control
reg state_timer_start;
reg [7:0] state_duration;
wire state_timer_done;


// Instantiate Timer Module for state timing
timer state_timer_inst (
    .clk(clk),
    .rst(rst),
    .start(state_timer_start),
    .duration(state_duration),
    .done(state_timer_done)
);

// Washing Programs
parameter COLD_WASH     = 3'b000;
parameter HOT_WASH      = 3'b001;
parameter RINSING_DRY   = 3'b010;
parameter ONLY_DRY      = 3'b011;
parameter WARM_WASH     = 3'b100;

reg [3:0] drying_cycle_count;  // Counts the on/off cycles (3 bits for 0-7 range)

// Timing Configuration for Each Step (Example Durations)
parameter FILLING_TIME   = 8'd8; // Example: 8 cycles
parameter WASHING_TIME   = 8'd12; // Example: 12 cycles
parameter DRAINING_TIME  = 8'd8;  // Example: 8 cycles

parameter RINSING_TIME   = 8'd9; // Example: 9 cycles
parameter R_DRAINING_TIME  = 8'd15;  // Example: 15 cycles
parameter DRYING_TIME    = 8'd12; // Example: 12 cycles

// State Machine
always @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

// Next State Logic
always @(*) begin
    next_state = current_state; // Default to staying in the same state

    case (current_state)
        IDLE: begin
            if (power && start && doorclosed) begin
                case (program_selection)
                    COLD_WASH,HOT_WASH,WARM_WASH:   next_state = FILLING_WATER_SOAP; 
                    RINSING_DRY:   next_state = RINSING;
                    ONLY_DRY:       begin next_state = ONLY_DRYING; drying_cycle_count=0; end
                    default:        next_state = IDLE;
                endcase
            end
        end

        FILLING_WATER_SOAP: begin
            if (!soap) begin
                next_state = WAIT_FOR_SOAP;   // Transition to WAIT_FOR_SOAP if soap is not added
            end else begin
                timer_start = 1;
                duration = FILLING_TIME + WASHING_TIME + DRAINING_TIME + 22 ;
                total_timer_start = 1 ; 
                total_duration = (RINSING_TIME + R_DRAINING_TIME + DRYING_TIME + 16) + (FILLING_TIME + WASHING_TIME + DRAINING_TIME + 22)+2;
                state_timer_start=1;
                state_duration = FILLING_TIME/4;
                if (state_timer_done) begin
                    next_state = WASHING;
                    state_timer_start = 0;
                end
            end
        end

        WAIT_FOR_SOAP: begin
            if (soap) begin
                next_state = FILLING_WATER_SOAP;  // Resume filling when soap is added and pause_for_soap is pressed
            end else begin
                next_state = WAIT_FOR_SOAP;       // Remain in WAIT_FOR_SOAP state
            end
        end



        WASHING: begin
            state_timer_start=1;
            state_duration = WASHING_TIME/4;
            if (state_timer_done) begin
                next_state = DRAINING_WASH;
                state_timer_start = 0;
            end
        end

        DRAINING_WASH: begin
            state_timer_start=1;
            state_duration = DRAINING_TIME/4;

            if (state_timer_done) begin
                next_state = FILLING_WATER_SOAP;
                state_timer_start = 0;
                if (timer_done) begin
                    next_state = RINSING;
                    timer_start = 0;
                end
            end
        end

        RINSING: begin
            timer_start = 1;
            duration = RINSING_TIME + R_DRAINING_TIME + DRYING_TIME + 16;

            total_timer_start = 1;
            total_duration = duration; 
    
            state_timer_start=1;
            state_duration = RINSING_TIME/3;
            if (state_timer_done) begin
                next_state = DRAINING_RINSE;
                state_timer_start = 0;
            end
        end

        DRAINING_RINSE: begin
            state_timer_start=1;
            state_duration = R_DRAINING_TIME/3;
            if (state_timer_done) begin
                next_state = DRYING;
                state_timer_start = 0;
            end
        end

        DRYING: begin
            state_timer_start=1;
            state_duration = DRYING_TIME/3;

            if (state_timer_done) begin
                next_state = RINSING ;
                state_timer_start = 0;
                if (timer_done) begin
                    next_state = Finished;
                    timer_start = 0;
                end
            end
        end

        ONLY_DRYING: begin
            total_timer_start = 1; 
            total_duration = DRYING_TIME;
            if (!state_timer_start) begin
                // Start the state timer for DRYING_TIME / 4
                state_timer_start = 1;
                state_duration = DRYING_TIME / 4;
                
            end

            if (state_timer_done) begin
                // Toggle motor state
                motor = !motor; 

                // Increment the drying cycle counter
                drying_cycle_count = drying_cycle_count + 1;

                // Restart the state timer for the next cycle
                state_timer_start = 0;

                // If all 4 cycles are complete, transition to IDLE
                if (drying_cycle_count == 8) begin
                    motor = 0;  // Ensure motor is off before exiting
                    drying_cycle_count = 0;  // Reset cycle counter
                    next_state = Finished;
                    

                end
            end
        end

        Finished : begin
          program_done = 1 ;
          total_timer_start = 0 ; 
          next_state = IDLE;
        end

        default: begin
            next_state = IDLE;
        end
    endcase
end

// Output Control Logic
always @(*) begin
    // Default Output Values
    valve_in_cold = 0;
    valve_in_hot = 0;
    valve_out = 0;
    motor = 0;
    soap_warning = 0;     // Default to no warning
    soap_in=0;
    timer_display = counter;
    

    case (current_state)
        IDLE : begin
            program_done = 0;
            timer_start = 0;
        end
        FILLING_WATER_SOAP: begin
            if(soap)
            begin
                soap_in=1;
                if (program_selection == COLD_WASH) valve_in_cold = 1;
                else if (program_selection == HOT_WASH) valve_in_hot = 1; 
                else if (program_selection == WARM_WASH) begin valve_in_hot = 1;valve_in_cold = 1; end  
            end
        end
        WAIT_FOR_SOAP: begin
            soap_warning = 1;   // Show soap warning
        end
        WASHING: motor = 1;
        RINSING: valve_in_cold = 1;
        ONLY_DRY : motor = 1; 

        DRAINING_RINSE: valve_out = 1;     
        DRAINING_WASH: valve_out = 1;

        DRYING: motor = 2;
       
        default: begin
            // No active outputs in IDLE or invalid state
        end
    endcase
end

endmodule
