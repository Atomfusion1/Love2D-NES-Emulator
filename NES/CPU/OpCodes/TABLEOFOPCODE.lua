--local cpu = require("NES.CPU.cpumemory")

local opcodeTable = {}
-- Default for opcode if unknown (Testing)
opcodeTable[0xEA] = {
    opcode    = "NOP",
    func      = function ()
        local cycleCount    = 2
        local pcSteps       = 1
        return cycleCount, pcSteps
    end
}

-- load files for opcodes 
local flags       = require("NES.CPU.OPCODES.flags")
local branch      = require("NES.CPU.OPCODES.branch")
local stack       = require("NES.CPU.OPCODES.stack")
local transfers   = require("NES.CPU.OPCODES.transfers")
local lda   = require("NES.CPU.OPCODES.lda")
local ldx   = require("NES.CPU.OPCODES.ldx")
local ldy   = require("NES.CPU.OPCODES.ldy")
local adc   = require("NES.CPU.OPCODES.adc")
local eor   = require("NES.CPU.OPCODES.eor")
local sbc   = require("NES.CPU.OPCODES.sbc")
local and1  = require("NES.CPU.OPCODES.and")
local asl   = require("NES.CPU.OPCODES.asl")
local bit   = require("NES.CPU.OPCODES.bit")
local cmp   = require("NES.CPU.OPCODES.cmp")
local cpx   = require("NES.CPU.OPCODES.cpx")
local cpy   = require("NES.CPU.OPCODES.cpy")
local dec   = require("NES.CPU.OPCODES.dec")
local inc   = require("NES.CPU.OPCODES.inc")
local jmp   = require("NES.CPU.OPCODES.jmp")
local jsr   = require("NES.CPU.OPCODES.jsr")
local rts   = require("NES.CPU.OPCODES.rts")
local lsr   = require("NES.CPU.OPCODES.lsr")
local nop   = require("NES.CPU.OPCODES.nop")
local ora   = require("NES.CPU.OPCODES.ora")
local rol   = require("NES.CPU.OPCODES.rol")
local ror   = require("NES.CPU.OPCODES.ror")
local rti   = require("NES.CPU.OPCODES.rti")
local sta   = require("NES.CPU.OPCODES.sta")
local stx   = require("NES.CPU.OPCODES.stx")
local sty   = require("NES.CPU.OPCODES.sty")


-- create opcode table 
for k, v in pairs(flags) do opcodeTable[k]    = v end
for k, v in pairs(branch) do opcodeTable[k]   = v end
for k, v in pairs(stack) do opcodeTable[k]    = v end
for k, v in pairs(transfers) do opcodeTable[k]    = v end
for k, v in pairs(lda) do opcodeTable[k]    = v end
for k, v in pairs(ldx) do opcodeTable[k]    = v end
for k, v in pairs(ldy) do opcodeTable[k]    = v end
for k, v in pairs(adc) do opcodeTable[k]    = v end
for k, v in pairs(eor) do opcodeTable[k]    = v end
for k, v in pairs(sbc) do opcodeTable[k]    = v end
for k, v in pairs(and1) do opcodeTable[k]   = v end
for k, v in pairs(asl) do opcodeTable[k]    = v end
for k, v in pairs(bit) do opcodeTable[k]    = v end
for k, v in pairs(cmp) do opcodeTable[k]    = v end
for k, v in pairs(cpx) do opcodeTable[k]    = v end
for k, v in pairs(cpy) do opcodeTable[k]    = v end
for k, v in pairs(jmp) do opcodeTable[k]    = v end
for k, v in pairs(dec) do opcodeTable[k]    = v end
for k, v in pairs(inc) do opcodeTable[k]    = v end
for k, v in pairs(jsr) do opcodeTable[k]    = v end
for k, v in pairs(rts) do opcodeTable[k]    = v end
for k, v in pairs(lsr) do opcodeTable[k]    = v end
for k, v in pairs(nop) do opcodeTable[k]    = v end
for k, v in pairs(ora) do opcodeTable[k]    = v end
for k, v in pairs(rol) do opcodeTable[k]    = v end
for k, v in pairs(ror) do opcodeTable[k]    = v end
for k, v in pairs(rti) do opcodeTable[k]    = v end
for k, v in pairs(sta) do opcodeTable[k]    = v end
for k, v in pairs(stx) do opcodeTable[k]    = v end
for k, v in pairs(sty) do opcodeTable[k]    = v end


return opcodeTable