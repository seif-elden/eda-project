module timer(
    input               clk,            
    input               rst,            
    input               start,          
    input      [7:0]   duration, 
    output reg          done,        
    output reg [7:0]    counter    
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 7'b0;
            done <= 1'b0;
        end else if (start) begin
            if (counter == 7'b0) begin
                counter <= duration;
                done <= 1'b0;
            end else begin
                counter <= counter - 1;
                if (counter == 1)begin
                    done <= 1'b1;
                    counter <= counter - 1 ;
                end
            end
        end
    end
endmodule