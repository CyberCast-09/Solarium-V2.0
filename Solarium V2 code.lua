local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")

-- Fonction pour créer une ligne entre le curseur et les joueurs
local function createLineToPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        -- Créer les Attachments pour la ligne
        local attachment0 = Instance.new("Attachment", LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        local attachment1 = Instance.new("Attachment", player.Character:FindFirstChild("HumanoidRootPart"))

        -- Créer le Beam (la ligne)
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

-- Fonction pour ajouter un highlight, un label autour des joueurs
local function highlightPlayer(player)
    if player ~= LocalPlayer and player.Character then
        -- Ajouter le Highlight si nécessaire
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

        -- Ajouter un label de nom au joueur
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

            -- Mettre à jour la distance en temps réel
            RunService.RenderStepped:Connect(function()
                local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                textLabel.Text = player.Name .. " - " .. math.floor(distance) .. " m"
            end)
        end

        -- Créer une ligne entre le curseur et le joueur
        createLineToPlayer(player)
    end
end

-- Appliquer les effets à tous les joueurs
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

-- Lorsque de nouveaux joueurs rejoignent, appliquer les effets
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        highlightPlayer(player)
    end)
end)

-- Mettre à jour la position des lignes en temps réel
RunService.RenderStepped:Connect(function()
    -- Met à jour les lignes entre le curseur et tous les autres joueurs
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- Créer une ligne entre le curseur et chaque joueur
                createLineToPlayer(player)
            end
        end
    end
end)
