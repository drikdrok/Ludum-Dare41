arm = class("arm")

function arm:initialize(team, playerID)
	--self.x = 11
	--self.y = 8
	self.xMotionOffset = 0
	self.yMotionOffset = 0

	self.width = 2
	self.height = 10

	self.angle = 0

	self.image = love.graphics.newImage("assets/gfx/arms/arm"..team..".png")

	self.playerID = playerID

	self.closest = 0

end

function arm:update()
	if players[self.playerID] then 
		self.x = players[self.playerID].x
		self.y = players[self.playerID].y + 9 -- +9 is the offset for every direction

		local direction = players[self.playerID].direction

		if direction == 1 or direction == 2 or direction == 3 then 
			self.x = self.x + 5
		elseif direction == 5 or direction == 6 or direction == 7 then 
			self.x = self.x + 11
		elseif direction == 8 or direction == 4 then 
			self.x = self.x + 8
		end
	end

	--    1 2 3
	--    8   4
	--    7 6 5 
end

function arm:draw()
	if self.playerID == controller.currentPlayer then 
		local mouseX, mouseY = camera:mousePosition()
		self.angle = math.atan2((mouseY - players[controller.currentPlayer].y), (mouseX - players[controller.currentPlayer].x)) + math.pi/-2

		if mouseX > players[self.playerID].x + players[self.playerID].width / 2 then 
			n = 1
		else
			n = -1
		end  
		love.graphics.draw(self.image, self.x, self.y, self.angle, n, 1)
	else
		local n = self:decideAngle()
		love.graphics.draw(self.image, self.x, self.y, self.angle, n, 1)
	end
end

function arm:decideAngle()
	if players[self.playerID] and players[controller.currentPlayer] and not players[self.playerID].dead then 
		self.closest =  0
		self.angle = 0
		local n = 1

		for i,v in pairs(zombies) do
			if v.closest[1] == self.playerID then -- If a zombie has the arms player as the closest player to it
				self.closest = v.id

				self.angle = math.atan2((v.y - players[controller.currentPlayer].y), (v.x - players[controller.currentPlayer].x)) + math.pi/-2

				if v.x > players[self.playerID].x + players[self.playerID].width / 2 then 
					n = 1
				else
					n = -1
				end  
			end
		end
	end
end

--I'll try ceiling. That's a good trick!
-- :(
--I'll try offsetting. That's a good trick!
-- :(
--Updateing arm in draw function worked :)