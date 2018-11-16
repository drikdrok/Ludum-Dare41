game = class("game")

local heartImage = love.graphics.newImage("assets/gfx/hud/heart.png")

function game:initialize()

	createSoundEffects()

	self.fonts = {}
	self.font = love.graphics.newFont("assets/gfx/fonts/04B_03__.ttf")
	love.graphics.setFont(self.font)

	camera = Camera(players[controller.currentPlayer].x, players[controller.currentPlayer].y)
	camera.smoother = Camera.smooth.damped(5)
	camera:zoom(2)

	self.team1Score = 0 
	self.team2Score = 0 

	self.teamPossesion = 0

	self.team1Players = 3
	self.team2Players = 3

	self.state = "menu"
	self.startingTimer = 3

	self.goalColor = {0.5, 0.5, 0.5}
	self.justStarted = true

	self.mins = 2
	self.secs = 30

	self.endMessage = "YOU WON!"
	self.endTimer = 7
end

function game:update(dt)

	if self.state == "playing" then 
		self.justStarted = false 

		doPlayerAI(dt)

		for i,v in pairs(players) do
			if not v.dead then 
				v:update(dt)
				v.hasAId = false
			end
		end

		controller:update(dt)
		
		ball:update(dt)

		updateBullets(dt)
		updateZombies(dt)

		self.secs = self.secs - dt
		if self.secs <= 0 then 
			self.secs = 59
			self.mins = self.mins - 1
		end
		if self.mins < 0 then 
			self:endGame()
		end

	elseif self.state == "starting" then
		self.startingTimer = self.startingTimer - dt
		if not self.justStarted then 
			self.goalColor = {255/255, 229/255, 2/255}
		end
		if self.startingTimer < 0 then 
			self.state = "playing"
			self.goalColor = {0.5, 0.5, 0.5} 
		end
	elseif self.state == "menu" then 
		menu:update()
	elseif self.state == "endgame" then 
		self.endTimer = self.endTimer - dt
		if self.endTimer <= 0 then 
			self.state = "menu" 
		end
	end

	if self.state ~= "endgame" and self.state ~= "menu" then 
		if not players[controller.currentPlayer] then 
			controller:switchToRandom()
		end

		camera:lockPosition(players[controller.currentPlayer].x, players[controller.currentPlayer].y)
	end
end

function game:draw()
	if self.state == "starting" or self.state == "playing" or self.state == "endgame" then 
		camera:attach() -- Everyhing that will be influcenced by the camera
			pitch:draw()

			drawBullets()
			drawZombies()

			for i,v in pairs(players) do
				v:draw()
			end

			ball:draw()

			if debug then 
				local items, len = collisionWorld:getItems()
				for i,v in pairs(items) do
					love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
				end 
			end

		camera:detach()
		--HUD

		self:drawHud()

	elseif self.state == "menu" then 
		menu:draw()
	end

end

function game:fontSize(size)
	if self.fonts[size] then 
		love.graphics.setFont(self.fonts[size])
	else
		self.font = love.graphics.newFont("assets/gfx/fonts/04B_03__.ttf", size)
		self.fonts[size] = self.font
		love.graphics.setFont(self.font)
	end
end

function game:drawHud()

	if self.state == "playing" or self.state == "starting" then 
		love.graphics.setColor(109/255, 112/255, 117/255)
		love.graphics.rectangle("fill", love.graphics.getWidth()/2-175, 0, 350, 35)
		
		love.graphics.setColor(self.goalColor)
		self:fontSize(22)
		love.graphics.print("GOAL!", love.graphics.getWidth()/2-175+40, 5)

		love.graphics.setColor(1,1,1)

		if math.ceil(self.secs) > 9 then  
			love.graphics.print(self.mins..":"..math.ceil(self.secs), love.graphics.getWidth()/2+80, 5)
		else
			love.graphics.print(self.mins..":0"..math.ceil(self.secs), love.graphics.getWidth()/2+80, 5)
		end
	end


	if self.state == "playing" then 
		self:fontSize(22)
		love.graphics.print(self.team1Score.. "-"..self.team2Score, love.graphics.getWidth()/2 - self.font:getWidth(self.team1Score.. "-"..self.team2Score)/2, 5)

		love.graphics.draw(heartImage, 10, 10, 0, 2 ,2)
		self:fontSize(17)
		love.graphics.print("x"..players[controller.currentPlayer].health, 46, 20)


	elseif self.state == "starting" then 
		self:fontSize(22)
		love.graphics.print(math.ceil(self.startingTimer), love.graphics.getWidth()/2 - self.font:getWidth(math.ceil(self.startingTimer))/2, 5)
	elseif self.state == "endgame" then 
		self:fontSize(22)
		love.graphics.setColor(109/255, 112/255, 117/255)
		love.graphics.rectangle("fill", love.graphics.getWidth()/2-175, 0, 350, 35)

		love.graphics.setColor(255/255, 229/255, 2/255)
		love.graphics.print(game.endMessage, love.graphics.getWidth()/2 - self.font:getWidth(self.endMessage)/2, 5)

		love.graphics.setColor(1,1,1)
	end
end

function game:setState(state)
	self.state = state

	if self.state == "starting" then 
		self.startingTimer = 3
	end
end

function game:endGame()
	if self.team1Score > self.team2Score then 
		self.endMessage = "YOU WON!"
	elseif self.team1Score == self.team2Score then 
		self.endMessage = "YOU DREW!"
	else
		self.endMessage = "YOU LOST"
	end


	if self.team1Players == 0 then 
		self.endMessage = "YOU LOST!"
	elseif self.team2Players == 0 then 
		self.endMessage = "YOU WON!"
	end

	self.state = "endgame"
	self.endTimer = 7
end

function game:reset()
	self.team1Score = 0 
	self.team2Score = 0 

	self.teamPossesion = 0

	self.team1Players = 3
	self.team2Players = 3

	self.state = state
	self.startingTimer = 3

	self.state = "starting"

	self.goalColor = {0.5, 0.5, 0.5}

	self.mins = 2
	self.secs = 30

	self.justStarted = true

	for i, v in pairs(players) do
		v.x = 100000 --Fixes "phantom" player bug
		collisionWorld:remove(v)
	end

	players = {
		player:new(math.random(100, 350), math.random(50, 100), 1, 1), player:new(math.random(100, 350), math.random(50, 100), 2, 1), player:new(math.random(100, 350), math.random(50, 100), 3, 1),
		player:new(math.random(100, 350), math.random(500, 550), 4, 2), player:new(math.random(100, 350), math.random(500, 550), 5, 2) , player:new(math.random(100, 350), math.random(500, 550), 6, 2)
	}

	ball:reset()
	
	local ballExists = false
	local items, len = collisionWorld:getItems()

	for i,v in pairs(items) do 
		if v.type == "ball" then 
			ballExists = true
		end
	end

	if ballExists then -- This should fix a crash that happens rarely where the ball gets removed from the world
		collisionWorld:update(ball, ball.x, ball.y)
	else
		collisionWorld:add(ball, ball.x, ball.y)
	end

	removeAllZombies()
	removeAllBullets()
	controller:reset()
end

function createSoundEffects()
	buttonSound = love.audio.newSource("assets/sfx/button.wav", "static")
	goalSound = love.audio.newSource("assets/sfx/goal.wav", "static")
	hurtSound = love.audio.newSource("assets/sfx/hurt.wav", "static")
	passSound = love.audio.newSource("assets/sfx/pass.wav", "static")
	shootSound = love.audio.newSource("assets/sfx/shoot.wav", "static")
end