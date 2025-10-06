(function()
    repeat wait() until game:IsLoaded()

    local WebSocketURL = "ws://127.0.0.1:51948" -- поменяй порт если ты его поменял в питоне


    local Players = game:GetService("Players")

	-- anti-kick / thanks to fractal hub for bypass
	hookfunction(isfunctionhooked, function(func) if func == tick then return false end end)
    local origTick = getfenv()["tick"]
    getfenv()["tick"] = function() return math.huge end
    hookfunction(tick, function() return math.huge end)

    -- lagger bypass (thanks to fractal hub)
    for _, player in pairs(Players:GetPlayers()) do
        player.CharacterAdded:Connect(function()
            player:ClearCharacterAppearance()
        end)

        if player.Character then player:ClearCharacterAppearance() end
    end
    Players.PlayerAdded:Connect(function(player)
        if player.Character then player:ClearCharacterAppearance() end
        player.CharacterAdded:Connect(function()
            player:ClearCharacterAppearance()
        end)
    end)


    local function prints(str)
        print("[AutoJoiner]: " .. str)
    end


    local function findTargetGui()
		local coreGui = game:GetService("CoreGui")

		for _, gui in ipairs(coreGui:GetChildren()) do
			if gui:IsA("ScreenGui") then
				local mainFrame = gui:FindFirstChild("MainFrame")
				if mainFrame and mainFrame:FindFirstChild("ContentContainer") then
					local contentContainer = mainFrame.ContentContainer
					local tabServer = contentContainer:FindFirstChild("TabContent_Server")
					if tabServer then
						return tabServer
					end
				end
			end
		end
		return nil
	end

    local function setJobIDText(targetGui, text)
		if not targetGui then return end

		local inputFrame = targetGui:FindFirstChild("Input")
		local textBox = inputFrame:FindFirstChildOfClass("TextBox")

        textBox.Text = text
        firesignal(textBox.FocusLost)

        prints('Textbox updated: ' .. text .. ' (10m+ bypass)')
		return origTick()
	end

    local function clickJoinButton(targetGui)
		for _, buttonFrame in ipairs(targetGui:GetChildren()) do
			if buttonFrame:IsA("Frame") and buttonFrame.Name == "Button" then
				local textLabel = buttonFrame:FindFirstChildOfClass("TextLabel")
				local imageButton = buttonFrame:FindFirstChildOfClass("ImageButton")

				if textLabel and imageButton and textLabel.Text == "Join Job-ID" then
                    return imageButton
				end
			end
		end
		return nil
	end

    local function bypass10M(jobId)
        task.defer(function()
            local targetGui = findTargetGui()
            local start = setJobIDText(targetGui, jobId)
            local button = clickJoinButton(targetGui)

            getconnections(button.MouseButton1Click)[1]:Fire()
            prints(string.format("Join server clicked (10m+ bypass) | maybe real delay: %.5fs", origTick() - start))
        end)
    end


    local function justJoin(script)
        local func, err = loadstring(script)
        if func then
            local ok, result = pcall(func)
            if not ok then
                prints("Error while executing script: " .. result)
            end
        else
            prints("Some unexcepted error: " .. err)
        end
    end


    local function connect()
        while true do
            prints("Trying to connect to " .. WebSocketURL)
            local success, socket = pcall(WebSocket.connect, WebSocketURL)

            if success and socket then
                prints("Connected to WebSocket")
                local ws = socket

                ws.OnMessage:Connect(function(msg)
                    if not string.find(msg, "TeleportService") then
                        prints("Bypassing 10m server: " .. msg)
                        bypass10M(msg)
                    else
                        prints("Running the script: " .. msg)
                        justJoin(msg)
                    end
                end)

                local closed = false
                ws.OnClose:Connect(function()
                    if not closed then
                        closed = true
                        prints("The websocket closed, trying to reconnect...")
                        wait(1)
                        connect()
                    end
                end)

                break
            else
                prints("Unable to connect to websocket, trying again..")
                wait(1)
            end
        end
    end
    connect()
end)()
-- https://github.com/notasnek/roblox-autojoiner
-- please star my repo