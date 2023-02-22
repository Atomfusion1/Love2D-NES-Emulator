local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[

]]--

-- Opcode function 
local function OpcodeFunction(value)
    
    cpuMemory.CheckZeroAndNegativeFlag(value)
    return value
end

local opcodes = {
    -- Immediate Mode
    [0x00] = {
        opcode = "TAG",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 2
            local address = addressMode.GetImmediateMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("TAG","TAG","0x00", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page Mode
    [0x07] = {
        opcode = "TAG",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 3
            local pcCounts = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("TAG","TAG","0x07", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page X Mode
    [0x01] = {
        opcode = "TAG",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 2
            local address = addressMode.GetZeroPage_XAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("TAG","TAG","0x01", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute Mode
    [0x02] = {
        opcode = "TAG",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("TAG","TAG","0x02", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute X Mode
    [0x03] = {
        opcode = "TAG",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsolute_XAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("TAG","TAG","0x03", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute,Y Mode
    [0x04] = {
        opcode = "TAG",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsolute_YAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("TAG","TAG","0x04", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Indirect X Mode
    [0x05] = {
        opcode = "TAG",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 2
            local address = addressMode.GetIndexed_Indirect_XMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("TAG","TAG","0x05", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Indirect Y Mode
    [0x06] = {
        opcode = "TAG",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 5
            local pcCounts = 2
            local address = addressMode.GetIndirect_Indexed_YMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("TAG","TAG","0x06", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes