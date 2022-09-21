-- https://youtu.be/I549C6SmUnk?t=17375
local love = require "love"
local enemy = require "Enemy"
local button = require "Button"

math.randomseed(os.time())

local game = {
  state = {
    menu = true,
    paused = false,
    running = false,
    ended = false
  },
  points = 0,
  levels = {15, 30, 60, 120}
}

local player = {
  radius = 20,
  x = 30,
  y = 30
}

local buttons = {
  menu_state = {}
}

local enemies = {}

local function startNewGame()
  game.state["menu"] = false
  game.state["running"] = true

  game.points = 0

  enemies = { enemy(1) }
end

function love.mousepressed(x, y, button, istouch, presses)
  if not game.state["running"] then
    if button == 1 then
      if game.state ["menu"] then
        for index in pairs(buttons.menu_state) do
          buttons.menu_state[index]:checkPressed(x, y, player.radius)
        end
      end
    end
  end
end

function love.load()
  love.window.setTitle("Save the ball")
  love.mouse.setVisible(false)

  buttons.menu_state.play_game = button("Play Game", startNewGame, nil, 120, 40)
  buttons.menu_state.settings = button("Settings", nil, nil, 120, 40)
  buttons.menu_state.exit_game = button("Exit Game", love.event.quit, nil, 120, 40)

  table.insert(enemies, 1, enemy())
end


function love.update(dt)
  player.x, player.y = love.mouse.getPosition()

  if game.state["running"] then
    for i=1, #enemies do
      enemies[i]:move(player.x, player.y)
    end
    game.points = game.points + dt --one point per second
  end

end

function love.draw()
  love.graphics.printf(
    "FPS: " .. love.timer.getFPS(),
    love.graphics.newFont(16),
    10,
    love.graphics.getHeight() - 30,
    love.graphics.getWidth()
  )
  if game.state["running"] then
    love.graphics.printf(math.floor(game.points), love.graphics.newFont(24), 0, 10, love.graphics.getWidth(), "center")

    for i=1, #enemies do
      enemies[i]:draw()
    end

    love.graphics.circle("fill", player.x, player.y, player.radius)
  elseif game.state["menu"] then
    buttons.menu_state.play_game:draw(10, 20, 17, 10)
    buttons.menu_state.settings:draw(10, 70, 17, 10)
    buttons.menu_state.exit_game:draw(10, 120, 17, 10)
  end

  if not game.state["running"] then
    love.graphics.circle("fill", player.x, player.y, player.radius / 2)
  end
end