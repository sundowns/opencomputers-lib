local component = require("component")
local rs = component.redstone
local colours = require("colors")
local sides = require("sides")

while true do
  rs.setBundledOutput(sides.back, colours.green, 100)
end