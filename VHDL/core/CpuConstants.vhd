library IEEE;
use IEEE.STD_LOGIC_1164.all;
package cpu_constants is

--Bit Positions
constant BP_OPCODE_BEGIN: integer := 0;
constant BP_OPCODE_END: integer := 6;

constant BP_RS2_BEGIN: integer := 20;
constant BP_RS2_END: integer := 24;

constant BP_RS1_BEGIN: integer := 15;
constant BP_RS1_END: integer := 19;

constant BP_FUNCT7_BEGIN: integer := 25;
constant BP_FUNCT7_END: integer := 31;

constant BP_FUNCT3_BEGIN: integer := 12;
constant BP_FUNCT3_END: integer := 14;

constant BP_RD_BEGIN: integer := 7;
constant BP_RD_END: integer := 11;

constant BP_I_IMM_11_0_BEGIN: integer := 20;
constant BP_I_IMM_11_0_END: integer := 31;

constant BP_I_IMM_11_5_BEGIN: integer := 25;
constant BP_I_IMM_11_5_END: integer := 31;

constant BP_I_IMM_11_4_BEGIN: integer := 24;
constant BP_I_IMM_11_4_END: integer := 31;

constant BP_I_SHAMT_BEGIN: integer := 20;
constant BP_I_SHAMT_0_END: integer := 24;

constant BP_I_SHAMTW_BEGIN: integer := 20;
constant BP_I_SHAMTW_0_END: integer := 23;

constant BP_S_IMM_11_5_BEGIN: integer := 25;
constant BP_S_IMM_11_5_END: integer := 31;

constant BP_S_IMM_4_0_BEGIN: integer := 7;
constant BP_S_IMM_4_0_END: integer := 11;

constant BP_B_IMM_12: integer := 31;

constant BP_B_IMM_10_5_BEGIN: integer := 25;
constant BP_B_IMM_10_5_END: integer := 30;

constant BP_B_IMM_4_1_BEGIN: integer := 8;
constant BP_B_IMM_4_1_END: integer := 11;

constant BP_B_IMM_11: integer := 7;

constant BP_U_IMM_31_12_BEGIN: integer := 12;
constant BP_U_IMM_31_12_END: integer := 31;

constant BP_J_IMM_20: integer := 31;

constant BP_J_IMM_10_1_BEGIN: integer := 21;
constant BP_J_IMM_10_1_END: integer := 30;

constant BP_J_IMM_11: integer := 20;

constant BP_J_IMM_19_12_BEGIN: integer := 12;
constant BP_J_IMM_19_12_END: integer := 19;



-- Instructions
constant INSTRUCTION_NOP:     integer := ;  -- No-op
-- RV-321
constant INSTRUCTION_LUI:     integer := ;  -- Load upper immediate
constant INSTRUCTION_AUIPC:   integer := ;  -- Add upper immediate to PC
constant INSTRUCTION_JAL:     integer := ;  -- Jump and link
constant INSTRUCTION_JALR:    integer := ;  --
constant INSTRUCTION_BEQ:     integer := ;  --
constant INSTRUCTION_BNE:     integer := ;  --
constant INSTRUCTION_BLT:     integer := ;  --
constant INSTRUCTION_BGE:     integer := ;  --
constant INSTRUCTION_BLTU:    integer := ;  --
constant INSTRUCTION_BGEU:    integer := ;  --
constant INSTRUCTION_LB:      integer := ; --
constant INSTRUCTION_LH:      integer := ; --
constant INSTRUCTION_LW:      integer := ; --
constant INSTRUCTION_LBU:     integer := ; --
constant INSTRUCTION_LHU:     integer := ; --
constant INSTRUCTION_SB:      integer := ; --
constant INSTRUCTION_SH:      integer := ; --
constant INSTRUCTION_SW:      integer := ; --
constant INSTRUCTION_ADDI:    integer := ; --
constant INSTRUCTION_SLTI:    integer := ; --
constant INSTRUCTION_SLTIU:   integer := ; --
constant INSTRUCTION_XORI:    integer := ; --
constant INSTRUCTION_ORI:     integer := ; --
constant INSTRUCTION_ANDI:    integer := ; --
constant INSTRUCTION_SLLI:    integer := ; --
constant INSTRUCTION_SRLI:    integer := ; --
constant INSTRUCTION_SRAI:    integer := ; --
constant INSTRUCTION_ADD:     integer := ; --
constant INSTRUCTION_SUB:     integer := ; --
constant INSTRUCTION_SLL:     integer := ; --
constant INSTRUCTION_SLT:     integer := ; --
constant INSTRUCTION_SLTU:    integer := ; --
constant INSTRUCTION_XOR:     integer := ; --
constant INSTRUCTION_SRL:     integer := ; --
constant INSTRUCTION_SRA:     integer := ; --
constant INSTRUCTION_OR:      integer := ; --
constant INSTRUCTION_AND:     integer := ; --
constant INSTRUCTION_FENCE:   integer := ; -- Fence Memory and I/O
constant INSTRUCTION_FENCE_I: integer := ; -- Fence Instruction Stream
constant INSTRUCTION_ECALL:   integer := ; --
constant INSTRUCTION_EBREAK:  integer := ; --
constant INSTRUCTION_CSRRW:   integer := ; --
constant INSTRUCTION_CSRRS:   integer := ; --
constant INSTRUCTION_CSRRC:   integer := ; --
constant INSTRUCTION_CSRRWI:  integer := ; --
constant INSTRUCTION_CSRRSI:  integer := ; --
constant INSTRUCTION_CSRRCI:  integer := ; --
-- RV-64I
constant INSTRUCTION_LWU:     integer := ; --
constant INSTRUCTION_LD:      integer := ; --
constant INSTRUCTION_SD:      integer := ; --
constant INSTRUCTION_SLLI:    integer := ; --
constant INSTRUCTION_SRLI:    integer := ; --
constant INSTRUCTION_SRAI:    integer := ; --
constant INSTRUCTION_ADDIW:   integer := ; --
constant INSTRUCTION_SLLIW:   integer := ; --
constant INSTRUCTION_SRLIW:   integer := ; --
constant INSTRUCTION_SRAIW:   integer := ; --
constant INSTRUCTION_ADDW:    integer := ; --
constant INSTRUCTION_SUBW:    integer := ; --
constant INSTRUCTION_SLLW:    integer := ; --
constant INSTRUCTION_SRLW:    integer := ; --
constant INSTRUCTION_SRAW:    integer := ; --



-- Opcodes
constant OPCODE_LUI: std_logic_vector(6 downto 0) := "0110111";
constant OPCODE_AUIPC: std_logic_vector(6 downto 0) := "0010111";
constant OPCODE_JAL: std_logic_vector(6 downto 0) := "1101111";
constant OPCODE_JALR: std_logic_vector(6 downto 0) := "1100111";
constant OPCODE_BRANCH: std_logic_vector(6 downto 0) := "1100011";
constant OPCODE_LOAD: std_logic_vector(6 downto 0) := "0000011";
constant OPCODE_STORE: std_logic_vector(6 downto 0) := "0100011";
constant OPCODE_ARITHMETIC_1: std_logic_vector(6 downto 0) := "0010011";
constant OPCODE_ARITHMETIC_2: std_logic_vector(6 downto 0) := "0110011";
constant OPCODE_FENCE: std_logic_vector(6 downto 0) := "0001111";
constant OPCODE_CONTROLL: std_logic_vector(6 downto 0) := "1110011";
constant OPCODE_ARITHMETIC_3: std_logic_vector(6 downto 0) := "0011011";
constant OPCODE_ARITHMETIC_4: std_logic_vector(6 downto 0) := "0111011";














-- Memory mappings
constant MEM_RAM_END: integer := 65535;
constant MEM_PROGRAM_START: integer := 0;

constant MEM_UART_DATA: integer := 65536;
constant MEM_UART_STATUS: integer := 65537;
constant UART_AVAILABLE_BIT: integer := 1;
constant UART_TXRDY_BIT: integer := 0;


constant MEM_IO_BUTTONS: integer := 65538;
constant MEM_IO_SWITCHES: integer := 65539;
constant MEM_IO_LEDS: integer := 65540;

constant MEM_IO_RGB_0R: integer := 65541;
constant MEM_IO_RGB_0G: integer := 65542;
constant MEM_IO_RGB_0B: integer := 65543;

constant MEM_IO_RGB_1R: integer := 65544;
constant MEM_IO_RGB_1G: integer := 65545;
constant MEM_IO_RGB_1B: integer := 65546;

constant MEM_IO_RGB_2R: integer := 65547;
constant MEM_IO_RGB_2G: integer := 65548;
constant MEM_IO_RGB_2B: integer := 65549;

constant MEM_IO_RGB_3R: integer := 65550;
constant MEM_IO_RGB_3G: integer := 65551;
constant MEM_IO_RGB_3B: integer := 65552;


end cpu_constants;
package body cpu_constants is
end cpu_constants;