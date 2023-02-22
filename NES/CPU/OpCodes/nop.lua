local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
NOP - No Operation
The NOP instruction causes no changes to the processor other than the normal incrementing of the program counter to the next instruction.
]]--


local opcodes = {
    -- Implied Mode
    [0xEA] = {
        opcode = "NOP",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 1
            if addressMode.debug.trace then addressMode.OpcodePrint("NOP","NOP","0xEA", 0, 0, 0, 0) end
            return cycleCounts, pcCounts
        end
    },    
}


return opcodes