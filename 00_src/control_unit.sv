

module control_unit (
    input clk, rst_n, start,
    input [31:0] instruction,        // 32-bit instruction
    input done_ECPM,                 // ECPM completion signal
    input done_ECPA,                 // ECPA completion signal
    input done_ECC_core,             // ECC core completion signal
    output reg start_ECPM,           // Start ECPM
    output reg start_ECPA,           // Start ECPA
    output reg start_ECC_core,       // Start ECC core
    output reg [1:0] wb_sel,               // Write-back select
    output reg [2:0] ecc_sel,        // Select ECC core
    output reg en_pc_update,         // Operation done
    output reg [1:0] ecc_control,    // ECC control signal
	output reg wb_wren,				 // Write-back enable
    output reg done                  // FSM completion signal
);

    // FSM States
    enum logic [2:0] {
        IDLE       = 3'b111,
        FETCH      = 3'b000,
        DECODE     = 3'b001,
        EXECUTE    = 3'b010,
        WRITE_BACK = 3'b011,
        DONE       = 3'b100
    } state, next_state;

    // Internal signals
    reg [6:0] opcode;
    reg [2:0] funct3;
   // reg [4:0] rs1, rs2, rd;          // Unused in current logic, kept for completeness
   // reg [2:0] ecc_control;           // ECC control signal
    wire done_EXECUTE;               // Combinational signal for completion
    assign done_EXECUTE = done_ECPM | done_ECC_core | done_ECPA;

    // Assign ecc_sel to funct3
    assign ecc_sel = funct3;

    // State Transition
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Decode Instruction
    always_comb begin
        opcode = instruction[6:0];
        funct3 = instruction[14:12];
    end

    // FSM Logic
    always_comb begin
        // Default outputs
        en_pc_update    = 0;
		wb_wren 		= 0; 
        wb_sel          = `SEL_ECC_CORE;
        done            = 0;
        ecc_control     = `MODULO;
        start_ECPM      = 0;
        start_ECPA      = 0;
        start_ECC_core  = 0;
        next_state      = IDLE;
        done = 0 ;
        case (state)
            IDLE: begin
                done = 0; // Reset done signal
                if (start)
                    next_state = FETCH;
                else
                    next_state = IDLE;
            end

            FETCH: begin
                //en_pc_update = 1;
                next_state   = DECODE;
            end

            DECODE: begin
                case (opcode[5:3])
                    3'b110: ecc_control = `MODULO;    // MODULO
                    3'b001: ecc_control = `MULSCL;    // MULSCL
                    3'b100: ecc_control = `MULSCLX;   // MULSCLX
                    3'b101: ecc_control = `ADD_SCLX;  // ADD_SCLX
                    default: ecc_control = `MODULO;
                endcase
                next_state = EXECUTE;
            end

            EXECUTE: begin
                case (opcode[5:3])
                    3'b110: begin start_ECC_core = 1; ecc_control = `MODULO; end      // MODULO
                    3'b001: begin start_ECPM     = 1; ecc_control = `MULSCL; end       // MULSCL
                    3'b100: begin start_ECPM     = 1; ecc_control = `MULSCLX; end       // MULSCLX
                    3'b111: begin start_ECPA     = 1; ecc_control = `ADD_SCLX; end     // ADD_SCLX
                    default: begin start_ECC_core = 1; ecc_control = `MODULO; end // Default case
                endcase
                if (done_EXECUTE)
                    next_state = WRITE_BACK;
                else
                    next_state = EXECUTE;
            end

            WRITE_BACK: begin
				wb_wren = 1;
                // Keep start_ECPM, start_ECPA, start_ECC_core as they were (no assignment here)
                case (opcode[5:3])
                    3'b110: begin ecc_control = `MODULO; wb_sel = `SEL_ECC_CORE; end   // MODULO
                    3'b001: begin ecc_control = `MULSCL; wb_sel = `SEL_ECPM; end   // MULSCL
                    3'b100: begin ecc_control = `MULSCLX; wb_sel = `SEL_ECPM; end // MULSCLX
                    3'b111: begin ecc_control = `ADD_SCLX; wb_sel = `SEL_ECPA; end // ADD_SCLX
                    default: begin ecc_control = `MODULO; wb_sel = `SEL_ECC_CORE; end
                endcase
                next_state = DONE;
            end

            DONE: begin
                // All signals except 'done' and 'next_state' revert to default
                en_pc_update    = 1;         // Default
				wb_wren			= 0;
                wb_sel          = `SEL_ECC_CORE;         // Default
                start_ECPM      = 0;         // Default
                start_ECPA      = 0;         // Default
                start_ECC_core  = 0;         // Default
                ecc_control     = `MODULO;   // Default
                done            = 1;         // Set to 1
                next_state      = IDLE;      // Transition to IDLE
            end
        endcase
    end

endmodule