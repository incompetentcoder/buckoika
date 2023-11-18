function love.load()
  setup()
  love.window.setVSync(1)
end

function love.mousepressed(x,y,button,istouch,presses)
  if button==1 then
    if love.timer.getTime() - since > 2 then
      createball(pos,50,nextball)
      nextball=startsize*math.pow(increase,math.random(0,2))
      since=love.timer.getTime()
    end
  end
end
  
function love.keypressed(key,scancode,isrepeat)
  if key == "r" then
    World:destroy()
    setup()
  end
  if key == "escape" then
    love.event.quit(0)
  end
end

function love.update(dt)
-- Update the physics World with the specified time step (dt)
  pos=love.mouse.getX()
  if pos < 250 then
    pos=250
  elseif pos > 550 then
    pos=550
  end
  for ii,i in ipairs(ballstoremove) do
    if Balls[i] then
      Balls[i].body:destroy()
      Balls[i]=nil
      score=score+1
    end
  end
  ballstoremove={}
  for ii,i in ipairs(ballstocreate) do
    createball(i.x,i.y,i.size)
  end
  ballstocreate={}
  for ii,i in pairs(Balls) do
    if i.body:getY() > 700 then
      gameover=1
      break
    end
  end
  if gameover == 1 then
    World:destroy()
    setup()
  end
  World:update(dt)

  if love.keyboard.isDown("right") then
    for ii,i in pairs(Balls) do
      i.body:applyForce(100, 0)
    end
  
  elseif love.keyboard.isDown("left") then
    for ii,i in pairs(Balls) do
      i.body:applyForce(-100, 0)
    end
  end
end

function love.draw()
  for ii,i in pairs(Balls) do
    love.graphics.draw(bucko,i.body:getX(), i.body:getY(), i.body:getAngle(), i.shape:getRadius() / startsize, i.shape:getRadius() / startsize, offset, offset)
  end
  for ii,i in ipairs(Platforms) do
    love.graphics.polygon("line", i.body:getWorldPoints(i.shape:getPoints()))
  end
  love.graphics.draw(bucko,pos,50,0,nextball/startsize,nextball/startsize,offset,offset)
  love.graphics.print(Text.. tostring(score), 50, 10)
end

function beginContact(a, b, coll)
  local textA=a:getUserData()
  local textB=b:getUserData()
  if string.sub(textA,1,1) ~= "P" and string.sub(textB,1,1) ~= "P" then
    if Balls[textA].shape:getRadius() == Balls[textB].shape:getRadius() then
      local size = Balls[textA].shape:getRadius()
      size = size * increase
      local x1,y1,x2,y2 = coll:getPositions()
      table.insert(ballstoremove,textA)
      table.insert(ballstoremove,textB)
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
  Balls[tostring(balls)]=Ball
  balls=balls+1
end

function setup()
  World = love.physics.newWorld(0, 200, true)
  World:setCallbacks(beginContact, endContact, preSolve, postSolve)
  ballstocreate={}
  ballstoremove={}
  startsize=17
  increase=1.4
  balls=1
  score=0
  gameover=0
  bucko=love.graphics.newImage("Untitled.png")
  offset=bucko:getHeight() / 2
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
  for i=0,4,1 do
    createball(math.random(200,500),300,startsize*math.pow(increase,i))
  end
  nextball=startsize*math.pow(increase,math.random(0,2))
  since=love.timer.getTime()
  Text = "Buckoika \n R to reset \n Esc to quit \n LMB to drop \n Score:"	  -- we'll use this to put info Text on the screen later
end
  
  
