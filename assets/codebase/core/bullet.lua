bullet = class("bullet")
bullets = {}

function bullet:initialize(x, y, angle)
	self.x = x+4
	self.y = y+4
	self.width = 3
	self.height = 3

	self.angle = angle
	self.speed = 500

	self.dx = self.speed * math.cos(self.angle)
	self.dy = self.speed * math.sin(self.angle)

	self.type = "bullet"

	self.id = #bullets+1

	self.timer = 0
	self.lifeTime = 5 -- How many seconds until bullets should despawn

	collisionWorld:add(self, self.x, self.y, self.width, self.height)
	table.insert(bullets, self)
end

function bullet:update(dt)
	self.x = self.x + self.dx*dt --Movement
	self.y = self.y + self.dy*dt

	collisionWorld:update(self, self.x, self.y)


	self.timer = self.timer + dt

	if self.timer >= self.lifeTime then 
		bullets[self.id] = nil
		collisionWorld:remove(self)
	end
end

function bullet:draw()
	love.graphics.setColor(231/255, 255/255, 15/255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(1,1,1)
end

function updateBullets(dt)
	for i, v in pairs(bullets) do
		v:update(dt)
	end
end

function drawBullets()
	for i,v in pairs(bullets) do
		v:draw()
	end
end

function removeAllBullets()
	for i,v in pairs(bullets) do
		collisionWorld:remove(v)
	end
	bullets = {}
end