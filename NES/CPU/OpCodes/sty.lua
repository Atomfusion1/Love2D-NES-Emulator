local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
STY - Store Accumulator
M = A

Stores the contents of the accumulator into memory.
]]


local opcodes = {
    -- ZeroPage
    [0x84] = {
        opcode = "STY",
        pcCounts = 2,
        func = function ()
            local cycles = 3
            local PCCounter = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = cpuMemory.Y
            bus.CPUWrite(address, value)
            if addressMode.debug.trace then addressMode.OpcodePrint("STY","STY","0x84", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- ZeroPage_X
    [0x94] = {
        opcode = "STY",
        pcCounts = 2,
        func = function ()
            local cycles = 4
            local PCCounter = 2
            local address = addressMode.GetZeroPage_XAddressMode()
            local value = cpuMemory.Y
            bus.CPUWrite(address, value)
            if addressMode.debug.trace then addressMode.OpcodePrint("STY","STY","0x94", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- Absolute
    [0x8C] = {
        opcode = "STY",
        pcCounts = 3,
        func = function ()
            local cycles = 4
            local PCCounter = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = cpuMemory.Y
            bus.CPUWrite(address, value)
            if addressMode.debug.trace then addressMode.OpcodePrint("STY","STY","0x8C", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
}

return opcodes