pitch = class("lua")

local pitchImage = love.graphics.newImage("assets/gfx/pitches/pitch1.png")
local goalImage1 = love.graphics.newImage("assets/gfx/goals/goal1.png")
local goalImage2 = love.graphics.newImage("assets/gfx/goals/goal2.png")

function pitch:initialize()
	self.width = pitchImage:getWidth()
	self.height = pitchImage:getHeight()


	local x = self.width/2 - goalImage1:getWidth()/2 + 3 -- +3 is crossbar and post
	local y = -goalImage1:getHeight() + 3 + 33/2+ 5
	local goal1Collision = {x = x, y = y, width = 97, height = 33/2, type = "goal", team = 1}

	collisionWorld:add(goal1Collision,  goal1Collision["x"],  goal1Collision["y"], goal1Collision["width"], goal1Collision["height"])

	local x = self.width/2 - goalImage2:getWidth()/2
	local y = self.height-5
	local goal2Collision = {x = x, y = y, width = 97, height = 40/2,  type = "goal", team = 2}

	collisionWorld:add(goal2Collision,  goal2Collision["x"],  goal2Collision["y"], goal2Collision["width"], goal2Collision["height"])


	self.background = love.graphics.newImage("assets/gfx/backgrounds/background.png")

end

function pitch:update(dt)

end

function pitch:draw()
	love.graphics.draw(self.background, -515, -531)
	love.graphics.draw(pitchImage, 0, 0 )
	love.graphics.draw(goalImage1, self.width/2 - goalImage1:getWidth()/2, -goalImage1:getHeight())
	love.graphics.draw(goalImage2, self.width/2 - goalImage2:getWidth()/2, self.height - goalImage2:getHeight()/2)


end