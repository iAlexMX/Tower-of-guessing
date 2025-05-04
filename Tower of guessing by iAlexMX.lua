local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local floorsFolder = workspace:WaitForChild("Game"):WaitForChild("Floors")
local proximityDistance = 25

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DoorDetectorGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 120)
frame.Position = UDim2.new(0.5, -150, 0.85, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false
frame.Parent = screenGui

local doorNameLabel = Instance.new("TextLabel")
doorNameLabel.Size = UDim2.new(1, 0, 0.5, 0)
doorNameLabel.Position = UDim2.new(0, 0, 0, 0)
doorNameLabel.BackgroundTransparency = 1
doorNameLabel.TextColor3 = Color3.new(1, 1, 1)
doorNameLabel.TextScaled = true
doorNameLabel.Font = Enum.Font.GothamBold
doorNameLabel.Text = ""
doorNameLabel.Parent = frame

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(1, 0, 0.3, 0)
copyButton.Position = UDim2.new(0, 0, 0.5, 0)
copyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
copyButton.TextColor3 = Color3.new(1, 1, 1)
copyButton.TextScaled = true
copyButton.Font = Enum.Font.Gotham
copyButton.Text = "Copiar Nombre (o pulsa Q)"
copyButton.Parent = frame

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(1, 0, 0.2, 0)
creditLabel.Position = UDim2.new(0, 0, 0.8, 0)
creditLabel.BackgroundTransparency = 100
creditLabel.TextColor3 = Color3.new(1, 1, 1)
creditLabel.TextScaled = true
creditLabel.Font = Enum.Font.GothamSemibold
creditLabel.Text = "by iAlexMX"
creditLabel.TextSize = 12
creditLabel.Parent = frame

local closestDoor = nil
local scriptEnabled = true

local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    else
        warn("No se puede copiar al portapapeles en este dispositivo.")
    end
end

local function findClosestDoor()
    local closest = nil
    local shortestDistance = math.huge

    local function findDoorsInObject(obj)
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("BasePart") then
                local distance = (humanoidRootPart.Position - child.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = child
                end

                for _, attachment in pairs(child:GetChildren()) do
                    if attachment:IsA("Attachment") then
                        attachment:Destroy()
                    end
                end
            elseif child:IsA("Model") then
                findDoorsInObject(child)
            end
        end
    end

    for _, floor in pairs(floorsFolder:GetChildren()) do
        findDoorsInObject(floor)
    end

    return closest
end

copyButton.MouseButton1Click:Connect(function()
    if closestDoor then
        local main = closestDoor:FindFirstChild("Main")
        if main and main:IsA("StringValue") then
            copyToClipboard(main.Value)
        end
    end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Q then
            if closestDoor then
                local main = closestDoor:FindFirstChild("Main")
                if main and main:IsA("StringValue") then
                    copyToClipboard(main.Value)
                end
            end
        elseif input.KeyCode == Enum.KeyCode.M then
            scriptEnabled = false
            frame.Visible = false

            local notification = Instance.new("TextLabel")
            notification.Size = UDim2.new(0, 300, 0, 50)
            notification.Position = UDim2.new(0.5, -150, 0.85, 0)
            notification.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            notification.TextColor3 = Color3.new(1, 1, 1)
            notification.Text = "El script se ha cerrado."
            notification.TextScaled = true
            notification.Font = Enum.Font.GothamBold
            notification.Parent = screenGui

            task.wait(5)
            notification:Destroy()
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if scriptEnabled then
            closestDoor = findClosestDoor()

            if closestDoor then
                local main = closestDoor:FindFirstChild("Main")
                if main and main:IsA("StringValue") then
                    doorNameLabel.Text = main.Value
                    frame.Visible = true

                    copyToClipboard(main.Value)
                else
                    frame.Visible = false
                end
            else
                frame.Visible = false
            end
        end
    end
end)
