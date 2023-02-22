local notes = {}

local A4 = 440.00
local i = 1
for n = 12, 131 do -- From C0 to B9
  table.insert(notes, A4 * 2^((n-69)/12))
  print(i,notes[i])
  i = i + 1
end 

function love.load1()
    local sampleRate = 44100
    local duration = 20
    local amplitude = 0.2
    local sin = math.sin
    local floor = math.floor

    local samplePoints = sampleRate * duration
    local soundData = love.sound.newSoundData(samplePoints, sampleRate, 16, 1)

    -- sin Waves
    for i = 0, samplePoints - 1 do
        local time = i / sampleRate
        local value = amplitude * math.sin(2 * math.pi * notes[58] * time)
        soundData:setSample(i, value)
    end
    -- square wave
    for i = 0, samplePoints - 1 do
        local time = i / sampleRate
        local value = (floor(time * notes[58] * 2) % 2 == 0) and amplitude or -amplitude
        soundData:setSample(i, value*.1)
    end
    Pulsesources1 = {}
    for i, note in ipairs(notes) do
        Pulsesources1[i] = love.audio.newSource(soundData)
        Pulsesources1[i]:setPitch(note / notes[58])
        Pulsesources1[i]:setLooping(true)
    end
    Pulsesources2 = {}
    for i, note in ipairs(notes) do
        Pulsesources2[i] = love.audio.newSource(soundData)
        Pulsesources2[i]:setPitch(note / notes[58])
        Pulsesources2[i]:setLooping(true)
    end

    -- Triangle Wave
    for i = 0, samplePoints - 1 do
        local time = i / sampleRate
        local value = ((time * notes[58]) % 1) * 4 - 2
        if value > 1 then
            value = 2 - value
        elseif value < -1 then
            value = -2 - value
        end
        value = value * amplitude
        soundData:setSample(i, value)
    end

    Trianglesource = {}
    for i, note in ipairs(notes) do
        Trianglesource[i] = love.audio.newSource(soundData)
        Trianglesource[i]:setPitch(note / notes[58])
        Trianglesource[i]:setLooping(true)
    end

end
  P1 = 58
  P2 = 57
  T1 = 25

-- table of notes with MIDI note numbers and durations
local notes1 = {
    { note = 60, duration = 0.5 }, -- C4 - hack the start of the song on play 
    { note = 60, duration = 0.5 }, -- C4
    { note = 60, duration = 0.5 }, -- C4
    { note = 67, duration = 0.5 }, -- G4
    { note = 67, duration = 0.5 }, -- G4
    { note = 69, duration = 0.5 }, -- A4
    { note = 69, duration = 0.5 }, -- A4
    { note = 67, duration = 1 },   -- G4
    { note = 65, duration = 0.5 }, -- F4
    { note = 65, duration = 0.5 }, -- F4
    { note = 64, duration = 0.5 }, -- E4
    { note = 64, duration = 0.5 }, -- E4
    { note = 62, duration = 0.5 }, -- D4
    { note = 62, duration = 0.5 }, -- D4
    { note = 60, duration = 1 },   -- C4
    { note = 67, duration = 0.5 }, -- G4
    { note = 67, duration = 0.5 }, -- G4
    { note = 65, duration = 0.5 }, -- F4
    { note = 65, duration = 0.5 }, -- F4
    { note = 64, duration = 0.5 }, -- E4
    { note = 64, duration = 0.5 }, -- E4
    { note = 62, duration = 1 },   -- D4
    { note = 67, duration = 0.5 }, -- G4
    { note = 67, duration = 0.5 }, -- G4
    { note = 65, duration = 0.5 }, -- F4
    { note = 65, duration = 0.5 }, -- F4
    { note = 64, duration = 0.5 }, -- E4
    { note = 64, duration = 0.5 }, -- E4
    { note = 62, duration = 1 },   -- D4
    { note = 60, duration = 0.5 }, -- C4
    { note = 60, duration = 0.5 }, -- C4
    { note = 67, duration = 0.5 }, -- G4
    { note = 67, duration = 0.5 }, -- G4
    { note = 69, duration = 0.5 }, -- A4
    { note = 69, duration = 0.5 }, -- A4
    { note = 67, duration = 1 },   -- G4
    { note = 65, duration = 0.5 }, -- F4
    { note = 65, duration = 0.5 }, -- F4
}

startTime = 0
timer = 0
locationOfNote = 1
function love.update1(dt)
    timer = timer -dt    
    if timer <= 0 then
        Pulsesources1[notes1[locationOfNote].note]:stop()
        Pulsesources2[notes1[locationOfNote].note+5]:stop()
        Trianglesource[notes1[locationOfNote].note-24]:stop()
        locationOfNote = 1 + locationOfNote
        love.timer.sleep(.05)
        if locationOfNote > #notes1 then
            locationOfNote = 1
        end
        Pulsesources1[notes1[locationOfNote].note]:play()
        Pulsesources2[notes1[locationOfNote].note+5]:play()
        Trianglesource[notes1[locationOfNote].note-24]:play()
        timer = notes1[locationOfNote].duration
    end

  
    function love.keypressed(key)
        if key == 'u' then
            Pulsesources1[P1]:stop()
            P1 = P1 + 1
        elseif key == 'y' then
            Pulsesources1[P1]:stop()
            P1 = P1 - 1
        elseif key == 'i' then
            if Pulsesources1[P1]:isPlaying() then Pulsesources1[P1]:stop() else Pulsesources1[P1]:play() end
        end
        if key == 'j' then
            Pulsesources2[P2]:stop()
            P2 = P2 + 1
        elseif key == 'h' then
            Pulsesources2[P2]:stop()
            P2 = P2 - 1
        elseif key == 'k' then
            if Pulsesources2[P2]:isPlaying() then Pulsesources2[P2]:stop() else Pulsesources2[P2]:play() end
        end
        if key == 'm' then
            Trianglesource[T1]:stop()
            T1 = T1 + 1
        elseif key == 'n' then
            Trianglesource[T1]:stop()
            T1 = T1 - 1
        elseif key == ',' then
            if Trianglesource[T1]:isPlaying() then Trianglesource[T1]:stop() else Trianglesource[T1]:play() end
        end
    end
end
