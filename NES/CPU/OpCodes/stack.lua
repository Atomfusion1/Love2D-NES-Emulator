local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
PHA - Push Accumulator
Pushes a copy of the accumulator on to the stack.
PHA< PHP< PLA< PLP
]]--

local opcodes = {
    -- Push Accumulator To Stack
    [0x48] = {
        opcode = "PHA",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 3
            local pcCounts = 1
            addressMode.WriteToStack(cpuMemory.A)
            if addressMode.debug.trace then addressMode.OpcodePrint("PHA","PHA","0x48", 0, 0, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Push Processor Status To Stack
    [0x08] = {
        opcode = "PHP",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 3
            local pcCounts = 1
            local value = bit.bor(cpuMemory.statusRegister,0x30)
            addressMode.WriteToStack(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("PHP","PHP","0x08", value, 0, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Pull Accumulator From Stack
    [0x68] = {
        opcode = "PLA",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 1
            local value = addressMode.ReadFromStack()
            cpuMemory.CheckZeroAndNegativeFlag(value)
            cpuMemory.A = value
            if addressMode.debug.trace then addressMode.OpcodePrint("PLA","PLA","0x68", value, 0, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Pull Processor Status
    [0x28] = {
        opcode = "PLP",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 1
            local value = addressMode.ReadFromStack()
            value = bit.bor(value, 0x20)
            value = bit.band(value, 0xEF)
            cpuMemory.statusRegister = value
            if addressMode.debug.trace then addressMode.OpcodePrint("PLP","PLP","0x28", cpuMemory.statusRegister, 0, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes