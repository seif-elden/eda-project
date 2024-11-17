module timer(
    input               clk,            
    input               rst,            
    input               start,          
    input      [7:0]    duration, 
    output reg          done,        
    output wire [7:0]   counter  // Changed to output wire
);

    reg [7:0] counter_internal; // Internal register to hold the counter value

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_internal <= 8'b0;
            done <= 1'b0;
        end else if (start) begin
            if (counter_internal == 8'b0) begin
                counter_internal <= duration;
                done <= 1'b0;
            end else begin
                counter_internal <= counter_internal - 1;
                if (counter_internal == 1) begin
                    done <= 1'b1;
                    counter_internal <= 8'b0 ;
                end
            end
        end
    end

    assign counter = counter_internal; // Assign internal register to the output wire
endmodule
