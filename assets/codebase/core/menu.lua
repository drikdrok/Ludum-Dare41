menu = class("menu")

function menu:initialize()
	self.state = "mainMenu"

	self.mainMenuImage = love.graphics.newImage("assets/gfx/misc/menu.png")

	self.mouseX = 0
	self.mouseY = 0

	self.highlightedText = {"", 30, 300}

	self.zombieLevel = "Few"

end

function menu:update()
	self.mouseX, self.mouseY = love.mouse.getPosition()	

	self:highlight()
end

function menu:draw()
	if self.state == "mainMenu" then 
		love.graphics.draw(self.mainMenuImage)

		game:fontSize(30)
		love.graphics.print("Start", 30, 300)
		love.graphics.print("About", 30, 350)

		love.graphics.print("Zombies: "..self.zombieLevel, 30, 600)
		love.graphics.print("Exit", 30, 650)

		love.graphics.setColor(0,0,1)
		love.graphics.print(self.highlightedText[1], self.highlightedText[2], self.highlightedText[3]) --THIS IS TERRIBLE NEVER DO THIS AGAIN
		love.graphics.setColor(1,1,1)
	elseif self.state == "about" then 
		love.graphics.setColor(168/255, 8/255, 8/255)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(1,1,1)

		game:fontSize(40)
		love.graphics.print("About", 10, 10)
		game:fontSize(25)
		love.graphics.print("Soccer Zombie Shootout was made in 48 hours for Ludum Dare 41.", 10, 130)
		love.graphics.print("Everything was made within the timeframe. Sound effects were generated with BFXR", 10, 170)
		love.graphics.print("Christian Schwenger 2018", 10, 210)
		game:fontSize(50)
		love.graphics.print("THANKS FOR PLAYING!", 10, 280)

		game:fontSize(30)
		love.graphics.print("Controls:", 10, 500)
		game:fontSize(25)
		love.graphics.print("Move: WASD", 10, 540)
		love.graphics.print("Switch Player: F", 10, 570)
		love.graphics.print("Shoot/Pass: SPACE", 10, 600)
		love.graphics.print("Fire Gun: LEFT MOUSE BUTTON", 10, 630)



		game:fontSize(30)
		love.graphics.print("Back", 1150, 650)
		love.graphics.setColor(0,0,1)
		love.graphics.print(self.highlightedText[1], self.highlightedText[2], self.highlightedText[3]) --DAMNIT YOU DID IT AGAIN
		love.graphics.setColor(1,1,1)


	end
end

--I should really use a button library but what ever
function menu:click()
	if self.highlightedText[1] == "Start" then 
		game:reset()
		love.audio.play(buttonSound)
	elseif self.highlightedText[1] == "About" then 
		self.state = "about"
		love.audio.play(buttonSound)
	elseif self.highlightedText[1] == "Zombies:" then

		if self.zombieLevel == "Few" then 
			zombieInterval = 3.5
			self.zombieLevel = "Medium"
		elseif self.zombieLevel == "Medium" then 
			zombieInterval = 2
			self.zombieLevel = "Many"
		elseif self.zombieLevel == "Many" then 
			zombieInterval = 100000
			self.zombieLevel = "None" 
		elseif self.zombieLevel == "None" then
			zombieInterval = 5
			self.zombieLevel = "Few"
		end 	
		love.audio.play(buttonSound)
	elseif self.highlightedText[1] == "Exit" then
		love.event.quit()
		love.audio.play(buttonSound)
	elseif self.highlightedText[1] == "Back" then
		self.state = "mainMenu"
		love.audio.play(buttonSound)
	end
end

function menu:highlight()
	if self.state == "mainMenu" then 
		if self.mouseX > 5 and self.mouseX < 150 and self.mouseY > 300 and self.mouseY < 340 then
			self.highlightedText = {"Start", 30, 300}
		elseif self.mouseX > 5 and self.mouseX < 150 and self.mouseY > 350 and self.mouseY < 390 then 
			self.highlightedText = {"About", 30, 350}
		elseif self.mouseX > 5 and self.mouseX < 150 and self.mouseY > 600 and self.mouseY < 640 then 
			self.highlightedText = {"Zombies:", 30, 600}
		elseif self.mouseX > 5 and self.mouseX < 150 and self.mouseY > 650 and self.mouseY < 690 then 
			self.highlightedText = {"Exit", 30, 650}
		else
			self.highlightedText = {"", 0, 0}
		end
	elseif self.state == "about" then 
		if self.mouseX > 1150 and self.mouseX < 1280 and self.mouseY > 650 and self.mouseY < 690 then
			self.highlightedText = {"Back", 1150, 650}
		else
			self.highlightedText = {"", 0, 0}
		end
	end
end