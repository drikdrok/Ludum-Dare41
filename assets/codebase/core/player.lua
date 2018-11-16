player = class("function")

local shadowImage = love.graphics.newImage("assets/gfx/misc/shadow.png")

function player:initialize(x, y, id, team)
	self.x = x or 10
	self.y = y or 10

	self.lastX = x
	self.lastY = y

	self.spawnX = x
	self.spawnY = y

	self.width = 16
	self.height = 22

	self.speed = 100

	self.id = id
	self.team = team

	self.beingControlled = false

	self.stunTimer = 0 

	self.direction = 5
	self.hasAId = false

	self.sheet = love.graphics.newImage("assets/gfx/teams/team"..team..".png")

	self.health = 3
	self.dead = false
	self.damageIndicator = 0

	self.shootingRange = 150

	local sheetWidth = self.sheet:getWidth()
	local sheetHeight = self.sheet:getHeight()

	self.quads = {
		love.graphics.newQuad(0, 0, 16, 22, sheetWidth, sheetHeight),
		love.graphics.newQuad(16, 0, 16, 22, sheetWidth, sheetHeight),
		love.graphics.newQuad(32, 0, 16, 22, sheetWidth, sheetHeight),
		love.graphics.newQuad(48, 0, 16, 22, sheetWidth, sheetHeight),
		love.graphics.newQuad(64, 0, 16, 22, sheetWidth, sheetHeight),
	}

	self.currentQuad = 1

	self.up = false
	self.left = false
	self.down = false
	self.right = false

	self.type = "player"

	self.hasBall = false

	self.ballOffset = math.random(0, 50)

	self.directionTimer = 0

	self.bulletCooldown = 0

	self.arm = arm:new(self.team, self.id)

	collisionWorld:add(self, self.x, self.y, self.width, self.height)
end

function player:update(dt)
	if self.stunTimer <= 0 then 
		self:movementAI(dt)
	else
		self.stunTimer = self.stunTimer - dt
	end

	self:collide()

	if not self.dead then 
		self:shootingAI()

		self.directionTimer = self.directionTimer + dt
		self.bulletCooldown = self.bulletCooldown - dt
		self.damageIndicator = self.damageIndicator - dt

		if not self.beingControlled and self.directionTimer > 0.5 then
			decideDirection(self)
		end

		collisionWorld:update(self, self.x, self.y)
	end
end

function player:draw()

	love.graphics.draw(shadowImage, self.x+4, self.y + 15)	

	if self.damageIndicator > 0 then 
		love.graphics.setColor(1, 0.5, 0.5)
	end

	self.arm:update()
	if self.direction == 1 or self.direction == 2 or self.direction == 3 or self.direction == 4 then --Drawing order for arm
		self.arm:draw()
	end

	love.graphics.draw(self.sheet, self.quads[self.currentQuad], self.x, self.y)

	if self.direction == 5 or self.direction ==  6 or self.direction ==  7 or self.direction == 8 then 
		self.arm:draw()
	end

	love.graphics.setColor(1, 1, 1)
	
end

function player:collide()

	local actualX, actualY, cols, len = collisionWorld:check(self, self.x, self.y)

	if #cols > 0 then 
		for i,v in pairs(cols) do 
			if v.other.type == "ball" then 
				ball.isStuck = true
				ball.stuckTo = players[self.id]
				if self.team == controller.team then 
					controller:switchPlayer(self.id)
				end

				for i,v in pairs(players) do
					v.hasBall = false
				end
				self.hasBall = true

				game.teamPossesion = self.team
			elseif v.other.type == "player" then
				if v.other.hasBall and v.other.team ~= self.team then 
					self:shootDirection(self.direction, v.other.id)
					v.other.stunTimer = 0.7
				end

				if v.other.x == self.x and v.other.y == self.y then -- Push player away if they are in eachother
					if self.x < pitch.width/2 then 
						v.other.x = v.other.x + 120
						v.other.y = v.other.y + 120
					else
						v.other.x = v.other.x - 120
						v.other.y = v.other.y - 120
					end
				end
			elseif v.other.type == "zombie" then 
				if self.damageIndicator <= 0 and v.other.state == "roaming" then 
					self.damageIndicator = 1.5
					self.health = self.health - 1
					love.audio.play(hurtSound)
					if self.health < 0 then 
						self:die()
					end
				end
			end 
		end
	end 

	--Boundary
	if self.x < 0 then  
		self.x = 0 
	elseif self.x + self.width > pitch.width then 
		self.x = pitch.width - self.width
	end
	if self.y < 0  then 
		self.y = 0 
	elseif self.y + self.height > pitch.height then 
		self.y = pitch.height - self.height
	end
end

--This is a long one
function player:movementAI(dt)
	if not self.beingControlled and not self.hasAId then 
		self.lastx = self.x
		self.lastY = self.y
		if game.teamPossesion == self.team then -- When ball is in team possesion

			if self.hasBall then -- If has ball then go towards goal and go into the pitch when near goal.
				if self.y > 0 then 
					self.y = self.y - self.speed*dt
					if self.y < 120 then 
						if self.x <= 175 then 
							self.x = self.x + self.speed*dt
						elseif self.x >= 275 then 
							self.x = self.x - self.speed*dt
						end
					end 
				end
				if self.y < 75 then --If in range to shoot decide if to do so.
					self:decideShoot()
				end

			else
				if self.team == 1 then 	
					if ball.y > pitch.height/2 then -- Make player run up to attack
						if self.y < ball.y + self.ballOffset then 
							self.y = self.y + self.speed*dt
							if self.y > ball.y + self.ballOffset then 
								self.y = ball.y + self.ballOffset 
							end
						else
							self.y = self.y - self.speed*dt
							if self.y < ball.y + self.ballOffset then 
								self.y = ball.y + self.ballOffset
							end
						end
					end
				elseif self.team == 2 then 
					if ball.y < pitch.height/2 then -- Make player run up to attack
						if self.y < ball.y + self.ballOffset then 
							self.y = self.y + self.speed*dt
							if self.y > ball.y + self.ballOffset then 
								self.y = ball.y + self.ballOffset 
							end
						else
							self.y = self.y - self.speed*dt
							if self.y < ball.y + self.ballOffset then 
								self.y = ball.y + self.ballOffset
							end
						end
					end
				end
			end

		else -- Ball in enemy possesion
			if self.team == 1 then -- Run back when in enemy half and they have ball in friendly half
				if self.y > 100 and ball.y < pitch.height / 2 then
					if game.teamPossesion == 2 then 
						self.y = self.y - self.speed*dt
					end
				end  
			else
				if twoClosest[1][1] == self.id then -- If the closest to the ball is an enemy then go in for the tackle
					self:goTowardsBall(dt, 0.75)
				else
					if self.y < 500 and ball.y > pitch.height /2 then
						self.y = self.y + self.speed*dt
					end 
				end 
			end
		end
	end
end

function player:shootingAI()
	if #zombies > 0 and zombies[self.arm.closest] then 
		if zombies[self.arm.closest].closest[2] <= self.shootingRange and self.bulletCooldown <= 0 then --If closest zombie is in range to shoot
			local angle = math.atan2((zombies[self.arm.closest].y - self.y), (zombies[self.arm.closest].x - self.x))

			bullet:new(self.x, self.y, angle)
			self.bulletCooldown = 1.5
			love.audio.play(shootSound)
		end
	end
end


--This is also a long one
function doPlayerAI(dt) -- Ai for only certain players
		twoClosest = {{4, 10000},{2, 10000}} -- The two closest players to the ball (that are not controlled by player)
		for i, v in pairs(players) do
			if v.id ~= controller.currentPlayer and not v.dead then 
				local distanceX = 0
				local distanceY = 0

				if v.x > ball.x then 
					distanceX = v.x - ball.x
				else
					distanceX = ball.x - v.x
				end 
				if v.y > ball.y then 
					distanceY = v.y - ball.y
				else
					distanceY = ball.y - v.y
				end

				--How far away the player is from the ball
				local distanceToBall = distanceX + distanceY
				if controller.currentPlayer ~= v.id then -- Player is AI controlled 
					if distanceToBall < twoClosest[2][2] then --Arange in distance to ball (from shortest to longest)
						if distanceToBall < twoClosest[1][2] then 
							twoClosest[2] = twoClosest[1]
							twoClosest[1] = {v.id, distanceToBall}
						end
					end
				end
			end
		end

	if game.teamPossesion == 0 then --No team is in possesion (Ball is loose)
		for i,v in pairs(twoClosest) do --Move 2 closest players towards ball
			if players[v[1]] and not players[v[1]].dead and players[v[1]].stunTimer <= 0 then 
				players[v[1]].lastx = players[v[1]].x
				players[v[1]].lastY = players[v[1]].y
				players[v[1]].hasAId = true
				players[v[1]]:goTowardsBall(dt)
			end
			if i == 1 and game.team1Players == 1 then
				break
			end
		end
	end
end


function player:decideShoot()
	if self.hasBall and self.team == 2 then 
		if math.random(1, 20) == 5 then -- There is a 1 in 60 chance player shoots every frame.
			if self.x < 200 then
				self:shootDirection(3, self.id)
			elseif self.x > 250 then 
				self:shootDirection(1, self.id)
			else
				self:shootDirection(2, self.id)
			end
		end
	end
end

function player:shootDirection(dir, shooter)
	if dir == 1 then 
		ball.xvel = -500
		ball.yvel = -500
	elseif dir == 2 then 
		ball.yvel = -500
	elseif dir == 3 then 
		ball.xvel = 500
		ball.yvel = -500
	elseif dir == 4 then 
		ball.xvel = 500
	elseif dir == 5 then
		ball.xvel = 500
		ball.yvel = 500
	elseif dir == 6 then 
		ball.yvel = 500
	elseif dir == 7 then 
		ball.xvel = -500
		ball.yvel = 500
	elseif dir == 8 then 
		ball.xvel = -500
	end

	ball.isStuck = false
	ball:collisionTimerStart()
	if players[shooter] then --This is sketchy
		players[shooter].hasBall = false
	end
	game.teamPossesion = 0 

	love.audio.play(passSound)
end

function player:goTowardsBall(dt, speedmultiplier)
	local speedmultiplier = speedmultiplier or 1
	local speedM = self.speed* speedmultiplier

	if self.x > ball.x then 
		self.x = self.x - speedM*dt
		if self.x < ball.x then 
			self.x = ball.x
		end
	else
		self.x = self.x + speedM*dt
		if self.x > ball.x then 
			self.x = ball.x
		end
	end
	if self.y > ball.y then 
		self.y = self.y - speedM*dt
		if self.y < ball.y then 
			self.y = ball.y
		end
	else
		self.y = self.y + speedM*dt
		if self.y > ball.y then 
			self.y = ball.y
		end
	end
end

function player:die()
	if self.hasBall then 
		ball.isStuck = false
		ball.stuckTo = players[1] --This doesn't matter
	end


	players[self.id] = nil
	collisionWorld:remove(self)
	self.dead = true

	
	--error(#players)

	if self.team == 1 then 
		game.team1Players = game.team1Players - 1
	else
		game.team2Players = game.team2Players - 1
	end
	
	if game.team1Players == 0 or game.team2Players == 0 then 
		game:endGame()
	else
		controller:switchToRandom()
	end
end


--This used to be exclusivly player. Thats why it's here
function decideDirection(object)

	if object.lastX ~= object.x then 
		if object.lastX > object.x then 
			object.left = true
			object.right = false 
		elseif object.lastX < object.x then 
			object.right = true
			object.left = false
		end
	else
		object.left = false
		object.right = false
	end 

	if object.lastY ~= object.y then 
		if object.lastY > object.y then 
			object.up = true
		elseif object.lastY < object.y then 
			object.down = true
			object.up = false
		end
	else
		object.up = false
		object.down = false
	end



	--    1 2 3
	--    8   4
	--    7 6 5 

	if object.up then 
		if object.left then
			object.direction = 1
		elseif object.right then 
			object.direction = 3
		else
			object.direction = 2
		end
		object.currentQuad = 5
	elseif object.down then 
		if object.left then 
			object.direction = 7
			object.currentQuad = 1
		elseif object.right then 
			object.direction = 5
			object.currentQuad = 2
		else
			object.direction = 6
			object.currentQuad = 1
		end
	elseif object.right then 
		object.direction = 4
		object.currentQuad = 4
	elseif object.left then 
		object.direction = 8
		object.currentQuad = 3
	end
end