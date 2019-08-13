os.execute("clear")
local words = {
  "garbage",
  "a weiner",
  "backwards",
  "simple",
  "dumb dumb",
  "shlimpo",
  "krill : )",
  "lovely",
  "good company",
  "gentle",
  "unwanted",
  "misplaced"
}

while true do  
  print("\n\n\n\n        you are " .. words[math.random(1,#words)])
  os.execute("sleep 2")
  os.execute("clear")
end