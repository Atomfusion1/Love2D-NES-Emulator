local cpuMemory   = require("NES.CPU.cpumemory")
local bus         = require("NES.BUS.bus")

local addressMode = {}
addressMode.debug = {}
addressMode.debug.trace = true
addressMode.debug.print = false
addressMode.debug.traceSize = 30
-- Addressing MODES
-- Get Value from Address
function addressMode.GetValueFromAddress(value)
    return bus.CPURead(value)
end
-- Get Value from next slot in Memory
function addressMode.GetImmediateMode()
    return bus.CPURead(cpuMemory.Update16Bit(cpuMemory.programCounter, 1))
end
-- Get Zero Page Address 
function addressMode.GetZeroPageAddressMode()
    return bus.CPURead(cpuMemory.Update16Bit(cpuMemory.programCounter, 1))
end
-- Get ZeroPage_X Address
function addressMode.GetZeroPage_XAddressMode()
    local address   = addressMode.GetZeroPageAddressMode()
    return cpuMemory.Update8Bit(address, cpuMemory.X)
end
-- Get ZeroPage_Y Address
function addressMode.GetZeroPage_YAddressMode()
    local address   = addressMode.GetZeroPageAddressMode()
    return cpuMemory.Update8Bit(address, cpuMemory.Y)
end
-- Get Absolute Address
function addressMode.GetAbsoluteAddressMode()
    local lowbyte   = bus.CPURead(cpuMemory.Update16Bit(cpuMemory.programCounter, 1))
    local highbyte  = bus.CPURead(cpuMemory.Update16Bit(cpuMemory.programCounter, 2))
    return ((highbyte * 0x100) + lowbyte)
end
-- Get Absolute_X Address
function addressMode.GetAbsolute_XAddressMode()
    local absolute  = addressMode.GetAbsoluteAddressMode()
    return cpuMemory.Update16Bit(absolute, cpuMemory.X)
end
-- Get Absolute_Y Address
function addressMode.GetAbsolute_YAddressMode()
    local absolute  = addressMode.GetAbsoluteAddressMode()
    return cpuMemory.Update16Bit(absolute, cpuMemory.Y)
end
-- Get Indexed_Indirect_X
function addressMode.GetIndexed_Indirect_XMode()
    local address8Bit   = cpuMemory.Update8Bit(bus.CPURead(cpuMemory.Update16Bit(cpuMemory.programCounter, 1)), cpuMemory.X)
    local LowByte16     = bus.CPURead(address8Bit)
    local HighByte16    = bus.CPURead(cpuMemory.Update8Bit(address8Bit,1))
    return  ((HighByte16 * 0x100) + LowByte16)
end
-- Get Indirect_Indexed_Y
function addressMode.GetIndirect_Indexed_YMode()
    local address8Bit   = addressMode.GetZeroPageAddressMode()
    local LowByte16     = bus.CPURead(address8Bit)
    local HighByte16    = bus.CPURead(cpuMemory.Update8Bit(address8Bit,1))
    local Address16bit  = ((HighByte16 * 0x100) + LowByte16)
    local Address16AddY = cpuMemory.Update16Bit(Address16bit,cpuMemory.Y)
    return Address16AddY
end

-- Stack Control
function addressMode.WriteToStack(value)
    bus.CPUWrite(0x100 + cpuMemory.stackPointer , value)
    cpuMemory.stackPointer    = cpuMemory.Update8Bit(cpuMemory.stackPointer, -1)
end

function addressMode.ReadFromStack()
    cpuMemory.stackPointer    = cpuMemory.Update8Bit(cpuMemory.stackPointer, 1)
    local value               = bus.CPURead(0x01*256 + cpuMemory.stackPointer)
    return value
end

-- Location, OpcodeValue, OpcodeName, Address, Value1, Value2, Value3.
function addressMode.OpcodePrint(opcodeLocation, opcodeValue, opcodeName, address, value1, value2, value3)
    -- add the current opcode to the beginning of the array
    table.insert(last10Opcodes, 1, string.format("PC:%04x Loc:%s opcode:%s opcode:%s Address:%x Value1:%x Value2:%x Value3:%x",
    cpuMemory.programCounter, opcodeLocation, opcodeValue, opcodeName, address, value1, value2, value3))
    
    -- remove any elements beyond the first 10
    if #last10Opcodes > addressMode.debug.traceSize then
        table.remove(last10Opcodes, #last10Opcodes)
    end
    
    -- print the current opcode to the console
    if addressMode.debug.print then print(last10Opcodes[1]) end
end

return addressMode