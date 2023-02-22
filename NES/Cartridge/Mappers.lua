local mappers = {
    [000] = {
        mapper = require("NES.Cartridge.Maps.Map_000")
    },
    [001] = {
        mapper = require("NES.Cartridge.Maps.Map_001")
    },
    [002] = {
        mapper = require("NES.Cartridge.Maps.Map_002")
    },
    [003] = {
        mapper = require("NES.Cartridge.Maps.Map_003")
    },
}

return mappers
