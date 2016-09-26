-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local akeys = {up=true, down=true, right=true, left=true}
local keys = {up=false, down=false, right=false, left=false}

local dx = 0
local dy = 0
local pos = "up"

local mapa = display.newImageRect("res/img/map.png", 1536, 1024)
mapa.x = display.contentCenterX + dx
mapa.y = -32

local globo = display.newImageRect("res/img/balloon.png", 32, 32)
globo.x = 100
globo.y = 100
globo.du = 1
globo.dv = 1
globo.last = 0

local avion = display.newImageRect("res/img/stuka.png", 80, 48)
avion.x = display.contentCenterX
avion.y = display.contentCenterY
avion.du = 0
avion.dv = 0

local function onKeyEvent( event )
    if(akeys[event.keyName]) then
        keys[event.keyName] = not(keys[event.keyName])
    end
end

Runtime:addEventListener( "key", onKeyEvent )

local function gameLoop()

    local time = system.getTimer()

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

    if((time - globo.last) > 3000) then
        globo.du = math.random(-3, 3)
        globo.dv = math.random(-3, 2)
        globo.last = time
    end

    avion.x = avion.x + avion.du
    avion.y = avion.y + avion.dv

    globo.x = (globo.x+globo.du)+dx
    globo.y = (globo.y+globo.dv)+dy

end

gameTimer = timer.performWithDelay(16, gameLoop, 0)
