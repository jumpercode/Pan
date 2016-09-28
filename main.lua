-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local akeys = {up=true, down=true, right=true, left=true}
local keys = {up=false, down=false, right=false, left=false}

local dx = 0
local dy = 0
local pts = 0
local pos = "up"
local rems = {}

local physics = require( "physics" )
physics.start()
physics.setGravity( 0.0, 0.0 )

local mapa = display.newImageRect("res/img/map.png", 1536, 1024)
mapa.x = display.contentCenterX + dx
mapa.y = -32

local globos = {}
for i=1,25 do
    local globo = display.newImageRect("res/img/balloon.png", 32, 32)
    globo.x = display.contentCenterX + math.random(-300, 300)
    globo.y = display.contentCenterY + math.random(-200, 200)
    globo.du = math.random(-4, 4)
    globo.dv = math.random(-4, 4)
    globo.id = "g_" .. i
    physics.addBody(globo, "dinamic", { radius=16, bounce=0.0 } )
    globos["g_" .. i] = globo
end
globos.last = 0

local avion = display.newImageRect("res/img/stuka.png", 80, 48)
avion.x = display.contentCenterX
avion.y = display.contentCenterY
avion.du = 0
avion.dv = 0
physics.addBody( avion, "static", { bounce=0.0 } )

debug = display.newText( "POINTS: "..pts.." / 25\nTIME: 0.0 s", 100, 100, 200, 200, native.systemFontBold, 12 )
debug:setFillColor( 1, 1, 1 )

local function removeGlobo(id)
    physics.removeBody( globos[id] )
    globos[id]:removeSelf()
    globos[id] = nil
end

function clearGlobos()
    for i,v in ipairs(rems) do
        removeGlobo(v)
    end
    rems = {}
end

local function score()
    debug.text = "POINTS: " .. pts .. " / 25 \nTIME: " ..(system.getTimer() / 1000).. " s"
end

local function onLocalCollision( self, event )
    pts = pts+1
    score()
    table.insert( rems, event.other.id )
end
avion.collision = onLocalCollision
avion:addEventListener( "collision" )

local function onKeyEvent( event )
    if(akeys[event.keyName]) then
        keys[event.keyName] = not(keys[event.keyName])
    end
end
Runtime:addEventListener( "key", onKeyEvent )


local function gameLoop()

    local time = system.getTimer()

    clearGlobos()

    avion.du = 0
    avion.dv = 0

    if(keys.up) then
        if(pos ~= "up") then
            avion.rotation = 0
            pos = "up"
        end
        dy = 5
        dx = 0
    elseif(keys.down) then
        if(pos ~= "down") then
            avion.rotation = 180
            pos = "down"
        end
        dy = -5
        dx = 0
    elseif(keys.left) then
        if(pos ~= "left") then
            avion.rotation = -90
            pos = "left"
        end
        dx = 5
        dy = 0
    elseif(keys.right) then
        if(pos ~= "right") then
            avion.rotation = 90
            pos = "right"
        end
        dx = -5
        dy = 0
    end

    if(not(keys.up) and not(keys.down)) then
        dy = 0
    end

    if(not(keys.left) and not(keys.right)) then
        dx = 0
    end

    if(avion.y == display.contentCenterY) then
        if((mapa.y+dy) <= 512 and (mapa.y+dy) >= -32) then
            mapa.y = mapa.y + dy
        else
            avion.dv = -1*dy
            dy = 0
        end
    else
        avion.dv = -1*dy
        dy = 0
    end

    if(avion.x == display.contentCenterX) then
        if((mapa.x+dx) <= 768 and (mapa.x+dx) >= -128) then
            mapa.x = mapa.x + dx
        else
            avion.du = -1*dx
            dx = 0
        end
    else
        avion.du = -1*dx
        dx = 0
    end

    if((time - globos.last) > 1500) then
        for k,v in pairs(globos) do
            if(k ~= "last") then
                globos[k].du = math.random(-4, 4)
                globos[k].dv = math.random(-4, 4)
            end
        end
        globos.last = time
    end

    avion.x = math.floor(avion.x + avion.du + 0.5)
    avion.y = math.floor(avion.y + avion.dv + 0.5)

    for k,v in pairs(globos) do
        if(k ~= "last") then
            globos[k].x = (globos[k].x+globos[k].du)+dx
            globos[k].y = (globos[k].y+globos[k].dv)+dy
        end
    end

end
gameTimer = timer.performWithDelay(16, gameLoop, 0)
