// ============================================
// Functional Coverage — Day 7
// AXI4-Lite Coverage Model
// ============================================
covergroup axi_cov @(posedge ACLK);

    // Address coverage
    cp_addr: coverpoint AWADDR {
        bins reg0 = {32'h00000000};
        bins reg1 = {32'h00000004};
        bins reg2 = {32'h00000008};
        bins reg3 = {32'h0000000C};
    }

    // Write channel activity
    cp_wvalid: coverpoint WVALID {
        bins active = {1};
        bins idle   = {0};
    }

    // Read channel activity
    cp_arvalid: coverpoint ARVALID {
        bins active = {1};
        bins idle   = {0};
    }

    // Response tracking
    cp_bresp: coverpoint BRESP {
        bins okay   = {2'b00};
        bins slverr = {2'b10};
    }

    // Cross — address × write activity
    cx_addr_wvalid: cross cp_addr, cp_wvalid;

endgroup

// Instantiate + sample
axi_cov cov_inst = new();