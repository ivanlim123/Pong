module onepulse(clk, pb_debounced, pb_onepulse);
    input clk;
    input pb_debounced;
    output pb_onepulse;

    reg pb_debounced_delay;
    reg pb_onepulse;

    always @(posedge clk) begin
        pb_onepulse <= pb_debounced & (!pb_debounced_delay);
        pb_debounced_delay <= pb_debounced;
    end

endmodule
