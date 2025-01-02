local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")  -- Service pour détecter les touches

-- Fonction pour créer une ligne entre le joueur local (curseur) et un autre joueur
local function createLineToPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        -- Attachement de la ligne au joueur local
        local attachment0 = Instance.new("Attachment")
        attachment0.Parent = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        -- Attachement de la ligne au joueur cible
        local attachment1 = Instance.new("Attachment", player.Character:FindFirstChild("HumanoidRootPart"))

        -- Création de la ligne (Beam)
        local beam = Instance.new("Beam")
        beam.Attachment0 = attachment0
        beam.Attachment1 = attachment1
        beam.Color = ColorSequence.new(Color3.new(1, 0, 0)) -- Rouge
        beam.Width0 = 0.1
        beam.Width1 = 0.1
        beam.Transparency = NumberSequence.new(0)
        beam.Parent = LocalPlayer.Character
    end
end

-- Fonction pour ajouter un surlignage et une étiquette de nom autour des joueurs
local function highlightPlayer(player)
    if player ~= LocalPlayer and player.Character then
        -- Ajout d'un surlignage (Highlight) autour du joueur
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

        -- Création d'une étiquette de nom (BillboardGui)
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

            -- Mise à jour de l'étiquette avec la distance entre les joueurs
            RunService.RenderStepped:Connect(function()
                local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                textLabel.Text = player.Name .. " - " .. math.floor(distance) .. " m"
            end)
        end

        -- Créer une ligne entre le joueur local et ce joueur
        createLineToPlayer(player)

        -- Afficher la barre de santé à gauche du joueur
        if not player.Character:FindFirstChild("HealthBar") then
            -- Création de l'affichage de la barre de santé
            local healthBillboard = Instance.new("BillboardGui")
            healthBillboard.Name = "HealthBar"
            healthBillboard.Adornee = player.Character:WaitForChild("Head")
            healthBillboard.Size = UDim2.new(0, 10, 0, 100)  -- Taille de la barre verticale
            healthBillboard.StudsOffset = Vector3.new(-2, 0, 0)  -- Décalage à gauche du joueur
            healthBillboard.AlwaysOnTop = true

            local backgroundFrame = Instance.new("Frame")
            backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
            backgroundFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)  -- Fond sombre
            backgroundFrame.BackgroundTransparency = 0.5
            backgroundFrame.BorderSizePixel = 0
            backgroundFrame.Parent = healthBillboard

            local healthFrame = Instance.new("Frame")
            healthFrame.Size = UDim2.new(1, 0, 0, 100)  -- La hauteur sera ajustée
            healthFrame.BackgroundColor3 = Color3.new(0, 1, 0)  -- Vert pour la barre de santé
            healthFrame.BorderSizePixel = 0
            healthFrame.Parent = backgroundFrame

            healthBillboard.Parent = player.Character

            -- Mettre à jour la barre de santé en temps réel
            local humanoid = player.Character:WaitForChild("Humanoid")
            humanoid.HealthChanged:Connect(function()
                local healthPercentage = humanoid.Health / humanoid.MaxHealth
                healthFrame.Size = UDim2.new(1, 0, healthPercentage, 0)  -- Ajuste la hauteur de la barre
            end)

            -- Ajuster la taille de la barre de santé pour correspondre à la taille du personnage
            RunService.RenderStepped:Connect(function()
                -- Obtenir la hauteur du personnage
                local humanoid = player.Character:WaitForChild("Humanoid")
                local characterHeight = humanoid.HipWidth + humanoid.HipHeight  -- Estimation de la hauteur du personnage

                -- Ajuster la hauteur de la barre de santé pour correspondre à la hauteur du personnage
                healthBillboard.Size = UDim2.new(0, 10, 0, characterHeight)
            end)

            -- Réduire la taille de la barre de santé en fonction de la distance
            RunService.RenderStepped:Connect(function()
                local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                -- Réduire la taille de la barre avec l'augmentation de la distance
                local scaleFactor = math.max(0.1, 1 - distance / 100)  -- Plus la distance augmente, plus la barre se réduit
                local humanoid = player.Character:WaitForChild("Humanoid")
                local characterHeight = humanoid.HipWidth + humanoid.HipHeight  -- Hauteur du personnage

                -- Ajuster la taille de la barre de santé selon la distance et la taille du joueur
                healthBillboard.Size = UDim2.new(0, 10 * scaleFactor, 0, characterHeight * scaleFactor)
            end)
        end
    end
end

-- Ajouter un GUI au démarrage du code (un rectangle)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RectangleGui"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Créer un rectangle dans le GUI
local rectangle = Instance.new("Frame")
rectangle.Size = UDim2.new(0, 700, 0, 400)  -- Taille agrandie du rectangle
rectangle.Position = UDim2.new(0.5, -350, 0.5, -200)  -- Centré à l'écran
rectangle.BackgroundColor3 = Color3.new(0, 0, 0)  -- Noir
rectangle.BackgroundTransparency = 0  -- Opaque
rectangle.BorderSizePixel = 0  -- Pas de bordure
rectangle.Parent = screenGui

-- Ajouter des coins arrondis au rectangle
rectangle.CornerRadius = UDim.new(0, 20)  -- Coins arrondis de 20 pixels

-- Variable pour suivre l'état de la visibilité du rectangle
local isVisible = true

-- Fonction pour basculer la visibilité du rectangle quand RightShift est pressé
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end  -- Ignorer si le jeu a déjà traité l'entrée
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.RightShift then
        -- Bascule la visibilité
        isVisible = not isVisible
        rectangle.Visible = isVisible
    end
end)

-- Applique l'effet à tous les joueurs existants
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

-- Applique l'effet à un joueur lorsqu'il rejoint
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        highlightPlayer(player)
    end)
end)
