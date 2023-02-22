local cpuMemory          = {}
-- Basic 6502 Registers and Storage
cpuMemory                = {}
cpuMemory.A              = 0x00
cpuMemory.X              = 0x00
cpuMemory.Y              = 0x00
cpuMemory.programCounter = 0x0000
cpuMemory.stackPointer   = 0xFF
cpuMemory.statusRegister = 0x24
cpuMemory.flag           = {
    ["negative"]  = 0x80, -- 7 = negative flag
    ["overflow"]  = 0x40, -- 6 = overflow flag
    ["none"]      = 0x20, -- 5 = always high Not Used
    ["breakflow"] = 0x10, -- 4 = breakflow flag
    ["decimal"]   = 0x08, -- 5 = decimal flag
    ["interrupt"] = 0x04, -- 3 = interrupt flag
    ["zero"]      = 0x02, -- 2 = zero flag
    ["carry"]     = 0x01, -- 1 = carry flag
}
--additional information I Wanted
cpuMemory.info           = {}
cpuMemory.info.cycle     = 0
cpuMemory.info.execute   = 0
cpuMemory.TriggerNMI     = false

-- UPDATE BYTES
-- update 16 bit value check for rollover
function cpuMemory.Update16Bit(value, change)
    value = bit.band((value + change), 0xFFFF)
    return value
end

-- Update 8 bit values check for rollover
function cpuMemory.Update8Bit(value, change)
    value = bit.band((value + change), 0xFF)
    return value
end

-- HANDLE FLAGS
-- Read Flag
function cpuMemory.ReadFlag(flag)
    local value = cpuMemory.flag[flag]
    return (bit.band(cpuMemory.statusRegister, value) == value) and 1 or 0
end

-- Write to Flag
function cpuMemory.WriteFlag(flag, value)
    local flagValue = cpuMemory.flag[flag]
    if value == 1 then
        cpuMemory.statusRegister = bit.bor(cpuMemory.statusRegister, flagValue)
    else
        cpuMemory.statusRegister = bit.band(cpuMemory.statusRegister, bit.bnot(flagValue))
    end
end

-- Check Zero Flag
function cpuMemory.CheckZeroFlag(value)
    local result = (bit.band(value, 0xFF) == 0) and 1 or 0
    cpuMemory.WriteFlag("zero", result)
end

-- Check Negative Flag
function cpuMemory.CheckNegativeFlag(value)
    local result = (bit.band(value, 0x80) ~= 0) and 1 or 0
    cpuMemory.WriteFlag("negative", result)
end

-- Check Zero and Negative Flag
function cpuMemory.CheckZeroAndNegativeFlag(value)
    local resultZero = (bit.band(value, 0xFF) == 0) and 1 or 0
    cpuMemory.WriteFlag("zero", resultZero)
    local resultNegative = (bit.band(value, 0x80) ~= 0) and 1 or 0
    cpuMemory.WriteFlag("negative", resultNegative)
end

return cpuMemory
