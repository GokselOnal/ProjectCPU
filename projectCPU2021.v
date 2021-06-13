// Göksel can ÖNAL
// S011827

`timescale 1ns / 1ps

module projectCPU2021(
  clk,
  rst,
  wrEn,
  data_fromRAM,
  addr_toRAM,
  data_toRAM,
  PC,
  W
);


input clk, rst;
input wire [15:0] data_fromRAM;
output reg [15:0] data_toRAM;
output reg wrEn;

// 12 can be made smaller so that it fits in the FPGA
output reg [12:0] addr_toRAM;
output reg [12:0] PC; // This has been added as an output for TB purposes
output reg [15:0] W;  // This has been added as an output for TB purposes


// Your design goes in here

// internal signals
reg [12:0] PCNext;
reg [ 2:0] opcode, opcodeNext;
reg [12:0] operand, operandNext;
reg [ 2:0] state, stateNext;
reg [15:0] WNext;

always @(posedge clk) begin
    state   <= #1 stateNext;
	PC      <= #1 PCNext;
	opcode  <= #1 opcodeNext;
	operand <= #1 operandNext;
	W       <= #1 WNext;
end

always @(*) begin
    stateNext   = state;
	PCNext      = PC;
	opcodeNext  = opcode;
	operandNext = operand;
	addr_toRAM  = 0;
	wrEn        = 0;
	data_toRAM  = 0;
	WNext       = W;
    if (rst) begin
        stateNext   = 0;
		PCNext      = 0;
		opcodeNext  = 0;
		operandNext = 0;
		addr_toRAM  = 0;
		wrEn        = 0;
		data_toRAM  = 0;
		WNext       = 0;
	end else
	    case (state)
		    0: begin
                PCNext      = PC;
				opcodeNext  = opcode;
				operandNext = 0;
				addr_toRAM  = PC;
				wrEn        = 0;
				data_toRAM  = 0;
				stateNext   = 1;
				WNext       = W;
			end
			1: begin
			    PCNext      = PC;
				opcodeNext  = data_fromRAM[15:13];
				operandNext = data_fromRAM[12:0 ];
				addr_toRAM  = data_fromRAM[12:0 ];
				wrEn        = 0;
				data_toRAM  = 0;
				WNext       = W;
				if (operandNext == 0)  // Indirect Addressing
				    stateNext = 3;
				else begin
				    if (opcodeNext == 3'b110) begin  // CPfW
					    PCNext     = PC + 1;
						wrEn       = 1;
						data_toRAM = WNext;
				        stateNext  = 0;
					end
				    else
				        stateNext = 2;
			    end
			end
			2: begin
			    PCNext      = PC + 1;
				opcodeNext  = opcode;
				operandNext = operand;
				wrEn        = 0;
				WNext       = W;
				if (opcode == 3'b000)  // ADD
				    WNext = W + data_fromRAM;
					
				else if (opcode == 3'b001)  // NAND
				    WNext = ~(W & data_fromRAM);
					
				else if (opcode == 3'b010) begin  // SRRL 
				    if (data_fromRAM < 16)
					    WNext = W >> data_fromRAM;
					else if (data_fromRAM >= 16 && data_fromRAM <= 31)
					    WNext = W << data_fromRAM[3:0];
					else if (data_fromRAM >= 32 && data_fromRAM <= 47)                           
						WNext = (W >> data_fromRAM[3:0]) | (W << (16 - data_fromRAM[3:0]));  // rotation using shift=> (W >> n) | (W << 16 - n)
					else
					    WNext = (W << data_fromRAM[3:0]) | (W >> (16 - data_fromRAM[3:0]));
				end
				
				else if (opcode == 3'b011)  // GE
				    /*if (W >= data_fromRAM)
					    WNext = 1;
				    end
				    else 
					    WNext = 0;*/
					WNext = (W >= data_fromRAM) ? 1 : 0;
				
				else if (opcode == 3'b100)  // SZ
				    /*if(data_fromRAM == 0)
					    PCNext = PC + 2;*/
					PCNext = (data_fromRAM == 0) ? (PC + 2) : (PC + 1);
				
				else if (opcode == 3'b101)  // CP2W
				    WNext = data_fromRAM;
					
				else if (opcode == 3'b111)  // JMP
				    PCNext = data_fromRAM;
					
				stateNext = 0;
			end
			3: begin  // Indirect Addressing
				addr_toRAM  = 2;  // request for *2
			    stateNext   = 4;
			end
			4: begin  // request for **2 and make CPfWi  
				opcodeNext  = opcode;
				addr_toRAM  = data_fromRAM;  
				WNext       = W;
				if (opcode == 3'b110) begin  // CPfWi
					PCNext     = PC + 1;
					wrEn       = 1;
					data_toRAM = WNext;
					stateNext  = 0;
				end
				else
			        stateNext = 2; // make same instructions with **2 instead of *A
			end
			default: begin
			    stateNext  = 0;
				PCNext     = 0;
				opcodeNext = 0;
				operand    = 0;
				addr_toRAM = 0;
				wrEn       = 0;
				data_toRAM = 0;
				WNext      = 0;
			end
		endcase
    end
endmodule
