ball = class("ball")

local ballImage = love.graphics.newImage("assets/gfx/balls/ball.png")

function ball:initialize()
	self.x = 223
	self.y = 295
	self.width = 6
	self.height = 6

	self.xvel = 0
	self.yvel = 0 

	self.friction = 5

	self.isStuck = false
	self.stuckTo = players[1]

	self.behindPlayer = false

	self.type = "ball"

	self.collisionTimer = 0
	self.collisionTimerActivated = false

	collisionWorld:add(self, self.x, self.y, self.width, self.height)
end

function ball:update(dt)
	if self.collisionTimerActivated then 
		self.collisionTimer = self.collisionTimer + dt
		if self.collisionTimer >= 0.1 then 
			self.collisionTimer = 0
			self.collisionTimerActivated = false
			collisionWorld:add(self, self.x, self.y, self.width, self.height)
		end
	end

	self:decidePosition()
	self:physics(dt)
	self:collide()


	if not self.collisionTimerActivated then 
		collisionWorld:update(self, self.x, self.y)
	end
end

function ball:draw()
	love.graphics.draw(ballImage, self.x, self.y)
	
	if self.behindPlayer then -- Makes the ball appear behind player. This is instead of creating an entire drawing hierarki
		self.stuckTo:draw()
	end
end

function ball:decidePosition()

	if self.isStuck and self.stuckTo then 
		self.behindPlayer = false
		
		local direction = self.stuckTo.direction

		if direction == 1 or direction == 2 or direction == 3 then 
			self.behindPlayer = true

			self.x = self.stuckTo.x + self.stuckTo.width/2 - self.width/2
			self.y = self.stuckTo.y + self.stuckTo.height - self.stuckTo.height/2
		elseif direction == 4 then 
			self.x = self.stuckTo.x + self.stuckTo.width - 3
			self.y = self.stuckTo.y + self.stuckTo.height - self.stuckTo.height/4
		elseif direction == 5 or direction == 6 or direction == 7 then 
			self.x = self.stuckTo.x + self.stuckTo.width/2 - self.width/2
			self.y = self.stuckTo.y + self.stuckTo.height + 1
		elseif direction == 8 then 
			self.x = self.stuckTo.x - 3
			self.y = self.stuckTo.y + self.stuckTo.height/2 + self.stuckTo.height/4
		end
	end
end

function ball:physics(dt)
	if not self.isStuck then 

		self.xvel = self.xvel * (1 - math.min(dt*self.friction, 1)) --Friction
		self.yvel = self.yvel * (1 - math.min(dt*self.friction, 1)) 

		self.x = self.x + self.xvel*dt
		self.y = self.y + self.yvel*dt

		if self.x < 0 then 
			self.x = 0
		elseif self.x > pitch.width - self.width then 
			self.x = pitch.width - self.width
		end
		if self.y < 0 then 
			self.y = 0
		elseif self.y > pitch.height - self.height then 
			self.y = pitch.height - self.height
		end

		if not self.collisionTimerActivated then 
			collisionWorld:update(self, self.x, self.y)
		end
	end 
end

function ball:collide()
	if not self.collisionTimerActivated then 
		local actualX, actualY, cols, len = collisionWorld:check(self, self.x, self.y)

		if #cols > 0 then 
			for i,v in pairs(cols) do 
				if v.other.type == "goal" then 
					local team = v.other.team
					if team == 1 then 
						game.team2Score = game.team2Score + 1
					elseif team == 2 then 
						game.team1Score = game.team1Score + 1
					end

					self:reset()
					--self.stuckTo = players[1] --This doesn't matter

					game.teamPossesion = 0

					for i,v in pairs(players) do -- Remove every player 
						v.x = 1000000 --Without this a "phantom" ghost willa appear when scoring in own goal. i don't know why but i dont have time to fix it properly
						players[i] = nil
						collisionWorld:remove(v, v.x, v.y)
					end

					--players = {
					--	player:new(150, 122, 1, 1), player:new(300, 122, 2, 1), player:new(225, 122, 3, 1),
					--	player:new(150, 500, 4, 2), player:new(300, 500, 5, 2) , player:new(225, 500, 6, 2)
					--}

					players = {}

					if game.team1Players >= 1 then 
						players[1] = player:new(math.random(100, 350), 122, 1, 1)
					end
					if game.team1Players >= 2 then 
						players[2] = player:new(math.random(100, 350), 122, 2, 1)
					else
						controller:switchPlayer(1)
					end
					if game.team1Players >= 3 then
						players[3] = player:new(math.random(100, 350), 122, 3, 1)
					end


					if game.team2Players >= 1 then 
						players[4] = player:new(math.random(100, 350), 500, 4, 2)
					end
					if game.team2Players >= 2 then 
						players[5] = player:new(math.random(100, 350), 500, 5, 2)
					end
					if game.team2Players >= 3 then
						players[6] = player:new(math.random(100, 350), 500, 6, 2)
					end


					love.audio.play(goalSound)
					game:setState("starting")

				end 
			end
		end 
	end
end 

function ball:collisionTimerStart()
	if not self.collisionTimerActivated then 
		collisionWorld:remove(self)
	end
	self.collisionTimerActivated = true
end

function ball:reset()
	self.x = 223
	self.y = 295
	self.xvel = 0
	self.yvel = 0 
	self.isStuck = false
	players[controller.currentPlayer].hasBall = false
end