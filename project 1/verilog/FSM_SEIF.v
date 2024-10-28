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
    output reg        motor,
    output reg  [7:0] timer_display,
    output reg        program_done,
    output reg        soap_warning       // Add this line

);


wire       pause_for_soap;


// State Definitions
reg [2:0] current_state, next_state;
parameter IDLE                  = 3'b000;
parameter FILLING_WATER_SOAP    = 3'b001;
parameter WASHING               = 3'b010;
parameter RINSING               = 3'b011;
parameter DRAINING_WASH         = 3'b100;
parameter DRAINING_RINSE        = 3'b101;
parameter DRYING                = 3'b110;
parameter WAIT_FOR_SOAP         = 3'b111;    


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

// Washing Programs
parameter COLD_WASH     = 3'b000;
parameter HOT_WASH      = 3'b001;
parameter RINSING_DRY  = 3'b010;
parameter ONLY_DRY      = 3'b011;

// Timing Configuration for Each Step (Example Durations)
parameter FILLING_TIME   = 8'd10; // Example: 10 cycles
parameter WASHING_TIME   = 8'd20; // Example: 20 cycles
parameter RINSING_TIME   = 8'd15; // Example: 15 cycles
parameter DRAINING_TIME  = 8'd8;  // Example: 8 cycles
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
    timer_start = 0;

    case (current_state)
        IDLE: begin
            program_done = 0;
            if (power && start && doorclosed) begin
                case (program_selection)
                    COLD_WASH:      next_state = FILLING_WATER_SOAP;
                    HOT_WASH:       next_state = FILLING_WATER_SOAP;
                    RINSING_DRY:   next_state = RINSING;
                    ONLY_DRY:       next_state = DRYING;
                    default:        next_state = IDLE;
                endcase
            end
        end

        FILLING_WATER_SOAP: begin
            if (!soap) begin
                next_state = WAIT_FOR_SOAP;   // Transition to WAIT_FOR_SOAP if soap is not added
            end else begin
                timer_start = 1;
                duration = FILLING_TIME;
                if (timer_done) begin
                    valve_in_cold = 0;
                    valve_in_hot = 0;
                    next_state = WASHING;
                    timer_start = 0;
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
            motor = 1;
            duration = WASHING_TIME;
            timer_start = 1;
            if (timer_done) begin
                motor = 0;
                next_state =  DRAINING_WASH;
                timer_start = 0;
            end
        end

        DRAINING_WASH: begin
            valve_out = 1;
            duration = DRAINING_TIME;
            timer_start = 1;
            if (timer_done) begin
                valve_out = 0;
                next_state = RINSING;
                timer_start = 0;

            end
        end

        RINSING: begin
            valve_in_cold = 1;
            duration = RINSING_TIME;
            timer_start = 1;
            if (timer_done) begin
                valve_in_cold = 0;
                next_state = DRAINING_RINSE;
                timer_start = 0;
            end
        end

        DRAINING_RINSE: begin
            valve_out = 1;
            duration = DRAINING_TIME;
            timer_start = 1;
            if (timer_done) begin
                valve_out = 0;
                next_state = DRYING;
                timer_start = 0;
            end
        end

        DRYING: begin
            motor = 1;
            duration = DRYING_TIME;
            timer_start = 1;
            if (timer_done) begin
                motor = 0;
                program_done = 1;
                next_state = IDLE;
                timer_start = 0;

            end
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
    timer_display = duration;
    soap_warning = 0;     // Default to no warning

    case (current_state)
        FILLING_WATER_SOAP: begin
            if(soap)
                if (program_selection == COLD_WASH) valve_in_cold = 1;
                else if (program_selection == HOT_WASH) valve_in_hot = 1;
        end
        WAIT_FOR_SOAP: begin
            soap_warning = 1;   // Show soap warning
        end
        WASHING: motor = 1;
        RINSING: valve_in_cold = 1;

        DRAINING_RINSE: valve_out = 1;     
        DRAINING_WASH: valve_out = 1;

        DRYING: motor = 1;
       
        default: begin
            // No active outputs in IDLE or invalid state
        end
    endcase
end

endmodule
