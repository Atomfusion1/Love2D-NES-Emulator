local ppuBus = require("NES.PPU.ppuBus")
local loopy = require("NES.PPU.loopy")
local OAM = require("NES.PPU.ppuOAM")
local ppuIO = {}


-- PPU IO Control
ppuIO.bit_masks = {
    bit0 = 1,
    bit1 = 2,
    bit2 = 4,
    bit3 = 8,
    bit4 = 16,
    bit5 = 32,
    bit6 = 64,
    bit7 = 128,
  }
    -- Create a new value variable and set its metatable
ppuIO.CTRL    = 0x80
ppuIO.MASKS   = 0x00
ppuIO.STATUS  = 0x00
ppuIO.OAMADDR = 0x0000
ppuIO.OAMDATA = 0x00
ppuIO.SCROLL  = 0x00
ppuIO.ADDR    = 0x00
ppuIO.DATA    = 0x00
ppuIO.OAMDMA  = 0x00

local bit = require("bit")
-- Pass Value and #Bit to get if high / low 
function ppuIO.IsBitSet(value, bitPosition)
    -- Shift 1 to the left by the bit position, and AND it with the value
    -- to get the value of that bit. If the result is non-zero, the bit is set.
    return bit.band(value, bit.lshift(1, bitPosition)) ~= 0
end
-- set bit value value #bit true/false
function ppuIO.SetBit(value, bitPosition, isSet)
    -- Shift 1 to the left by the bit position to get a mask with a 1 in that bit.
    local mask = bit.lshift(1, bitPosition)
    if isSet then
        -- OR the value with the mask to set the bit.
        value = bit.bor(value, mask)
    else
        -- AND the value with the inverse of the mask to clear the bit.
        value = bit.band(value, bit.bnot(mask))
    end
    return value
end

local debugPPU = false
local ppuaddrLatch = 0
local scrollLatch = 0
local ppu_data_buffer = 0x00
local trimaddr = 0x00
ppuIO.NameTableAddress = 0x00
ppuIO.BackgroundTable = 0x00
ppuIO.SpriteTable = 0x00

function ppuIO.CPURead(addr)
    if addr == 0x0000 then  -- control
        if debugPPU then print("Read PPU 2000 and data ", "nil") end
        return 0x00
    elseif addr == 0x0001 then -- mask 
        if debugPPU then print("Read PPU 2001 and data ", "nil") end
        return 0x00
    elseif addr == 0x0002 then -- status 
        -- Reading Status Resets Latches and Only top 3 bits are used bottom are noise
        local data = bit.bor(bit.band(ppuIO.STATUS,0xE0),bit.band(ppu_data_buffer,0x1F))
        ppuaddrLatch = 0
        scrollLatch = 0
        if debugPPU then print("Read PPU 2002 and data ", data) end
        return data
    elseif addr == 0x0003 then -- oam address
        local data = 0x00
        if debugPPU then print("Read PPU 2003 and data ", data) end
        return data
    elseif addr == 0x0004 then -- oam data 
        local data = 0x00
        if debugPPU then print("Read PPU 2004 and data ", data) end
        return data
    elseif addr == 0x0005 then -- scroll 
        local data = 0x00
        if debugPPU then print("Read PPU 2005 and data ", data) end
        return data
    elseif addr == 0x0006 then -- ppu address
        local data = 0x00
        if debugPPU then print("Read PPU 2006 and data ", data) end
        return data
    elseif addr == 0x0007 then -- ppu data 
        -- Delay Output from PPU one Read so store it then give it the next read
        local data = ppu_data_buffer
        ppu_data_buffer = ppuBus.PPURead(loopy.register_vram_addr)
        -- but if its palette data send right away 
        -- update Pointer location 
        if loopy.register_vram_addr >= 0x3F00 then data = ppu_data_buffer end
        if ppuIO.IsBitSet(ppuIO.CTRL, 2) then
            loopy.register_vram_addr = loopy.register_vram_addr + 32
        else
            loopy.register_vram_addr = loopy.register_vram_addr + 1
        end
        if debugPPU then print("Read PPU 2007 and data ", data, ppu_data_buffer, loopy.register_vram_addr, ppuIO.IsBitSet(ppuIO.CTRL, 2)) end
        
        return data
    end
    print("PPU Read Error")
    return 0x00
end

function ppuIO.CPUWrite(addr, data)
    if addr == 0x0000 then  -- control
        ppuIO.CTRL = data
        ppuIO.NameTableAddress = bit.band(data, 0x03)
        ppuIO.BackgroundTable = bit.band(data, 0x10) ~= 0 and 1 or 0
        ppuIO.SpriteTable = bit.band(data, 0x08) ~= 0 and 1 or 0
        loopy.nametable_x = ppuIO.IsBitSet(ppuIO.CTRL, 0) and 1 or 0
        loopy.nametable_y = ppuIO.IsBitSet(ppuIO.CTRL, 1) and 1 or 0
        if debugPPU then print(string.format("Write PPU 2000 %x %x", addr, data)) end
    elseif addr == 0x0001 then -- mask
        ppuIO.MASKS = data
        if debugPPU then print(string.format("Write PPU 2001 %x %x", addr, data)) end
    elseif addr == 0x0002 then -- status 
        scrollLatch = 0 -- reset address latch 
        ppuaddrLatch = 0 -- reset ppu addr latch 
        if debugPPU then print(string.format("Write PPU 2002 %x %x", addr, data)) end
        return nil
    elseif addr == 0x0003 then -- oam address
        ppuIO.OAMADDR = data
        if debugPPU then print(string.format("Write PPU 2003 %x %x", addr, data)) end
    elseif addr == 0x0004 then -- oam data 
        ppuIO.OAMDATA = data
        if debugPPU then print(string.format("Write PPU 2004 %x %x", addr, data)) end
    elseif addr == 0x0005 then -- scroll 
        if scrollLatch == 0 then
            ppuIO.SCROLL = data * 256
            loopy.fine_x = bit.band(data, 0x07)
            loopy.course_x = bit.rshift(data, 3)
            scrollLatch = 1
        else
            ppuIO.SCROLL = data + ppuIO.SCROLL
            loopy.fine_y = bit.band(data, 0x07)
            loopy.course_y = bit.rshift(data, 3)
            scrollLatch = 0
        end
        if debugPPU then print(string.format("Write PPU 2005 %x %x, %x, %x", addr, data, loopy.course_x, loopy.course_y)) end
    elseif addr == 0x0006 then -- ppu address
        if ppuaddrLatch == 0 then
            -- shift just the top 
            trimaddr = bit.bor(bit.lshift(bit.band(data,0x3F),8), bit.band(trimaddr, 0x00FF))
            ppuaddrLatch = 1
            if debugPPU then print(string.format("Write PPU 2006 latch %x trimaddr %x data %x pointer:%04x", ppuaddrLatch, trimaddr, data, loopy.register_vram_addr)) end 
        else
            -- shift the lower 
            trimaddr = bit.bor(bit.band(trimaddr,0xFF00), data)
            loopy.register_tram_addr = trimaddr -- set oam Pointer 
            loopy.register_vram_addr = loopy.register_tram_addr
            ppuaddrLatch = 0
            if debugPPU then print(string.format("Write PPU 2006 latch %x trimaddr %x data %x pointer:%04x", ppuaddrLatch, trimaddr, data, loopy.register_vram_addr)) end 
        end
        --print(string.format("PPU %x %x", addr, data))
    elseif addr == 0x0007 then -- ppu data 
        ppuBus.PPUWrite(loopy.register_vram_addr, data)
        if ppuIO.IsBitSet(ppuIO.CTRL, 2) then
            loopy.register_vram_addr = loopy.register_vram_addr + 32
        else
            loopy.register_vram_addr = loopy.register_vram_addr + 1
        end
        if debugPPU then print(string.format("Write PPU 2007 %x, %x, %x, %s", addr, data, loopy.register_vram_addr ,tostring(ppuIO.IsBitSet(ppuIO.CTRL, 2)))) end
    elseif addr == 0x4014 then
        OAM.RefreshOAM(data, ppuIO.OAMADDR)
    end
    return
end


-- Return the PPU control registers table
return ppuIO

