//`ifndef CONSTANT
// ALU operations {inst [30], funct3}
`define ALU_ADD                 2'b00
`define ALU_SUB                 2'b01
`define ALU_MULT                2'b10
`define ALU_INV                 2'b11
//REGFILE CONTROL
`define MODULO                  3'b010
`define MULSCL                  3'b001
`define MULSCLX                 3'b000
`define ADD_SCLX                3'b011
`define AFFINE			3'b100
//WB_SEL
`define SEL_ECC_CORE            2'b01
`define SEL_ECPM               2'b00
`define SEL_ECPA               2'b10
`define SEL_AFFINE             2'b11

