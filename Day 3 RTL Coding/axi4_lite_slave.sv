// ============================================
// AXI4-Lite Memory-Mapped Slave
// Nik-Coronics | 7-Day AMBA Sprint — Day 3
// Engineer: Shiwank Gupta
// Date: 28 June 2026
// ============================================

module axi4_lite_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    // Global Signals
    input  logic        ACLK,
    input  logic        ARESETn,

    // AW Channel — Master → Slave
    input  logic        AWVALID,
    input  logic [31:0] AWADDR,
    input  logic [2:0]  AWPROT,
    output logic        AWREADY,

    // W Channel — Master → Slave
    input  logic        WVALID,
    input  logic [31:0] WDATA,
    input  logic [3:0]  WSTRB,
    output logic        WREADY,

    // B Channel — Slave → Master
    output logic        BVALID,
    output logic [1:0]  BRESP,
    input  logic        BREADY,

    // AR Channel — Master → Slave
    input  logic        ARVALID,
    input  logic [31:0] ARADDR,
    input  logic [2:0]  ARPROT,
    output logic        ARREADY,

    // R Channel — Slave → Master
    output logic        RVALID,
    output logic [31:0] RDATA,
    output logic [1:0]  RRESP,
    input  logic        RREADY
);

// ============================================
// Internal Signals
// ============================================

// Register File — 4 x 32-bit registers
logic [31:0] slv_reg [0:3];

// FSM State
typedef enum logic [1:0] {
    IDLE       = 2'b00,
    GOT_AW     = 2'b01,
    GOT_W      = 2'b10,
    WRITE_RESP = 2'b11
} state_t;

state_t wr_state;

// Internal latches
logic [31:0] awaddr_lat;
logic [31:0] wdata_lat;
logic [3:0]  wstrb_lat;

// ============================================
// WRITE PATH — FSM
// ============================================

always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
        wr_state   <= IDLE;
        AWREADY    <= 1'b0;
        WREADY     <= 1'b0;
        BVALID     <= 1'b0;
        BRESP      <= 2'b00;
        awaddr_lat <= '0;
        wdata_lat  <= '0;
        wstrb_lat  <= '0;
    end else begin
        case (wr_state)

            IDLE: begin
                AWREADY <= 1'b0;
                WREADY  <= 1'b0;
                BVALID  <= 1'b0;

                // Case 1: AW + W simultaneously
                if (AWVALID && WVALID) begin
                    AWREADY    <= 1'b1;
                    WREADY     <= 1'b1;
                    awaddr_lat <= AWADDR;
                    wdata_lat  <= WDATA;
                    wstrb_lat  <= WSTRB;
                    wr_state   <= WRITE_RESP;
                end
                // Case 2: AW only
                else if (AWVALID && !WVALID) begin
                    AWREADY    <= 1'b1;
                    awaddr_lat <= AWADDR;
                    wr_state   <= GOT_AW;
                end
                // Case 3: W only
                else if (WVALID && !AWVALID) begin
                    WREADY    <= 1'b1;
                    wdata_lat <= WDATA;
                    wstrb_lat <= WSTRB;
                    wr_state  <= GOT_W;
                end
            end

            GOT_AW: begin
                AWREADY <= 1'b0;
                // Wait for W
                if (WVALID) begin
                    WREADY    <= 1'b1;
                    wdata_lat <= WDATA;
                    wstrb_lat <= WSTRB;
                    wr_state  <= WRITE_RESP;
                end
            end

            GOT_W: begin
                WREADY <= 1'b0;
                // Wait for AW
                if (AWVALID) begin
                    AWREADY    <= 1'b1;
                    awaddr_lat <= AWADDR;
                    wr_state   <= WRITE_RESP;
                end
            end

            WRITE_RESP: begin
                AWREADY <= 1'b0;
                WREADY  <= 1'b0;

                // Write to register using WSTRB
                if (wstrb_lat[0]) slv_reg[awaddr_lat[3:2]][7:0]   <= wdata_lat[7:0];
                if (wstrb_lat[1]) slv_reg[awaddr_lat[3:2]][15:8]  <= wdata_lat[15:8];
                if (wstrb_lat[2]) slv_reg[awaddr_lat[3:2]][23:16] <= wdata_lat[23:16];
                if (wstrb_lat[3]) slv_reg[awaddr_lat[3:2]][31:24] <= wdata_lat[31:24];

                // Assert response
                BVALID <= 1'b1;
                BRESP  <= 2'b00; // OKAY

                // Wait for Master BREADY
                if (BREADY) begin
                    BVALID   <= 1'b0;
                    wr_state <= IDLE;
                end
            end

            default: wr_state <= IDLE;

        endcase
    end
end

// ============================================
// READ PATH
// ============================================

always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
        ARREADY <= 1'b0;
        RVALID  <= 1'b0;
        RDATA   <= '0;
        RRESP   <= 2'b00;
    end else begin
        if (ARVALID && !RVALID) begin
            ARREADY <= 1'b1;
            RVALID  <= 1'b1;
            RDATA   <= slv_reg[ARADDR[3:2]];
            RRESP   <= 2'b00; // OKAY
        end else begin
            ARREADY <= 1'b0;
        end

        if (RVALID && RREADY) begin
            RVALID <= 1'b0;
        end
    end
end

endmodule