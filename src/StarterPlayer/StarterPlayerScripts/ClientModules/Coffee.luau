-- Coffee prompts on my screen (Features.Coffee — the server's CoffeeService decides everything): the customers'
-- "Give coffee" only while I hold a cup, the coffee maker's "Pour coffee" only while I don't. Local Enabled only —
-- the server never changes these prompts' Enabled (it removes a customer's once they have their coffee).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Coffee = {}

local player = Players.LocalPlayer

local function holding(): boolean
	return player:GetAttribute("HoldingCoffee") == true
end

-- coffee opens once my tutorial is done (the server checks the same: CoffeeService.open)
local function open(): boolean
	return ((player:GetAttribute("Tut") :: number?) or 4) >= 4 or player:GetAttribute("TutSkip") == true
end

local function fit(p: Instance)
	if p:IsA("ProximityPrompt") then
		if p.Name == "CoffeePrompt" then
			p.Enabled = holding()
		elseif p.Name == "PourPrompt" then
			p.Enabled = open() and not holding()
		end
	end
end

function Coffee.start()
	if not Config.feature("Coffee") then
		return
	end
	local function all()
		for _, d in workspace:GetDescendants() do
			fit(d)
		end
	end
	workspace.DescendantAdded:Connect(fit)
	player:GetAttributeChangedSignal("HoldingCoffee"):Connect(all)
	player:GetAttributeChangedSignal("Tut"):Connect(all)
	player:GetAttributeChangedSignal("TutSkip"):Connect(all)
	all()
end

return Coffee
