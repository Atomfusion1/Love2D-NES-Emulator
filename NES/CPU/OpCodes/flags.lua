local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

local opcodes = {
    -- Clear Carry Flag
    [0x18] = {
        opcode = "CLC",
        pcCounts = 1,
        func =  function ()
            local cycles = 2
            local PCCounter = 1
            cpuMemory.WriteFlag("carry",0)
            if addressMode.debug.trace then addressMode.OpcodePrint("Flags","CLC","0x18", 0, 0, 0, 0) end
            return cycles, PCCounter
        end,
    },
    -- Clear Decimal
    [0xD8] = {
        opcode = "CLD",
        pcCounts = 1,
        func = function ()
            local cycles = 2
            local PCCounter = 1
            cpuMemory.WriteFlag("decimal",0)
            if addressMode.debug.trace then addressMode.OpcodePrint("Flags","CLD","0xD8", 0, 0, 0, 0) end
            return cycles, PCCounter
        end,
    },
    -- Clear Interrupt disabled 
    [0x58] = {
        opcode = "CLI",
        pcCounts = 1,
        func = function ()
            local cycles = 2
            local PCCounter = 1
            cpuMemory.WriteFlag("interrupt",0)
            if addressMode.debug.trace then addressMode.OpcodePrint("Flags","CLI","0x58", 0, 0, 0, 0) end
            return cycles, PCCounter
        end,
    },
    -- clear Overflow Flag
    [0xB8] = {
        opcode = "CLV",
        pcCounts = 1,
        func = function ()
            local cycles = 2
            local PCCounter = 1
            cpuMemory.WriteFlag("overflow",0)
            if addressMode.debug.trace then addressMode.OpcodePrint("Flags","CLV","0xB8", 0, 0, 0, 0) end
            return cycles, PCCounter
        end,
    },
    -- Set Carry Flag
    [0x38] = {
        opcode = "SEC",
        pcCounts = 1,
        func = function ()
            local cycles = 2
            local PCCounter = 1
            cpuMemory.WriteFlag("carry",1)
            if addressMode.debug.trace then addressMode.OpcodePrint("Flags","SEC","0x38", 0, 1, 0, 0) end
            return cycles, PCCounter
        end,
    },
    -- Set Decimal flag
    [0xF8] = {
        opcode = "SED",
        pcCounts = 1,
        func = function ()
            local cycles = 2
            local PCCounter = 1
            cpuMemory.WriteFlag("decimal",1)
            if addressMode.debug.trace then addressMode.OpcodePrint("Flags","SED","0xF8", 0, 1, 0, 0) end
            return cycles, PCCounter
        end,
    },
    -- Set Interrupt flag
    [0x78] = {
        opcode = "SEI",
        pcCounts = 1,
        func = function ()
            local cycles = 2
            local PCCounter = 1
            cpuMemory.WriteFlag("interrupt",1)
            if addressMode.debug.trace then addressMode.OpcodePrint("Flags","SEI","0x78", 0, 1, 0, 0) end
            return cycles, PCCounter
        end,
    },
}

return opcodes