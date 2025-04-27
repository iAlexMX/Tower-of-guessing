local notification = nil
local copyButton = nil

local function copyToClipboard(text)
    local success, err = pcall(function()
        local HttpService = game:GetService("HttpService")
        setclipboard(text)
    end)
    if not success then
        warn("Error al copiar al portapapeles: " .. err)
    end
end

local function findClosestDoor()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local closestDoor = nil
    local shortestDistance = math.huge

    local floorsFolder = workspace:FindFirstChild("Game"):FindFirstChild("Floors")
    if not floorsFolder then
        print("No se encontró la carpeta 'Floors' en 'workspace.Game'.")
        return
    end

    local function findDoorsInObject(obj)
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("BasePart") then
                local distance = (humanoidRootPart.Position - child.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestDoor = child
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

    return closestDoor
end

local function updateNotification()
    local player = game.Players.LocalPlayer
    local door = findClosestDoor()
    if door then
        local main = door:FindFirstChild("Main")
        if main and main:IsA("StringValue") then
            local doorName = main.Value

            local playerGui = player:WaitForChild("PlayerGui")
            if not notification then
                local screenGui = Instance.new("ScreenGui")
                screenGui.Parent = playerGui

                notification = Instance.new("TextBox")
                notification.Parent = screenGui
                notification.Position = UDim2.new(0.5, -100, 0.1, 0)
                notification.Size = UDim2.new(0, 200, 0, 50)
                notification.BackgroundColor3 = Color3.new(0, 0, 0)
                notification.TextColor3 = Color3.new(1, 1, 1)
                notification.TextSize = 20
                notification.TextStrokeTransparency = 0.5
                notification.ClearTextOnFocus = false
                notification.TextEditable = false

                copyButton = Instance.new("TextButton")
                copyButton.Parent = screenGui
                copyButton.Position = UDim2.new(0.5, -50, 0.2, 0)
                copyButton.Size = UDim2.new(0, 100, 0, 50)
                copyButton.BackgroundColor3 = Color3.new(0, 0, 0)
                copyButton.TextColor3 = Color3.new(1, 1, 1)
                copyButton.TextSize = 20
                copyButton.Text = "Copiar"
                copyButton.MouseButton1Click:Connect(function()
                    copyToClipboard(notification.Text)
                end)
            end

            notification.Text = doorName
        else
            print("No se encontró el objeto 'Main' en la puerta o no es un StringValue.")
        end
    else
        print("No se encontró ninguna puerta cercana.")
    end
end

while true do
    updateNotification()
    wait(0.1)
end
