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

constant BP_FUNCT6_BEGIN: integer := 26;
constant BP_FUNCT6_END: integer := 31;

constant BP_FUNCT3_BEGIN: integer := 12;
constant BP_FUNCT3_END: integer := 14;

constant BP_RD_BEGIN: integer := 7;
constant BP_RD_END: integer := 11;

constant BP_SHAMT_BEGIN: integer := 20;
constant BP_SHAMT_END: integer := 24;

constant BP_SHAMTW_BEGIN: integer := 20;
constant BP_SHAMTW_END: integer := 23;

constant BP_IMM_11_0_BEGIN: integer := 20;
constant BP_IMM_11_0_END: integer := 31;

constant BP_IMM_31_12_BEGIN: integer := 12;
constant BP_IMM_31_12_END: integer := 31;





-- Instructions
constant INSTRUCTION_NOP:     integer := 0;   -- No-OP
-- RV-321
constant INSTRUCTION_LUI:     integer := 1;   -- Load Upper Immediate
constant INSTRUCTION_AUIPC:   integer := 2;   -- Add Upper Immediate to PC
constant INSTRUCTION_JAL:     integer := 3;   -- Jump And Link
constant INSTRUCTION_JALR:    integer := 4;   -- Jump And Link Register
constant INSTRUCTION_BEQ:     integer := 5;   -- Branch if Equal
constant INSTRUCTION_BNE:     integer := 6;   --
constant INSTRUCTION_BLT:     integer := 7;   --
constant INSTRUCTION_BGE:     integer := 8;   --
constant INSTRUCTION_BLTU:    integer := 9;   --
constant INSTRUCTION_BGEU:    integer := 10;  --
constant INSTRUCTION_LB:      integer := 11; --
constant INSTRUCTION_LH:      integer := 12; --
constant INSTRUCTION_LW:      integer := 13; --
constant INSTRUCTION_LBU:     integer := 14; --
constant INSTRUCTION_LHU:     integer := 15; --
constant INSTRUCTION_SB:      integer := 16; --
constant INSTRUCTION_SH:      integer := 17; --
constant INSTRUCTION_SW:      integer := 18; --
constant INSTRUCTION_ADDI:    integer := 19; --
constant INSTRUCTION_SLTI:    integer := 20; --
constant INSTRUCTION_SLTIU:   integer := 21; --
constant INSTRUCTION_XORI:    integer := 22; --
constant INSTRUCTION_ORI:     integer := 23; --
constant INSTRUCTION_ANDI:    integer := 24; --
constant INSTRUCTION_SLLI:    integer := 25; --
constant INSTRUCTION_SRLI:    integer := 26; --
constant INSTRUCTION_SRAI:    integer := 27; --
constant INSTRUCTION_ADD:     integer := 28; --
constant INSTRUCTION_SUB:     integer := 29; --
constant INSTRUCTION_SLL:     integer := 30; --
constant INSTRUCTION_SLT:     integer := 31; --
constant INSTRUCTION_SLTU:    integer := 32; --
constant INSTRUCTION_XOR:     integer := 33; --
constant INSTRUCTION_SRL:     integer := 34; --
constant INSTRUCTION_SRA:     integer := 35; --
constant INSTRUCTION_OR:      integer := 36; --
constant INSTRUCTION_AND:     integer := 37; --
constant INSTRUCTION_FENCE:   integer := 38; -- Fence Memory and I/O
constant INSTRUCTION_FENCE_I: integer := 39; -- Fence Instruction Stream
constant INSTRUCTION_ECALL:   integer := 40; --
constant INSTRUCTION_EBREAK:  integer := 41; --
constant INSTRUCTION_CSRRW:   integer := 42; --
constant INSTRUCTION_CSRRS:   integer := 43; --
constant INSTRUCTION_CSRRC:   integer := 44; --
constant INSTRUCTION_CSRRWI:  integer := 45; --
constant INSTRUCTION_CSRRSI:  integer := 46; --
constant INSTRUCTION_CSRRCI:  integer := 47; --
-- RV-64I
constant INSTRUCTION_LWU:     integer := 48; --
constant INSTRUCTION_LD:      integer := 49; --
constant INSTRUCTION_SD:      integer := 50; --
constant INSTRUCTION_ADDIW:   integer := 51; --
constant INSTRUCTION_SLLIW:   integer := 52; --
constant INSTRUCTION_SRLIW:   integer := 53; --
constant INSTRUCTION_SRAIW:   integer := 54; --
constant INSTRUCTION_ADDW:    integer := 55; --
constant INSTRUCTION_SUBW:    integer := 56; --
constant INSTRUCTION_SLLW:    integer := 57; --
constant INSTRUCTION_SRLW:    integer := 58; --
constant INSTRUCTION_SRAW:    integer := 59; --



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
constant MEM_MEM_BEGIN: integer := 0;
constant MEM_MEM_END: integer := 65535;

constant MEM_IO_BEGIN: integer := 0;
constant MEM_IO_END: integer := 65535;

constant MEM_UART_BEGIN: integer := 0;
constant MEM_UART_END: integer := 65535;








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