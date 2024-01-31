-- // Credits \\
-- TotalHorizons / @0horizon
-- MIT License

-- // Variables \\
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local DSS = game:GetService("DataStoreService")
local DB = DSS:GetDataStore("XP")
local Config = require(script.Configuration)

-- // Functions \\
local GetLevel = function(Player: Player)
	local XP = Player:WaitForChild("leaderstats").XP.Value
	local Level = (1 + math.sqrt(1 + 8 * XP / 50)) / 2
	return Level
end

local LoadData = function(Player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player

	local Level = Instance.new("IntValue")
	Level.Name = "Level"
	Level.Parent = leaderstats
	
	local XP = Instance.new("IntValue")
	XP.Name = "XP"
	XP.Parent = leaderstats
	
	Level.Value = GetLevel(Player)
	
	XP:GetPropertyChangedSignal("Value"):Connect(function()
		Level.Value = GetLevel(Player)
	end)
end

local SaveData = function(Player: Player)
	DB:SetAsync("XP_"..Player.UserId, Player.leaderstats.XP.Value)
end

local Increment = function(Player: Player)
	while task.wait(1) do
		if Player.MembershipType == Enum.MembershipType.Premium then
			Player.leaderstats.XP.Value += 2
		else
			Player.leaderstats.XP.Value += 1
		end
	end
end

local Reward = function(Player: Player)
	local Level = Player:WaitForChild("leaderstats").Level.Value
	for Key, Value in pairs(Config) do
		if Key <= Level then
			for _, v in pairs(Value) do
				local Tool = ServerStorage:FindFirstChild(v):Clone()
				Tool.Parent = Player.Backpack
			end
		end
	end
end

-- // Code \\
Players.PlayerAdded:Connect(function(Player: Player)
	LoadData(Player)
	coroutine.wrap(Increment)(Player)
	
	Player.CharacterAdded:Connect(function(char: Model)
		Reward(Player)
	end)
end)

Players.PlayerRemoving:Connect(SaveData)
