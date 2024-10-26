module timer(
    input               clk,            
    input               rst,            
    input               start,          
    input      [31:0]   duration, 
    output reg          done        
);
           reg [31:0]   counter;    

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 32'b0;
            done <= 1'b0;
        end else if (start) begin
            if (counter == 32'b0) begin
                counter <= duration;
                done <= 1'b0;
            end else begin
                counter <= counter - 1;
                if (counter == 1) done <= 1'b1;
            end
        end
    end
endmodule