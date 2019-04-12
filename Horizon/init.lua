--[[
                     _                                  
                  (`  ).                   _           
                 (     ).              .:(`  )`.       
    )           _(       '`.          :(   .    )      
            .=(`(      .   )     .--  `.  (    ) )      
           ((    (..__.:'-'   .+(   )   ` _`  ) )                 
    `.     `(       ) )       (   .  )     (   )  ._   
      )      ` __.:'   )     (   (   ))     `-'.-(`  ) 
    )  )  ( )       --'       `- __.'         :(      )) 
    .-'  (_.'          .')                    `(    )  ))
                      (_  )                     ` __.:'          
                                            
    --..,___.--,--'`,---..-.--+--.,,-,,..._.--..-._.-a:f--.

    Horizön
    3DS <-> PC Löve Bridge
--]]

Horizon =
{
    _VERSION = "1.0.1",
    RUNNING = (love.system.getOS() ~= "Horizon")
}

--SYSTEM CHECK
if not Horizon.RUNNING then
    return
end

Horizon.RUNNING = true

local _PACKAGE = ...

Enum = require(_PACKAGE .. ".enum")
CONFIG = require(_PACKAGE .. ".config")

require(_PACKAGE .. ".input")
require(_PACKAGE .. ".render")
require(_PACKAGE .. ".system")

love.window.setMode(400, 480, {vsync = true})
love.window.setTitle("NINTENDO 3DS :: " .. love.filesystem.getIdentity():upper())

if CONFIG.BOOT then
    require(_PACKAGE .. ".boot")
end

require(_PACKAGE .. ".objects")