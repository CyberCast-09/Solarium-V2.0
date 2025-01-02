local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Fonction pour créer une ligne entre les joueurs
local function createLineBetween(player)
    if player.Character and LocalPlayer.Character then
        local attachment0 = Instance.new("Attachment", LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        local attachment1 = Instance.new("Attachment", player.Character:FindFirstChild("HumanoidRootPart"))

        local beam = Instance.new("Beam")
        beam.Attachment0 = attachment0
        beam.Attachment1 = attachment1
        beam.FaceCamera = false -- La ligne est visible à la première personne
        beam.Color = ColorSequence.new(Color3.new(1, 0, 0)) -- Rouge
        beam.Width0 = 0.1
        beam.Width1 = 0.1
        beam.Transparency = NumberSequence.new(0)
        beam.Parent = LocalPlayer.Character
    end
end

-- Fonction pour ajouter un highlight, un label et une ligne autour des joueurs
local function highlightPlayer(player)
    if player ~= LocalPlayer and player.Character then
        if not player.Character:FindFirstChild("Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = player.Character
            highlight.FillColor = Color3.new(1, 0, 0)
            highlight.OutlineColor = Color3.new(1, 0, 0)
            highlight.OutlineTransparency = 0
            highlight.FillTransparency = 0.5
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = player.Character
        end

        if not player.Character:FindFirstChild("NameTag") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "NameTag"
            billboard.Adornee = player.Character:WaitForChild("Head")
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true

            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextStrokeTransparency = 0.5
            textLabel.TextColor3 = Color3.new(1, 1, 1)
            textLabel.TextScaled = false
            textLabel.TextSize = 14
            textLabel.Parent = billboard
            billboard.Parent = player.Character

            RunService.RenderStepped:Connect(function()
                local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                textLabel.Text = player.Name .. " - " .. math.floor(distance) .. " m"
            end)
        end

        -- Créer une ligne entre le joueur local et ce joueur
        createLineBetween(player)
    end
end

-- Applique à tous les joueurs les effet
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then
            highlightPlayer(player)
        end
        player.CharacterAdded:Connect(function()
            highlightPlayer(player)
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        highlightPlayer(player)
    end)
end)
