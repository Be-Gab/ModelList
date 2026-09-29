--[[#######################################################################
##  app.lua                                                              ##
##                BattUseView - app                                      ##
##                                                                       ##
## Author: BeGab                                                         ##
##                                                                       ##
## URL   : https://github.com/Be-Gab/BattUseView                         ##
##                                                                       ##
##                      Copyright (C) "BeGab"                            ##
##                                                                       ##
###########################################################################
## License GNU General Public License v3.0                               ##
#########################################################################]] 
local app = ...

local A = {}
app.STATE = {}
	app.STATE.INIT							=	 1
	app.STATE.SHOW_MODEL_LIST			=	20
	app.STATE.SHOW_MODEL_LIST_WAIT	=	30
	app.STATE.QUIT							=	999

app.state = app.STATE.INIT

local function getModelsTable()
    local models = {}

    for fname in dir("/MODELS") do
        -- Csak a modelXX.yml fájlokat vesszük
        local num = string.match( fname , "^model(%d+)%.yml$" )
        if num then
            local id = tonumber(num)
            local modelName = fname          -- fallback a fájlnévre

            -- Megpróbáljuk kiolvasni a valódi nevet a YAML-ból
            local f = io.open("/MODELS/" .. fname, "r")
            if f then
                while true do
                    local line = io.read(f, 120)
                    if not line or #line == 0 then break end

                    -- Keresés: name: "Valami név"  vagy  name: Valami név
                    local found = string.match( line , 'name:%s*"?([^"\r\n]+)"?' )
                    if found then
                        modelName = string.match( found , "^%s*(.-)%s*$" )  -- trim
                        break
                    end
                end
                io.close(f)
            end

            models[id] =	{	["id"] = id,
										["modelName"] = modelName,
										["fileName" ] = fname
									}
        end
    end

    return models
end

local function isFileExist(fileName)
    if type(fileName) ~= "string" or fileName == "" then
        return false
    end

    local fileName = io.open(fileName, "r")  
    if fileName then
        io.close(fileName)
        return true
    end
    return false
end
  
local function getFilesByExtension(path, extension)
    if type(path) ~= "string" or path == "" then
        return {}
    end

    local result = {}
	 local extLen = -1 * #extension

    -- EdgeTX-ben a dir() iterator-t ad vissza
    for fname in dir(path) do
			app.d.log( "fname" , fname , "getFilesByExtension()" )
		  if string.sub( fname, extLen ) == extension then
            table.insert(result, fname)
        end
    end
	 
	 app.d.printAssoc( "getFilesByExtension() :: result" ,  result )

    return result
end 

local function modelsNamesForCfgFiles( aCfgFiles, aAllModel )	 
	local cfgModels	= {}, id
	
	-- app.d.printAssoc( "aAllModel" , aAllModel )
	-- app.d.printAssoc( "aCfgFiles" , aCfgFiles )
	
	for k , f in ipairs( cfgFiles ) do
	
		id = tonumber( string.match( f , "(%d+)") )
		
		if aAllModel[ id ] then
			-- Csak azok a .cfg állományok melyenek van párja az aAllModel-ben -> van ilye a /MODELS mappában is. Teszten érdekes ez.
			
			cfgModels[ id ] =	{	["name"]		= aAllModel[ id ]	,
										["cfgFile"]	= f
									}	
								
		end
	end

	-- app.d.printAssoc( "Return" , cfgModels )

	return cfgModels
end


-- ====================================================================================================================

local function showErrorMessage( s )

	dispErrorMsg(  s )

	app.state = app.STATE.SHOW_MODEL_LIST_WAIT

	return 0
end


local function proc_ShowModelList()
	local mdlTable = getModelsTable()

	local function modelLine( mdl )
		local ui =	{	type = "rectangle" , 
							filled		= false , 
							thickness	= 2 ,
							rounded		= 6 , 
							flexFlow		= lvgl.FLOW_ROW , flexPad = 0 , 
							scrollBar	= false, scrollDir = 0 , 
							children = {
								{	type	= "label" ,
									align	= CENTER ,
									w		= 40 * lvgl.LCD_SCALE ,
									text	= mdl.id 
								} ,
								{	type	= "label" ,
									align	= CENTER ,
									w		= 250 * lvgl.LCD_SCALE ,
									text	= mdl.modelName 
								} ,
								{	type	= "label" ,
									align= RIGHT,
									w		= 100 * lvgl.LCD_SCALE ,
									text	= mdl.fileName
								}
							}
						}
		
		return ui
	end
	
	local lineUi = {}
	
	for id , mdl in pairs( mdlTable ) do
		lineUi[ #lineUi+1 ] = modelLine( mdl )
	end

	lvgl.clear()
	
--[[#######################################################################
[box  - fullScreen
	[rectangle
		[Label:title] ,
		[button: close ]
	],
	[ box, scroll
		[ rectanle
			[label ], id
			[label ], name
			[label ], filename
			[label ], rx data
		] ,
		..
	]
]
#########################################################################]] 	
	
	ui =                                     
	{
		{	type = "box", -- id = "fullScreen" ,
			scrollBar = false, scrollDir = 0,
			flexFlow = lvgl.FLOW_COLUMN , 
			flexPad =  0 , 
			x = 0 , 
			y = 0 ,
			w = LCD_W , 
			h = LCD_H ,  
			children = {
				{	type = "rectangle" ,
					flexFlow = lvgl.FLOW_ROW , 
					flexPad =  0 , 
					scrollBar = false, scrollDir = 0,
					w = LCD_W , 
					align = CENTER,
					color = COLOR_THEME_SECONDARY1 ,
					h 	= 40 * lvgl.LCD_SCALE ,
					children	= {
						{	type	= "label" ,
							w		= LCD_W * 0.6, 
							align = CENTER,
							text	= "Models on the radio"
						},
						{	type = "button" ,
							text = " Quit ",
							press = (function()  app.state = app.STATE.QUIT; end)				
						}
					}
				},
				{	type = "box",  
					flexFlow = lvgl.FLOW_COLUMN , 
					flexPad	= lvgl.PAD_MEDIUM , 
					scrollBar = true, scrollDir = lvgl.SCROLL_VER,
					w = LCD_W , 
					h = LCD_H - ( 40 * lvgl.LCD_SCALE ) ,  
					children = 	lineUi
				}
						
			}
		}
	}
	
	-- app.d.printAssoc( " proc_ShowModelList() : ui" , ui  )
	-- app.d.printAssoc( " proc_ShowModelList() : lineUi" , lineUi  )
	
	lvgl.build( ui )	

	app.state = app.STATE.SHOW_MODEL_LIST_WAIT
	return 0
end

local function state_INIT()
	
	-- -----------------------------------------------------------------------
	
		app.d	=	loadScript( app.otsFolder .. "d.lua"   , "tbd" )( app.shortname )
		-- app.dt=	loadScript( app.appFolder .. "dt.lua"  , "tbd" )( app )

		-- TODO : Set AppLog file.
		-- app.d.setLogFile( "BUV" )
		-- app.d.log( "setLogFile()" ,  "BUV ..." , "state_INIT()" )
		
		-- -----------------------------------------------------------------------
		-- app.cbm = loadScript( app.appFolder .. "cbm.lua"   , "tbd" )( app )
		
		-- app.cbm.load(	app.appFolder .. "/csvfile.lua" , 
							-- app.appFolder .. "/batfiles/" .. "batmodel.csv" )
		
		
		-- app.cbm.test()
		

		-- app.modelList = getModelsTable()		-- All model on the radio
		-- app.d.printAssoc( "state_INIT() :: getModelsTable() ->" ,  app.modelList )


		-- -- Search Model name for all models\*.cfg
		-- cfgFiles = getFilesByExtension( app.appFolder .. "/models" , ".cfg")
		-- app.aCfgModels	= modelsNamesForCfgFiles( cfgFiles, app.modelList )	 

	app.state = app.STATE.SHOW_MODEL_LIST
	
	return 0
	
end 

function proc_WAIT()
	return 0
end
-- #############################################################

function A.init()
	state_INIT()
   return 0
end

function A.run(event, touchState)

	-- Alap eseménykezelés
	if event == EVT_VIRTUAL_EXIT then
		return 1
	end

	if app.state == app.STATE.INIT then
		return state_INIT()

	
	elseif app.state == app.STATE.SHOW_MODEL_LIST then
		proc_ShowModelList()
		
	elseif app.state == app.STATE.SHOW_MODEL_LIST_WAIT then
		proc_WAIT()
		
	elseif app.state == app.STATE.QUIT then
		return 2
			
	else
		error( "state not exist : " .. app.state )
		return 2
		
	end

   return 0
end


return A
