# RiscV-Processor
This is a in progress processor that will handle most of the RV-64I instructions.

### Architecture
<p align="center">
<img align="center" src="https://i.imgur.com/HzO9JM0.png">
</p>
The processor has 4 stage pipeline:
- Fetch - reads the next instruction and passes it to Decode.
- Decode - Decodes the instruction and reads registers.
- Execute - Excecutes the instruction.
- Write Back - Stores the values from Execute into registers.