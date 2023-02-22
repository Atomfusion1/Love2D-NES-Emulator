local cart       = require("NES.Cartridge.Cartridge")
local mapper     = require("NES.Cartridge.Mappers")
local nameTable  = require("NES.PPU.ppunametable")

local ppuBus = {}


-- PPU Own Bus .. NOT FOR 2000-2007 Those are Mapped on the CPU to stored in internal registers location in PPU 
function ppuBus.PPURead(addr)
    -- Mirrors 0x0 - 0x3FFF
        addr = bit.band(addr, 0x3FFF)
        
        local cartMapper = mapper[cart.mapper].mapper
    -- Pattern Tables CHR ROM
        if addr >= 0x0000 and addr <= 0x1FFF then
            local value = cartMapper.PPURead(addr)
            return value
    -- Access internal NameTable Memory VRAM
        elseif addr >= 0x2000 and addr <= 0x3EFF then
                return nameTable.NameTableMirrorRead(addr)
    -- Palette Memory Palette 
        elseif addr >= 0x3F00 and addr <= 0x3FFF then
            addr = bit.band(addr,0x001F)
            if addr == 0x0010 then addr = 0x0000 end
            if addr == 0x0014 then addr = 0x0004 end
            if addr == 0x0018 then addr = 0x0008 end
            if addr == 0x001C then addr = 0x000C end
            return nameTable.tblPalette[addr]
        else
            print("PPU Error Read Memory", addr)
        end
    end
    
    function ppuBus.PPUWrite(addr, data)
    -- Mirrors 0x0 - 0x3FFF
        addr = bit.band(addr, 0x3FFF)
        local cartMapper = mapper[cart.mapper].mapper
    -- Pattern Tables CHR ROM
        if addr >= 0x0000 and addr <= 0x1FFF then
            cartMapper.PPUWrite(addr,data)
            return data
    -- Access internal NameTable Memory VRAM
        elseif addr >= 0x2000 and addr <= 0x3EFF then
                return nameTable.NameTableMirrorWrite(addr, data)
    -- Palette Memory Palette 
        elseif addr >= 0x3F00 and addr <= 0x3FFF then
            addr = bit.band(addr,0x001F)
            if addr == 0x0010 then addr = 0x0000 end
            if addr == 0x0014 then addr = 0x0004 end
            if addr == 0x0018 then addr = 0x0008 end
            if addr == 0x001C then addr = 0x000C end
            nameTable.tblPalette[addr] = data
            return
        else
            print("PPU Error Write Memory", addr, data)
        end
    end


return ppuBus