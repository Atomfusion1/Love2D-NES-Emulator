local cart       = require("NES.Cartridge.Cartridge")
local mapper     = require("NES.Cartridge.Mappers")
local memory     = require("NES.CPU.cpuram")
local controller = require("NES.Controller.controller")
local ppuIO      = require("NES.PPU.ppuIO")
local apu        = require("NES.Audio.apu")

local bus        = {}
local cartMapper = mapper[cart.mapper].mapper
local rshift, band, bor = bit.rshift, bit.band, bit.bor
local CPURAM = memory.cpuRAM
local CPURead = cartMapper.CPURead
function bus.CPURead(addr)
-- Read Cartridge Prog Memory ROM
    if addr >= 0x8000 then
        return CPURead(addr)
-- Read Internal CPU RAM
    elseif addr < 0x2000 then
        local cpuRAMIndex    = band(addr, 0x07ff)
        return CPURAM[cpuRAMIndex]
-- Read PPU Registers Directly 
    elseif addr >= 0x2000 and addr <= 0x3FFF then
        addr = band(addr, 0x0007)
        return ppuIO.CPURead(addr)
-- Other CPU Reads (Controller Sound etc)
    elseif addr >= 0x4000 and addr <= 0x401f then
        if addr == 0x4016 or addr == 0x4017 then
            return controller.ReadState(addr)
        end
    else
        print("CPU Error Read not Mapped", addr)
        return 0x18
    end
end

local CPUWrite = ppuIO.CPUWrite
function bus.CPUWrite(addr, data)

-- Write to Internal RAM
    if addr <= 0x1FFF then
        CPURAM[band(addr, 0x07ff)] = data
        return
-- Write to PPU Registers Directly 
    elseif addr >= 0x2000 and addr <= 0x3FFF then
        addr = band(addr, 0x0007)
        CPUWrite(addr, data)
-- Write to Controllers or Other (Sound)
    elseif addr >= 0x4000 and addr <= 0x401f then
        -- Controllers
        if addr == 0x4016 or addr == 0x4017 then
            controller.GetState(addr)
            return
        end
        if addr == 0x4014 then
            ppuIO.CPUWrite(addr, data)
        end
        if addr >= 0x4000 and addr <= 0x400F then
            if UseSound then apu.APUSound(addr, data) end
        end

        if addr == 0x4015 then
            apu.StatusHandle(addr,data)
        end
    elseif addr >= 0x8000 and addr <= 0xFFFF then
        cartMapper.CPUWrite(addr, data)
    else
        print("CPU Error Write Memory", addr, data)
    end
end

return bus

