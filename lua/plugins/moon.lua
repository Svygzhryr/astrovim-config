local quotes = {
  { "The moon remembers", "what the sun forgets." },
  { "Something is watching", "from the dark side of the moon." },
  { "Every window you open", "was once a dream of someone asleep." },
  { "The stars are not distant.", "They are simply waiting." },
  { "Beneath the pale light,", "the old shadows stir." },
  { "The sun only lends its glow.", "The moon pretends it is her own." },
  { "At noon the day has no secrets.", "At midnight it has nothing else." },
  { "Tonight the tides pull", "at things that have no shore." },
  { "A whisper in the moonlight says:", "you were here before." },
  { "The night keeps secrets.", "The dawn keeps receipts." },
  { "Ancient things sleep beneath the sunrise.", "Do not wake them early." },
  { "The moon is just the sun's", "night shift." },
  { "In space no one can hear you", "ask for a sunrise." },
  { "Once upon a midnight dreary,", "the moon was suspiciously cheerful." },
  { "Somewhere a wolf howls.", "Somewhere the sun is still asleep." },
  { "The void stares back.", "It wants its moon returned." },
  { "Dawn is only the night", "changing its mind." },
  { "The moon keeps no diary.", "The tides write everything down." },
  { "Even the sun", "must sleep somewhere." },
  { "Midnight is a door.", "Nobody remembers opening it." },
  { "The owls know", "what the daylight hides." },
  { "Dusk is when the world", "takes off its mask." },
  { "Every sunset is a goodbye", "the sky pretends not to mean." },
  { "The moon has seen your secrets", "and found them boring." },
  { "Stars are just the night's", "unanswered questions." },
  { "At the edge of the dawn,", "something forgets your name." },
  { "The shadows are long tonight.", "They are looking for you." },
  { "The sun rises for everyone.", "The moon, only for the awake." },
  { "A candle is a small sun", "afraid of the dark." },
  { "Somewhere it is always midnight.", "Somewhere it is always breakfast." },
  { "The moon is a lighthouse", "for ships that do not exist." },
  { "Night is the day's", "unlocked diary." },
  { "The sun forgot to set once.", "Nobody talks about that summer." },
  { "In the hour of the wolf,", "the moon counts its sheep." },
  { "Twilight is the sky", "deciding what to be." },
  { "The moon rises slowly", "to avoid questions." },
  { "Every dawn is a rumour", "the night has not confirmed." },
  { "Lunar light is just sunlight", "that took the scenic route." },
  { "Somewhere a clock strikes thirteen.", "The moon pretends not to hear." },
  { "The night sky is the oldest map.", "No one has found the exit." },
  { "The sun draws the day.", "The moon erases it, gently." },
  { "Something moved in the moonlight.", "It was probably nothing." },
  { "The tide is a promise", "the moon keeps badly." },
  { "Under a full moon,", "even the shadows have shadows." },
  { "A new moon is the sky", "holding its breath." },
  { "In the quiet before dawn,", "the stars rehearse their exit." },
  { "The moon is a coin", "tossed to decide the night." },
  { "Even the darkest night", "was once a very long afternoon." },
  { "The sun is out there somewhere,", "doing its best." },
  { "The moon never explains.", "It simply returns." },
}

local function moon_header()
  local synodic = 29.530588853
  local ref = 947182440
  local age = ((os.time() - ref) / 86400) % synodic
  local p = age / synodic
  local angle = 2 * math.pi * p
  local illum = math.floor((1 - math.cos(angle)) / 2 * 100 + 0.5)

  local names = {
    "New Moon",
    "Waxing Crescent",
    "First Quarter",
    "Waxing Gibbous",
    "Full Moon",
    "Waning Gibbous",
    "Last Quarter",
    "Waning Crescent",
  }
  local name = names[(math.floor(p * 8 + 0.5) % 8) + 1]

  local radius = 9.5
  local rows = math.floor(radius)
  local aspect = 2.3
  local fill = "●"
  local dark = "·"
  local waxing = p < 0.5
  local cut = math.cos(angle)
  local lines = {}

  math.randomseed(os.time())
  for _, line in ipairs(quotes[math.random(#quotes)]) do
    lines[#lines + 1] = line
  end
  for _ = 1, 3 do
    lines[#lines + 1] = ""
  end

  for y = -rows, rows do
    local half = math.sqrt(math.max(0, radius ^ 2 - y ^ 2)) * aspect
    local row = {}
    for x = -math.ceil(radius * aspect), math.ceil(radius * aspect) do
      local char = " "
      if math.abs(x) <= half then
        local u = half > 0 and x / half or 0
        local lit
        if waxing then
          lit = u > cut
        else
          lit = u < -cut
        end
        char = lit and fill or dark
      end
      row[#row + 1] = char
    end
    lines[#lines + 1] = table.concat(row)
  end

  for _ = 1, 3 do
    lines[#lines + 1] = ""
  end
  lines[#lines + 1] = name
  lines[#lines + 1] = ""
  lines[#lines + 1] = string.format("%d%% illuminated", illum)
  lines[#lines + 1] = ""
  lines[#lines + 1] = string.format("day %.1f", age)
  return table.concat(lines, "\n")
end

return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    opts.dashboard = opts.dashboard or {}
    opts.dashboard.preset = opts.dashboard.preset or {}
    opts.dashboard.preset.header = moon_header()
    opts.dashboard.sections = { { section = "header" } }
  end,
}
