module fsm_with_timer(

    input clk,          // Clock input
    input rst,          // Reset input
    input timer_done,   // Timer done signal from the timer module
    output reg start_timer,  // Signal to start the timer
    output reg [1:0] state    // FSM states (00, 01, 10, etc.)
);

    // Define state encoding
    parameter S0 = 2'b00;
    parameter S1 = 2'b01;
    parameter S2 = 2'b10;

    reg [1:0] next_state;

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0;  // Start at state S0
        else
            state <= next_state;
    end

    // FSM state transitions
    always @(*) begin
        case (state)
            S0: begin
                start_timer = 1;  // Start the timer
                if (timer_done)
                    next_state = S1;
                else
                    next_state = S0;
            end

            S1: begin
                start_timer = 1;  // Start the timer again for S1
                if (timer_done)
                    next_state = S2;
                else
                    next_state = S1;
            end

            S2: begin
                start_timer = 0;  // Stop the timer in S2
                next_state = S2;  // Stay in state S2
            end

            default: begin
                start_timer = 0;
                next_state = S0;
            end
        endcase
    end
endmodule

module FSMW(

    // INPUTS //

input  wire       power,
input  wire       clk,
input  wire       rst,
input  wire [1:0] program_selection,
input  wire       task_selection,
input  wire [1:0] pause_resume,

    // OUTPUTS //

output reg        valve_in_cold,
output reg        valve_in_hot,
output reg        valve_out,
output reg        motor,
output reg  [7:0] display,
output reg        dry_done,
output reg        wash_done,
output reg        rinse_done,
output reg        current_state
);


////// defining the states //////


reg [2:0] next_state;


parameter IDLE          = 3'b000 ;
parameter filling_water = 3'b001 ;
parameter washing       = 3'b010 ;
parameter rinsing       = 3'b100 ;
parameter drying        = 3'b011 ;
parameter pause         = 3'b101 ;
parameter draining      = 3'b110 ;
parameter no_need       = 3'b111 ;

always @(posedge clk,negedge rst) begin
    if (!rst)
         current_state <= IDLE; 
     else 
         current_state <= next_state; 
     
end
//////next state logic//////
always @(*) begin
    case (current_state)
        IDLE :          begin
                        
                        


                        end   
        filling_water : begin
            




                        end
        washing :       begin
            




                        end
        rinsing :       begin
            



                        end 
        drying :        begin
            



                        end 
        pause :         begin
            




                        end    
        draining :      begin
            




                        end 
        default :       begin
            




                        end         
    endcase
end    
//////output logic//////
always @(*) begin
    case (current_state)
        IDLE :          begin
                        
                        


                        end   
        filling_water : begin
            




                        end
        washing :       begin
            




                        end
        rinsing :       begin
            



                        end 
        drying :        begin
            



                        end 
        pause :         begin
            




                        end    
        draining :      begin
            




                        end 
        default :       begin
            




                        end         
    endcase
end
endmodule