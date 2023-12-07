function love.load()
	love.filesystem.setIdentity("buckoika")
	if love.filesystem.getInfo("score") then
		hiscore = love.filesystem.read("score")
	else
		love.filesystem.write("score","0\n")
	end
	sizes={17,23,30,38,47,57,68,80,93,107,122,138,155,173,192,212}
	invertedsizes={}
	for a,b in ipairs(sizes) do
		invertedsizes[b]=a
	end
	startsize=17
	balls=1
	bucko={}
	for i=1,15 do
		bucko[i]=love.graphics.newImage(string.format("Untitled%d.png",i))
	end
	title=love.graphics.newImage("title.png")
	gover=love.graphics.newImage("gameover.png")
	offset=bucko[1]:getHeight() / 2
	since=love.timer.getTime()
	firsttime=1
	love.window.setVSync(1)
end

function love.mousepressed(x,y,button,istouch,presses)
	if firsttime==1 or gameover==1 then
		firsttime=0
		gameover=0
		if World then 
			World:destroy()
		end
		setup()
		return
	end
	if button==1 then
		if love.timer.getTime() - since > 0.5 then
			createball(pos,50,nextball)
			nextball=sizes[math.random(3)]
			since=love.timer.getTime()
		end
	end
end
	
function love.keypressed(key,scancode,isrepeat)
	if firsttime==1 or gameover==1 then
		firsttime=0
		gameover=0
		if World then
			World:destroy()
		end
		setup()
	end
	if key == "r" then
		World:destroy()
		setup()
	end
	if key == "escape" then
		if score then
			if hiscore then
				if score>tonumber(hiscore) then
					hiscore=score
				end
			end
		end
		love.filesystem.write("score",tostring(hiscore) .. "\n")
		love.event.quit(0)
	end
end

function love.update(dt)
-- Update the physics World with the specified time step (dt)
	if gameover==1 or firsttime==1 then
		return
	end
	World:update(dt)
	pos=love.mouse.getX()
	if pos < 250 then
		pos=250
	elseif pos > 550 then
		pos=550
	end
	for ii,i in ipairs(ballstoremove) do
	--	print(i[1],i[2],Balls[i[1]])
		if Balls[i[1]][i[2]] then
			score=score+invertedsizes[Balls[i[1]][i[2]].shape:getRadius()]
			Balls[i[1]][i[2]].body:destroy()
			Balls[i[1]][i[2]]=nil
		end
	end
	ballstoremove={}
	for ii,i in ipairs(ballstocreate) do
		createball(i.x,i.y,i.size)
	end
	ballstocreate={}
	for ii,i in pairs(Balls) do
		for iii,iiii in pairs(i) do
			if iiii.body:getY() > 700 or iiii.body:getY() < 20 then
				gameover=1
				return
			end
		end
	end
end

function love.draw()
	if gameover==1 then
		love.graphics.draw(gover,0,0)
		return
	end
	if firsttime==1 then
		love.graphics.draw(title,0,0)
		return
	end
	for i=1,19 do
		if Balls[i] then
			local img=bucko[i]
			for iii,iiii in pairs(Balls[i]) do
				love.graphics.draw(img,iiii.body:getX(), iiii.body:getY(), iiii.body:getAngle(), iiii.shape:getRadius() / startsize, iiii.shape:getRadius() / startsize, offset, offset)
			end
		end
	end
	for ii,i in ipairs(Platforms) do
		love.graphics.polygon("line", i.body:getWorldPoints(i.shape:getPoints()))
	end
	love.graphics.draw(bucko[invertedsizes[nextball]],pos,50,0,nextball/startsize,nextball/startsize,offset,offset)
	love.graphics.print(Text.. tostring(score), 50, 10)
	love.graphics.print("Hiscore: ".. tostring(hiscore), 550, 10)
end

function beginContact(a, b, coll)
	local textA=a:getUserData()
	local textB=b:getUserData()
	if string.sub(textA,1,1) ~= "P" and string.sub(textB,1,1) ~= "P" then
		if a:getShape():getRadius() == b:getShape():getRadius() then
			local size = sizes[invertedsizes[a:getShape():getRadius()]+1]
			local x1,y1,x2,y2 = coll:getPositions()
			table.insert(ballstoremove,{invertedsizes[a:getShape():getRadius()],textA})
			table.insert(ballstoremove,{invertedsizes[b:getShape():getRadius()],textB})
			local ball={}
			ball.x=x1
			ball.y=y1
			ball.size=size
			table.insert(ballstocreate,ball)
		end
	end	
end

function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end

function createball(x,y,radius)
	local Ball = {}
	Ball.body = love.physics.newBody(World, x, y, "dynamic")
	Ball.body:setMass(radius)
	Ball.shape = love.physics.newCircleShape(radius)
	Ball.fixture = love.physics.newFixture(Ball.body, Ball.shape)
	Ball.fixture:setUserData(tostring(balls))
	Ball.fixture:setRestitution(0.1)
	Ball.fixture:setFriction(0.1)
	if Balls[invertedsizes[radius]]==nil then
		Balls[invertedsizes[radius]]={}
	end
	Balls[invertedsizes[radius]][tostring(balls)]=Ball
-- print(invertedsizes[radius],tostring(balls))
	balls=balls+1
end

function setup()
	World = love.physics.newWorld(0, 200, true)
	ballstocreate={}
	ballstoremove={}
	if score then
		if hiscore then
			if score>tonumber(hiscore) then
				hiscore=score
			end
		end
	end
	if hiscore == nil then
		hiscore = 0
	end
	score=0
	gameover=0
	Platforms = {}
	local Platform={}
	Platform.body = love.physics.newBody(World, 400, 500, "static")
	Platform.shape = love.physics.newRectangleShape(400, 50)
	Platform.fixture = love.physics.newFixture(Platform.body, Platform.shape)
	Platform.fixture:setUserData("Platform")
	table.insert(Platforms,Platform)
	local Platform={}
	Platform.body = love.physics.newBody(World, 200, 300, "static")
	Platform.shape = love.physics.newRectangleShape(50, 400)
	Platform.fixture = love.physics.newFixture(Platform.body, Platform.shape)
	Platform.fixture:setUserData("Platform1")
	table.insert(Platforms,Platform)
	local Platform={}
	Platform.body = love.physics.newBody(World, 600, 300, "static")
	Platform.shape = love.physics.newRectangleShape(50, 400)
	Platform.fixture = love.physics.newFixture(Platform.body, Platform.shape)
	Platform.fixture:setUserData("Platform2")
	table.insert(Platforms,Platform)
	Balls = {}
	for i=1,4 do
		createball(math.random(250,550),math.random(50,400),sizes[math.random(4)])
	end
	nextball=sizes[math.random(3)]
	World:setCallbacks(beginContact, endContact, preSolve, postSolve)
	Text = "Buckoika \n R to reset \n Esc to quit \n LMB to drop \n Score:"	 -- we'll use this to put info Text on the screen later
end
	
	
