--Note that the upper case keys are actually the lower case letter sprites.
--pico 8 saves all text as lowercase in p8 files, but only renders upper case letters
--cart developers can use them by using the escaped ascii codes

fontSpriteTable = {
    [" "] = { { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } },
    ["!"] = { { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 }, { 0, 0, 0 }, { 0, 1, 0 } },
    ['"'] = { { 1, 0, 1 }, { 1, 0, 1 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } },
    ["#"] = { { 1, 0, 1 }, { 1, 1, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 1, 0, 1 } },
    ["$"] = { { 1, 1, 1 }, { 1, 1, 0 }, { 0, 1, 1 }, { 1, 1, 1 }, { 0, 1, 0 } },
    ["%"] = { { 1, 0, 1 }, { 0, 0, 1 }, { 0, 1, 0 }, { 1, 0, 0 }, { 1, 0, 1 } },
    ["&"] = { { 1, 1, 0 }, { 1, 1, 0 }, { 1, 1, 0 }, { 1, 0, 1 }, { 1, 1, 1 } },
    ["'"] = { { 0, 1, 0 }, { 1, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } },
    ["("] = { { 0, 1, 0 }, { 1, 0, 0 }, { 1, 0, 0 }, { 1, 0, 0 }, { 0, 1, 0 } },
    [")"] = { { 0, 1, 0 }, { 0, 0, 1 }, { 0, 0, 1 }, { 0, 0, 1 }, { 0, 1, 0 } },
    ["*"] = { { 1, 0, 1 }, { 0, 1, 0 }, { 1, 1, 1 }, { 0, 1, 0 }, { 1, 0, 1 } },
    ["+"] = { { 0, 0, 0 }, { 0, 1, 0 }, { 1, 1, 1 }, { 0, 1, 0 }, { 0, 0, 0 } },
    [","] = { { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 1, 0 }, { 1, 0, 0 } },
    ["-"] = { { 0, 0, 0 }, { 0, 0, 0 }, { 1, 1, 1 }, { 0, 0, 0 }, { 0, 0, 0 } },
    ["."] = { { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 1, 0 } },
    ["/"] = { { 0, 0, 1 }, { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 }, { 1, 0, 0 } },
    ["0"] = { { 1, 1, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 1 } },
    ["1"] = { { 1, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 }, { 1, 1, 1 } },
    ["2"] = { { 1, 1, 1 }, { 0, 0, 1 }, { 1, 1, 1 }, { 1, 0, 0 }, { 1, 1, 1 } },
    ["3"] = { { 1, 1, 1 }, { 0, 0, 1 }, { 0, 1, 1 }, { 0, 0, 1 }, { 1, 1, 1 } },
    ["4"] = { { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 0, 0, 1 }, { 0, 0, 1 } },
    ["5"] = { { 1, 1, 1 }, { 1, 0, 0 }, { 1, 1, 1 }, { 0, 0, 1 }, { 1, 1, 1 } },
    ["6"] = { { 1, 0, 0 }, { 1, 0, 0 }, { 1, 1, 1 }, { 1, 0, 1 }, { 1, 1, 1 } },
    ["7"] = { { 1, 1, 1 }, { 0, 0, 1 }, { 0, 0, 1 }, { 0, 0, 1 }, { 0, 0, 1 } },
    ["8"] = { { 1, 1, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 1, 0, 1 }, { 1, 1, 1 } },
    ["9"] = { { 1, 1, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 0, 0, 1 }, { 0, 0, 1 } },
    [":"] = { { 0, 0, 0 }, { 0, 1, 0 }, { 0, 0, 0 }, { 0, 1, 0 }, { 0, 0, 0 } },
    [";"] = { { 0, 0, 0 }, { 0, 1, 0 }, { 0, 0, 0 }, { 0, 1, 0 }, { 1, 0, 0 } },
    ["<"] = { { 0, 0, 1 }, { 0, 1, 0 }, { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 } },
    ["="] = { { 0, 0, 0 }, { 1, 1, 1 }, { 0, 0, 0 }, { 1, 1, 1 }, { 0, 0, 0 } },
    [">"] = { { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 }, { 0, 1, 0 }, { 1, 0, 0 } },
    ["?"] = { { 1, 1, 1 }, { 0, 0, 1 }, { 0, 1, 1 }, { 0, 0, 0 }, { 0, 1, 0 } },
    ["@"] = { { 0, 1, 0 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 0 }, { 0, 1, 1 } },
    ["A"] = { { 0, 0, 0 }, { 1, 1, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 1, 0, 1 } },
    ["B"] = { { 0, 0, 0 }, { 1, 1, 0 }, { 1, 1, 0 }, { 1, 0, 1 }, { 1, 1, 1 } },
    ["C"] = { { 0, 0, 0 }, { 1, 1, 1 }, { 1, 0, 0 }, { 1, 0, 0 }, { 1, 1, 1 } },
    ["D"] = { { 0, 0, 0 }, { 1, 1, 0 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 0 } },
    ["E"] = { { 0, 0, 0 }, { 1, 1, 1 }, { 1, 1, 0 }, { 1, 0, 0 }, { 1, 1, 1 } },
    ["F"] = { { 0, 0, 0 }, { 1, 1, 1 }, { 1, 1, 0 }, { 1, 0, 0 }, { 1, 0, 0 } },
    ["G"] = { { 0, 0, 0 }, { 1, 1, 1 }, { 1, 0, 0 }, { 1, 0, 1 }, { 1, 1, 1 } },
    ["H"] = { { 0, 0, 0 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 1, 0, 1 } },
    ["I"] = { { 0, 0, 0 }, { 1, 1, 1 }, { 0, 1, 0 }, { 0, 1, 0 }, { 1, 1, 1 } },
    ["J"] = { { 0, 0, 0 }, { 1, 1, 1 }, { 0, 1, 0 }, { 0, 1, 0 }, { 1, 1, 0 } },
    ["K"] = { { 0, 0, 0 }, { 1, 0, 1 }, { 1, 1, 0 }, { 1, 0, 1 }, { 1, 0, 1 } },
    ["L"] = { { 0, 0, 0 }, { 1, 0, 0 }, { 1, 0, 0 }, { 1, 0, 0 }, { 1, 1, 1 } },
    ["M"] = { { 0, 0, 0 }, { 1, 1, 1 }, { 1, 1, 1 }, { 1, 0, 1 }, { 1, 0, 1 } },
    ["N"] = { { 0, 0, 0 }, { 1, 1, 0 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 } },
    ["O"] = { { 0, 0, 0 }, { 0, 1, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 0 } },
    ["P"] = { { 0, 0, 0 }, { 1, 1, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 1, 0, 0 } },
    ["Q"] = { { 0, 0, 0 }, { 0, 1, 0 }, { 1, 0, 1 }, { 1, 1, 0 }, { 0, 1, 1 } },
    ["R"] = { { 0, 0, 0 }, { 1, 1, 1 }, { 1, 0, 1 }, { 1, 1, 0 }, { 1, 0, 1 } },
    ["S"] = { { 0, 0, 0 }, { 0, 1, 1 }, { 1, 0, 0 }, { 0, 0, 1 }, { 1, 1, 0 } },
    ["T"] = { { 0, 0, 0 }, { 1, 1, 1 }, { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 } },
    ["U"] = { { 0, 0, 0 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 0, 1, 1 } },
    ["V"] = { { 0, 0, 0 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 0, 1, 0 } },
    ["W"] = { { 0, 0, 0 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 1, 1, 1 } },
    ["X"] = { { 0, 0, 0 }, { 1, 0, 1 }, { 0, 1, 0 }, { 1, 0, 1 }, { 1, 0, 1 } },
    ["Y"] = { { 0, 0, 0 }, { 1, 0, 1 }, { 1, 1, 1 }, { 0, 0, 1 }, { 1, 1, 1 } },
    ["Z"] = { { 0, 0, 0 }, { 1, 1, 1 }, { 0, 0, 1 }, { 1, 0, 0 }, { 1, 1, 1 } },
    ["["] = { { 1, 1, 0 }, { 1, 0, 0 }, { 1, 0, 0 }, { 1, 0, 0 }, { 1, 1, 0 } },
    ["\\"] = { { 1, 0, 0 }, { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 }, { 0, 0, 1 } },
    ["]"] = { { 0, 1, 1 }, { 0, 0, 1 }, { 0, 0, 1 }, { 0, 0, 1 }, { 0, 1, 1 } },
    ["^"] = { { 0, 1, 0 }, { 1, 0, 1 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } },
    ["_"] = { { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 1, 1, 1 } },
    ["`"] = { { 0, 1, 0 }, { 0, 0, 1 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } },
    ["a"] = { { 1, 1, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 1, 0, 1 }, { 1, 0, 1 } },
    ["b"] = { { 1, 1, 1 }, { 1, 0, 1 }, { 1, 1, 0 }, { 1, 0, 1 }, { 1, 1, 1 } },
    ["c"] = { { 0, 1, 1 }, { 1, 0, 0 }, { 1, 0, 0 }, { 1, 0, 0 }, { 0, 1, 1 } },
    ["d"] = { { 1, 1, 0 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 1 } },
    ["e"] = { { 1, 1, 1 }, { 1, 0, 0 }, { 1, 1, 0 }, { 1, 0, 0 }, { 1, 1, 1 } },
    ["f"] = { { 1, 1, 1 }, { 1, 0, 0 }, { 1, 1, 0 }, { 1, 0, 0 }, { 1, 0, 0 } },
    ["g"] = { { 0, 1, 1 }, { 1, 0, 0 }, { 1, 0, 0 }, { 1, 0, 1 }, { 1, 1, 1 } },
    ["h"] = { { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 1, 0, 1 }, { 1, 0, 1 } },
    ["i"] = { { 1, 1, 1 }, { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 }, { 1, 1, 1 } },
    ["j"] = { { 1, 1, 1 }, { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 }, { 1, 1, 0 } },
    ["k"] = { { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 0 }, { 1, 0, 1 }, { 1, 0, 1 } },
    ["l"] = { { 1, 0, 0 }, { 1, 0, 0 }, { 1, 0, 0 }, { 1, 0, 0 }, { 1, 1, 1 } },
    ["m"] = { { 1, 1, 1 }, { 1, 1, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 } },
    ["n"] = { { 1, 1, 0 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 } },
    ["o"] = { { 0, 1, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 0 } },
    ["p"] = { { 1, 1, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 1, 0, 0 }, { 1, 0, 0 } },
    ["q"] = { { 0, 1, 0 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 0 }, { 0, 1, 1 } },
    ["r"] = { { 1, 1, 1 }, { 1, 0, 1 }, { 1, 1, 0 }, { 1, 0, 1 }, { 1, 0, 1 } },
    ["s"] = { { 0, 1, 1 }, { 1, 0, 0 }, { 1, 1, 1 }, { 0, 0, 1 }, { 1, 1, 0 } },
    ["t"] = { { 1, 1, 1 }, { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 } },
    ["u"] = { { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 0, 1, 1 } },
    ["v"] = { { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 0, 1, 0 } },
    ["w"] = { { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 1, 1, 1 } },
    ["x"] = { { 1, 0, 1 }, { 1, 0, 1 }, { 0, 1, 0 }, { 1, 0, 1 }, { 1, 0, 1 } },
    ["y"] = { { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 0, 0, 1 }, { 1, 1, 1 } },
    ["z"] = { { 1, 1, 1 }, { 0, 0, 1 }, { 0, 1, 0 }, { 1, 0, 0 }, { 1, 1, 1 } },
    ["{"] = { { 0, 1, 1 }, { 0, 1, 0 }, { 1, 1, 0 }, { 0, 1, 0 }, { 0, 1, 1 } },
    ["|"] = { { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 } },
    ["}"] = { { 1, 1, 0 }, { 0, 1, 0 }, { 0, 1, 1 }, { 0, 1, 0 }, { 1, 1, 0 } },
    ["~"] = { { 0, 0, 0 }, { 0, 0, 1 }, { 1, 1, 1 }, { 1, 0, 0 }, { 0, 0, 0 } },
    [""] = { { 0, 0, 0 }, { 0, 1, 0 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 1 } },
    ["Ç"] = { { 1, 1, 1 }, { 1, 1, 1 }, { 1, 1, 1 }, { 1, 1, 1 }, { 1, 1, 1 } },
    ["ü"] = { { 1, 0, 1 }, { 0, 1, 0 }, { 1, 0, 1 }, { 0, 1, 0 }, { 1, 0, 1 } },
    ["é"] = { { 0, 0, 1 }, { 1, 1, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 1, 0 } },
    ["â"] = { { 1, 1, 0 }, { 0, 1, 1 }, { 0, 1, 1 }, { 1, 1, 1 }, { 1, 1, 0 } },
    ["ä"] = { { 1, 0, 0 }, { 0, 0, 1 }, { 1, 0, 0 }, { 0, 0, 1 }, { 1, 0, 0 } },
    ["à"] = { { 0, 0, 0 }, { 1, 1, 0 }, { 1, 0, 0 }, { 1, 0, 0 }, { 1, 0, 0 } },
    ["å"] = { { 1, 0, 0 }, { 0, 1, 0 }, { 1, 1, 0 }, { 1, 1, 0 }, { 1, 0, 0 } },
    ["ç"] = { { 1, 1, 0 }, { 1, 1, 0 }, { 1, 1, 0 }, { 1, 0, 0 }, { 0, 0, 0 } },
    ["ê"] = { { 1, 0, 0 }, { 1, 1, 0 }, { 1, 1, 1 }, { 1, 1, 0 }, { 1, 0, 0 } },
    ["ë"] = { { 1, 0, 0 }, { 1, 0, 0 }, { 1, 1, 0 }, { 1, 0, 0 }, { 1, 0, 0 } },
    ["è"] = { { 1, 0, 0 }, { 1, 1, 0 }, { 1, 1, 1 }, { 0, 1, 0 }, { 1, 1, 0 } },
    ["ï"] = { { 1, 1, 0 }, { 0, 1, 1 }, { 0, 1, 1 }, { 0, 1, 1 }, { 1, 1, 0 } },
    ["î"] = { { 1, 1, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 0, 0, 1 }, { 1, 1, 1 } },
    ["ì"] = { { 1, 1, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } },
    ["Ä"] = { { 1, 1, 0 }, { 0, 1, 1 }, { 0, 1, 1 }, { 0, 1, 1 }, { 1, 1, 0 } },
    ["Å"] = { { 0, 0, 0 }, { 1, 0, 0 }, { 1, 1, 0 }, { 1, 0, 0 }, { 0, 0, 0 } },
    ["É"] = { { 0, 0, 0 }, { 0, 0, 0 }, { 1, 0, 1 }, { 0, 0, 0 }, { 0, 0, 0 } },
    ["æ"] = { { 1, 1, 0 }, { 1, 1, 1 }, { 0, 1, 1 }, { 1, 1, 1 }, { 1, 1, 0 } },
    ["Æ"] = { { 0, 0, 0 }, { 1, 0, 0 }, { 1, 1, 1 }, { 1, 1, 0 }, { 0, 1, 0 } },
    ["ô"] = { { 1, 1, 0 }, { 1, 0, 0 }, { 0, 0, 0 }, { 1, 0, 0 }, { 1, 1, 0 } },
    ["ö"] = { { 1, 1, 0 }, { 1, 1, 1 }, { 0, 1, 1 }, { 0, 1, 1 }, { 1, 1, 0 } },
    ["ò"] = { { 0, 0, 0 }, { 0, 0, 0 }, { 1, 0, 1 }, { 0, 1, 0 }, { 0, 0, 0 } },
    ["û"] = { { 0, 0, 0 }, { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 }, { 0, 0, 0 } },
    ["ù"] = { { 1, 1, 0 }, { 0, 1, 1 }, { 1, 1, 1 }, { 0, 1, 1 }, { 1, 1, 0 } },
    ["ÿ"] = { { 1, 1, 1 }, { 0, 0, 0 }, { 1, 1, 1 }, { 0, 0, 0 }, { 1, 1, 1 } },
    ["Ö"] = { { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 } },
    ["┬"] = { { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 }, { 1, 0, 1 } }
  }