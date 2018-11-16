love.graphics.setDefaultFilter("nearest", "nearest")

require("assets/codebase/core/require")

debug = false

function love.load()
	math.randomseed(os.time())

	collisionWorld = bump.newWorld()
	
	players = {
		player:new(math.random(100, 350), 122, 1, 1), player:new(math.random(100, 350), 122, 2, 1), player:new(math.random(100, 350), 122, 3, 1),
		player:new(math.random(100, 350), 500, 4, 2), player:new(math.random(100, 350), 500, 5, 2) , player:new(math.random(100, 350), 500, 6, 2)
	}

	controller = controller:new()

	game = game:new()

	ball = ball:new()
	pitch = pitch:new()

	menu = menu:new()

	--zombie:new()

end

function love.update(dt)
	game:update(dt)
end

function love.draw()
	game:draw()

	if debug then 
		love.graphics.print(zombieIntervalss)
	end
end

function love.keypressed(key)
	if key == "escape" then 
		if game.state == "playing" or game.state == "starting" or game.state == "endgame" then
			game.state = "menu"
		else
			love.event.quit()
		end
	elseif key == "f1" then 
		debug = not debug
	elseif key == "f" and not players[controller.currentPlayer].hasBall then 
		controller:switchToRandom()
	elseif key == "r" then 
		n = 0 
	elseif key == "l" then
		
	end

end

function love.mousepressed(x, y, button)
	if button == 1 and game.state == "menu" then 
		menu:click()
	end
end

local scrollLimit = true
function love.wheelmoved(x, y)
	if scrollLimit then 
		if y > 0 and camera.scale < 4.6 then
	        camera.scale = camera.scale + 0.1
	    elseif y < 0 and camera.scale > 1.8 then
	        camera.scale = camera.scale - 0.1
	    end
	else
		if y > 0 then
	        camera.scale = camera.scale + 0.1
	    elseif y < 0  then
	        camera.scale = camera.scale - 0.1
	    end
	end
end
