-- TNS|Model List|TNE
--[[#######################################################################
##  main.lua                                                             ##
##                ModelIDs - main                                        ##
##                                                                       ##
## Author: BeGab                                                         ##
## Date:    2026-04-01                                                   ##
## Version: 1.0                                                          ## 
## URL   : https://github.com/Be-Gab/ModelIDs                            ##
##                                                                       ##
##                      Copyright (C) "BeGab"                            ##
##                                                                       ##
###########################################################################
## License GNU General Public License v3.0                               ##
#########################################################################]]


-- /(.:ModelList.|.:ModelList.^f_stat|filerw|error^f_stat|warning|^f_stat|-(E|W)-)/i

local app	= {}
		app.ver			= "1.0"
		app.shortname	= "ModelList"
		app.name			= "ModelList"
		app.otsFolder	= "/SCRIPTS/TOOLS/ModelList/"		-- One-Time-Script Path


print( "Loading " .. app.name .. " ver: " .. app.ver )

app.prg	=	loadScript( app.otsFolder .. "app.lua" , "tbd" )( app )


return { init		=	app.prg.init , 
			run		=	app.prg.run , 
			useLvgl	=	true }
