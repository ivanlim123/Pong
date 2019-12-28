module debounce(clk, pb, pb_debounced);
    input clk;
    input pb;
    output pb_debounced;

    reg [4-1:0] DFF;

    always @(posedge clk) begin
        DFF <= {DFF[2:0], pb};
    end

    assign pb_debounced = &DFF;

endmodule


