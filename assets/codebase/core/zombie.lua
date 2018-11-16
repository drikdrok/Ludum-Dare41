zombie = class("zombie")

zombies = {}

local zombieQuadSheet = love.graphics.newImage("assets/gfx/zombies/zombiesheet1.png")
local zombieQuadSheetWidth = zombieQuadSheet:getWidth()
local zombieQuadSheetHeight = zombieQuadSheet:getHeight()

local zombieQuads = {
	love.graphics.newQuad(0, 0, 17, 22, zombieQuadSheetWidth, zombieQuadSheetHeight),
	love.graphics.newQuad(17, 0, 17, 22, zombieQuadSheetWidth, zombieQuadSheetHeight),
	love.graphics.newQuad(17*2, 0, 17, 22, zombieQuadSheetWidth, zombieQuadSheetHeight),
	love.graphics.newQuad(17*3, 0, 17, 22, zombieQuadSheetWidth, zombieQuadSheetHeight),
	love.graphics.newQuad(17*4, 0, 17, 22, zombieQuadSheetWidth, zombieQuadSheetHeight),
}

local zombieSpawnerTimer = 0
zombieInterval = 5

local shadowImage = love.graphics.newImage("assets/gfx/misc/shadow.png")

function zombie:initialize()
	self.x = math.random(10, pitch.width-1)
	self.y = math.random(200, 400)

	self.lastX = self.x
	self.lastY = self.y

	self.width = 17
	self.height = 22

	self.state = "spawning"
	self.spawnTimer = 0
	self.canDie = false
	self.health = 3

	self.speed = 30

	self.type = "zombie"


	self.sheet = love.graphics.newImage("assets/gfx/zombies/zombiespawn1.png")
	self.grid = anim8.newGrid(17, 22, self.sheet:getWidth(), self.sheet:getHeight())

	self.spawningAnimation = anim8.newAnimation(self.grid("1-7", 1), 0.3)
	

	self.direction = 1
	self.currentQuad = 1

	self.up = false
	self.left = false
	self.down = false
	self.right = false

	self.closest = {4, 100000}

	self.id = #zombies+1


	table.insert(zombies, self)

	collisionWorld:add(self, self.x, self.y, self.width, self.height)
end

function zombie:update(dt)
	if self.state == "spawning" then 
		self:handleSpawning(dt)
	else
		self:movementAI(dt)
		decideDirection(zombies[self.id])
		self:collide(dt)

		collisionWorld:update(self, self.x, self.y)

		if self.health <= 0 then 
			zombies[self.id] = nil
			collisionWorld:remove(self)
		end

	end
end



function zombie:draw()
	if self.state == "spawning" then 
		self.spawningAnimation:draw(self.sheet, self.x, self.y)
	else
		local offset = 2 -- This could be better. Don't have time to improve
		if self.currentQuad == 1 or self.currentQuad == 2 then 
			offset = 3
		end

		love.graphics.draw(shadowImage, self.x+offset, self.y + 15)	
		love.graphics.draw(zombieQuadSheet, zombieQuads[self.currentQuad], self.x, self.y)
	end
end



function zombie:handleSpawning(dt)
	self.spawningAnimation:update(dt)
	self.spawnTimer = self.spawnTimer + dt

	if self.spawnTimer >= 7*0.3 then 
		self.state = "roaming"
	end 
end

function zombie:movementAI(dt)
	self.lastx = self.x
	self.lastY = self.y

	self:findClosestPlayer()


	--Go towards closest player
	if players[self.closest[1]] then 
		if self.x < players[self.closest[1]].x then
			self.x = self.x + self.speed*dt
			if self.x > players[self.closest[1]].x then 
				self.x = players[self.closest[1]].x
			end
		elseif self.x > players[self.closest[1]].x then 
			self.x = self.x - self.speed*dt
			if self.x < players[self.closest[1]].x then 
				self.x = players[self.closest[1]].x 
			end
		end
		if self.y < players[self.closest[1]].y then
			self.y = self.y + self.speed*dt
			if self.y > players[self.closest[1]].y then 
				self.y = players[self.closest[1]].y
			end
		elseif self.y > players[self.closest[1]].y then 
			self.y = self.y - self.speed*dt
			if self.y < players[self.closest[1]].y then 
				self.y = players[self.closest[1]].y 
			end
		end
	end
end

function zombie:collide(dt)
	local actualX, actualY, cols, len = collisionWorld:check(self, self.x, self.y)
	if #cols > 0 then 
		for i,v in pairs(cols) do 
			if v.other.type == "bullet" then 
				self.health = self.health - 1
				
				--Destory bullet			
				bullets[v.other.id] = nil
				collisionWorld:remove(v.other)
			end
		end
	end
end


function zombie:findClosestPlayer()
	for i, v in pairs(players) do
		local distanceX = 0
		local distanceY = 0

		if v.x > self.x then 
			distanceX = v.x - self.x
		else
			distanceX = self.x - v.x
		end 
		if v.y > self.y then 
			distanceY = v.y - self.y
		else
			distanceY = self.y - v.y
		end

		--How far away the player is from the zombie
		local distance = distanceX + distanceY
		if distance < self.closest[2] then
			self.closest = {v.id, distance}
		end
	end
end


function updateZombies(dt)
	for i,v in pairs(zombies) do 
		v:update(dt)
	end

	zombieSpawnerTimer = zombieSpawnerTimer + dt

	if zombieSpawnerTimer >= zombieInterval then 
		zombie:new()
		zombieSpawnerTimer = 0
	end

end

function drawZombies()
	for i,v in pairs(zombies) do
		v:draw()
	end
end


function removeAllZombies()
	for i,v in pairs(zombies) do
		collisionWorld:remove(v)
	end
	zombies = {}
	zombieSpawnerTimer = 0 
end