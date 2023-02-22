local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
LDA - Load Accumulator
A,Z,N = M

Loads a byte of memory into the accumulator setting the zero and negative flags as appropriate.
]]


local opcodes = {
    -- Immediate Mode 12500
    [0xA9] = {
        opcode = "LDA",
        pcCounts = 2,
        func = function ()
            local cycleCosts = 2
            local pcSteps = 2
            local ImmediateValue = addressMode.GetImmediateMode()
            cpuMemory.CheckZeroAndNegativeFlag(ImmediateValue)
            cpuMemory.A = ImmediateValue
            if addressMode.debug.trace then addressMode.OpcodePrint("LDA","LDA","0xA9", ImmediateValue, 0, 0, 0) end
            return cycleCosts, pcSteps
        end
    },
    -- ZeroPage
    [0xA5] = {
        opcode = "LDA",
        pcCounts = 2,
        func = function ()
            local cycles = 3
            local PCCounter = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = bus.CPURead(address)
            cpuMemory.CheckZeroAndNegativeFlag(value)
            cpuMemory.A = value
            if addressMode.debug.trace then addressMode.OpcodePrint("LDA","LDA","0xA5", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- ZeroPage_X
    [0xB5] = {
        opcode = "LDA",
        pcCounts = 2,
        func = function ()
            local cycles = 4
            local PCCounter = 2
            local address = addressMode.GetZeroPage_XAddressMode()
            local value = bus.CPURead(address)
            cpuMemory.CheckZeroAndNegativeFlag(value)
            cpuMemory.A = value
            if addressMode.debug.trace then addressMode.OpcodePrint("LDA","LDA","0xB5", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- Absolute
    [0xAD] = {
        opcode = "LDA",
        pcCounts = 3,
        func = function ()
            local cycles = 4
            local PCCounter = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = bus.CPURead(address)
            cpuMemory.CheckZeroAndNegativeFlag(value)
            cpuMemory.A = value
            if addressMode.debug.trace then addressMode.OpcodePrint("LDA","LDA","0xAD", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- Absolute_X
    [0xBD] = {
        opcode = "LDA",
        pcCounts = 3,
        func = function ()
            local cycles = 4
            local PCCounter = 3
            local address = addressMode.GetAbsolute_XAddressMode()
            local value = bus.CPURead(address)
            cpuMemory.CheckZeroAndNegativeFlag(value)
            cpuMemory.A = value
            if addressMode.debug.trace then addressMode.OpcodePrint("LDA","LDA","0xBD", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- Absolute_Y
    [0xB9] = {
        opcode = "LDA",
        pcCounts = 3,
        func = function ()
            local cycles = 4
            local PCCounter = 3
            local address = addressMode.GetAbsolute_YAddressMode()
            local value = bus.CPURead(address)
            cpuMemory.CheckZeroAndNegativeFlag(value)
            cpuMemory.A = value
            if addressMode.debug.trace then addressMode.OpcodePrint("LDA","LDA","0xB9", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- Indexed Indirect X
    [0xA1] = {
        opcode = "LDA",
        pcCounts = 2,
        func = function ()
            local cycles = 6
            local PCCounter = 2
            local address = addressMode.GetIndexed_Indirect_XMode()
            local value = bus.CPURead(address)
            cpuMemory.CheckZeroAndNegativeFlag(value)
            cpuMemory.A = value
            if addressMode.debug.trace then addressMode.OpcodePrint("LDA","LDA","0xA1", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- Indirect Indexed Y
    [0xB1] = {
        opcode = "LDA",
        pcCounts = 2,
        func = function ()
            local cycles = 5
            local PCCounter = 2
            local address = addressMode.GetIndirect_Indexed_YMode()
            local value = bus.CPURead(address)
            cpuMemory.CheckZeroAndNegativeFlag(value)
            cpuMemory.A = value
            if addressMode.debug.trace then addressMode.OpcodePrint("LDA","LDA","0xB1", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
}

return opcodes