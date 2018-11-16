controller = class("controller")

function controller:initialize()
	self.currentPlayer = 1 

	players[self.currentPlayer].beingControlled = true

	self.team = 1

	self.bulletCooldown = 0
end

function controller:update(dt)
	if not players[self.currentPlayer] then 
		self:switchToRandom()
	end

	if players[self.currentPlayer] then 

		self:move(dt)
		self:shoot()

		self.bulletCooldown = self.bulletCooldown - dt

		if love.mouse.isDown(1) then 
			self:fireGun()
		end 
	end
end


function controller:move(dt)
	if players[self.currentPlayer] then 
		if love.keyboard.isDown("w") then 
			players[self.currentPlayer].y = players[self.currentPlayer].y - players[self.currentPlayer].speed*dt
			players[self.currentPlayer].up = true
		else
			players[self.currentPlayer].up = false
		end
		if love.keyboard.isDown("a") then 
			players[self.currentPlayer].x = players[self.currentPlayer].x - players[self.currentPlayer].speed*dt
			players[self.currentPlayer].left = true
		else
			players[self.currentPlayer].left = false
		end
		if love.keyboard.isDown("s") then 
			players[self.currentPlayer].y = players[self.currentPlayer].y + players[self.currentPlayer].speed*dt
			players[self.currentPlayer].down = true
		else
			players[self.currentPlayer].down = false
		end
		if love.keyboard.isDown("d") then 
			players[self.currentPlayer].x = players[self.currentPlayer].x + players[self.currentPlayer].speed*dt
			players[self.currentPlayer].right = true
		else
			players[self.currentPlayer].right = false
		end



		--Decide quad. This is temporary until animations!

		if players[self.currentPlayer].up then 
			if players[self.currentPlayer].left then
				players[self.currentPlayer].direction = 1
			elseif players[self.currentPlayer].right then 
				players[self.currentPlayer].direction = 3
			else
				players[self.currentPlayer].direction = 2
			end
			players[self.currentPlayer].currentQuad = 5
		elseif players[self.currentPlayer].down then 
			if players[self.currentPlayer].left then 
				players[self.currentPlayer].direction = 7
				players[self.currentPlayer].currentQuad = 1
			elseif players[self.currentPlayer].right then 
				players[self.currentPlayer].direction = 5
				players[self.currentPlayer].currentQuad = 2
			else
				players[self.currentPlayer].direction = 6
				players[self.currentPlayer].currentQuad = 1
			end
		elseif players[self.currentPlayer].right then 
			players[self.currentPlayer].direction = 4
			players[self.currentPlayer].currentQuad = 4
		elseif players[self.currentPlayer].left then 
			players[self.currentPlayer].direction = 8
			players[self.currentPlayer].currentQuad = 3
		end
	end

	--    1 2 3
	--    8   4
	--    7 6 5 

end

function controller:shoot()
	if love.keyboard.isDown("space") and players[self.currentPlayer].hasBall then 
		
		players[self.currentPlayer]:shootDirection(players[self.currentPlayer].direction, self.currentPlayer)

	end
end

function controller:switchPlayer(n)
	if players[self.currentPlayer] then 
		players[self.currentPlayer].beingControlled = false
	end
	
	self.currentPlayer = n
	if players[self.currentPlayer] then 
		players[self.currentPlayer].beingControlled = true
	end
end

function controller:switchToRandom()
	if game.team1Players > 1 then 
		local n = math.random(1, #players)
		while players[n] == nil or n == controller.currentPlayer or players[n].team == 2 do
			n = math.random(1, #players)
		end
		self:switchPlayer(n)
	else
		for i,v in pairs(players) do
			if v.team == 1 then 
				self:switchPlayer(v.id)
			end
		end
	end
end

function controller:fireGun()
	if self.bulletCooldown <= 0 then 
		local mouseX, mouseY = camera:mousePosition()

		local angle = math.atan2((mouseY - players[self.currentPlayer].y), (mouseX - players[self.currentPlayer].x))

		bullet:new(players[self.currentPlayer].x, players[self.currentPlayer].y, angle)
		self.bulletCooldown = 0.5
		love.audio.play(shootSound)
	end
end

function controller:reset()
	self.currentPlayer = 1 

	players[self.currentPlayer].beingControlled = true

	self.bulletCooldown = 0
end
