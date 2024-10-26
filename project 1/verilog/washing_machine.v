
module top(
    input clk,
    input rst
);
    wire timer_done;
    wire start_timer;
    reg [31:0] duration = 1000000;  
    wire [1:0] state;

    timer my_timer (
        .clk(clk),
        .rst(rst),
        .start(start_timer),
        .duration(duration),
        .done(timer_done)
    );

  
    fsm_with_timer my_fsm (
        .clk(clk),
        .rst(rst),
        .timer_done(timer_done),
        .start_timer(start_timer),
        .state(state)
    );
endmodule