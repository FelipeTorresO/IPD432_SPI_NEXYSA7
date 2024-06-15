`timescale 1ns / 1ps

module Top_Acc_SPI_TB;

    // Parameters
    parameter MAX_BYTES_PER_CS_aux = 10;
    parameter CLK_PERIOD = 10;              // Clock period in ns (100MHz clock)


    // Signals
    logic CLK100MHZ;
    logic CPU_RESETN;
    logic ACL_MISO;
    logic ACL_MOSI;
    logic ACL_SCLK;
    logic ACL_CSN;
    logic TX_Ready_aux;
    logic CPOL_aux;
	logic CPHA_aux;
    logic RX_DV_aux;
    logic [$clog2(MAX_BYTES_PER_CS_aux+1)-1:0] RX_Count_aux;
    logic [7:0] RX_Byte_aux;
    logic TX_DV_aux;
    logic [7:0] TX_Byte_aux;
    logic [$clog2(MAX_BYTES_PER_CS_aux+1)-1:0] TX_Count_aux;
    logic [47:0] To_Seven_Seg_aux;

    // Clock generation
    initial begin
        CLK100MHZ = 1'b0;
        forever #(CLK_PERIOD / 2) CLK100MHZ = ~CLK100MHZ;
    end

    // Reset generation
    initial begin
        CPU_RESETN = 1'b0;
        #100;
        CPU_RESETN = 1'b1;
        #10000000
        CPU_RESETN = 1'b0;
        #100;
        CPU_RESETN = 1'b1;
    end

    // Instantiate the Comunicacion_Acc module
    Comunicacion_Acc
    #(
        .MAX_WAIT(5000000),
        .SIX_MS(600000),
        .TEN_MS(1000000),
        .FOURTY_MS(4000000),
        .MAX_BYTES_PER_CS(MAX_BYTES_PER_CS_aux)
    )
    Comunicacion_Acc_inst
    (
        .clk(CLK100MHZ),
        .rst(~CPU_RESETN),
        .TX_Ready(TX_Ready_aux),
        .RX_DV(RX_DV_aux),
        .RX_Count(RX_Count_aux),
        .RX_Byte(RX_Byte_aux),
        .TX_DV(TX_DV_aux),
        .CPOL(CPOL_aux),
	    .CPHA(CPHA_aux),
        .TX_Byte(TX_Byte_aux),
        .TX_Count(TX_Count_aux),
        .To_Seven_Seg(To_Seven_Seg_aux)
    );

    // Instantiate the SPI_Master_With_Single_CS module
    SPI_Master
    #(
        .CLKS_PER_HALF_BIT(50),
        .MAX_BYTES_PER_CS(MAX_BYTES_PER_CS_aux),
        .CS_INACTIVE_CLKS(0)
    )
    SPI_Master
    (
        // Control/Data Signals,
        .i_Rst(~CPU_RESETN),
        .i_Clk(CLK100MHZ),
        .i_CPOL(CPOL_aux),
        .i_CPHA(CPHA_aux),
        // TX (MOSI) Signals
        .i_TX_Count(TX_Count_aux),
        .i_TX_Byte(TX_Byte_aux),
        .i_TX_DV(TX_DV_aux),
        .o_TX_Ready(TX_Ready_aux),
        // RX (MISO) Signals
        .o_RX_Count(RX_Count_aux),
        .o_RX_DV(RX_DV_aux),
        .o_RX_Byte(RX_Byte_aux),
        // SPI Interface
        .o_SPI_Clk(ACL_SCLK),
        .i_SPI_MISO(ACL_MISO),
        .o_SPI_MOSI(ACL_MOSI),
        .o_SPI_CS_n(ACL_CSN)
    );

    // Stimulus generation
    initial begin
        // Wait for reset de-assertion
        wait(CPU_RESETN == 1);

        // Initial stimulus
        ACL_MISO = 1'b0;

        // Simulate data transmission and reception
        repeat (10) begin
            @(posedge CLK100MHZ);
            // Add stimulus here, e.g., changing ACL_MISO or driving TX_DV_aux and TX_Byte_aux
        end

        // End simulation after some time
        #1000;
        $finish;
    end

    // Monitor the signals
    initial begin
        $monitor("Time: %0t | TX_Ready: %0b | RX_DV: %0b | RX_Byte: %0h | TX_DV: %0b | TX_Byte: %0h",
                 $time, TX_Ready_aux, RX_DV_aux, RX_Byte_aux, TX_DV_aux, TX_Byte_aux);
    end

endmodule
