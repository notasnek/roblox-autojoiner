(function()
    repeat wait() until game:IsLoaded()

    local WebSocketURL = "ws://127.0.0.1:51948" -- поменяй порт если ты его поменял в питоне


    local Players = game:GetService("Players")
	local CoreGui = game:GetService("CoreGui")

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


    --[[local function hasJoinButton(contentHolder) -- дерьмучий говнокод сорри мне лень умное что-то писать
        for _, child in ipairs(contentHolder:GetChildren()) do
            if child:IsA("Frame") then
                local btn = child:FindFirstChildOfClass("TextButton")
                if btn and btn.Text == "Join Job-ID" then
                    return true
                end
            end
        end
        return false
    end]]

    local function findTargetGui()
        return CoreGui.ChilliLibUI.MainBase.Frame:GetChildren()[3]:GetChildren()[6].Frame.ContentHolder
        -- ^ просто заебало все решил вот так вернуть весь путь :D
        --[[local mainBase = CoreGui:FindFirstChild("ChilliLibUI") 
                         and CoreGui.ChilliLibUI:FindFirstChild("MainBase")
        
        local baseFrame = mainBase:FindFirstChild("Frame")
        local scrollsContainer = nil
        for _, child in ipairs(baseFrame:GetChildren()) do
            if child:IsA("Frame") and child:FindFirstChildOfClass("ScrollingFrame") then
                scrollsContainer = child
                break
            end
        end

        for _, scrollFrame in ipairs(scrollsContainer:GetChildren()) do
            if scrollFrame:IsA("ScrollingFrame") then
                local innerFrame = scrollFrame:FindFirstChildOfClass("Frame")
                if innerFrame then
                    local contentHolder = innerFrame:FindFirstChild("ContentHolder")
                    if contentHolder and hasJoinButton(contentHolder) then
                        return contentHolder
                    end
                end
            end
        end

        return nil]]
    end

    local function setJobIDText(targetGui, text)
		if not targetGui then return end

        textBox = targetGui:GetChildren()[5].Frame.TextBox -- опять же все задолбало

        textBox.Text = text
        firesignal(textBox.FocusLost)

        prints('Textbox updated: ' .. text .. ' (10m+ bypass)')
        return origTick()

        --[[for _, frame in ipairs(targetGui:GetChildren()) do
            if frame:IsA("Frame") then
                local label = frame:FindFirstChildOfClass("TextLabel")
                if label and label.Text == "Job-ID Input" then
                    local innerFrame = frame:FindFirstChildOfClass("Frame")
                    local textBox = innerFrame and innerFrame:FindFirstChildOfClass("TextBox")
                    
                    if textBox then
                        textBox.Text = text
                        firesignal(textBox.FocusLost)

                        prints('Textbox updated: ' .. text .. ' (10m+ bypass)')
                        return origTick()
                    end
                end
            end
        end]]
	end

    local function clickJoinButton(targetGui)
        return targetGui:GetChildren()[6].TextButton -- задолбалооо
        --[[if not targetGui then return nil end
        for _, frame in ipairs(targetGui:GetChildren()) do
            if frame:IsA("Frame") then
                local button = frame:FindFirstChildOfClass("TextButton")
                if button and button.Text == "Join Job-ID" then
                    return button
                end
            end
        end
        return nil]]
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