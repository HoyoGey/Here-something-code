repeat
    wait()
until game:IsLoaded()

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(
    function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end
)

getupvalues = getupvalues or debug.getupvalues
setupvalue = setupvalue or debug.setupvalue
if not (getrawmetatable and getupvalues and setupvalue and (getreg or debug.getregistry)) then
    local h = Instance.new("Hint", workspace)
    h.Text = "Incompatible exploit."
    wait(3)
    h:Destroy()
    return
end

if getconnections then
    for _, c in next, getconnections(game:GetService("ScriptContext").Error) do
        c:Disable()
    end
end

getgenv().TableCountWork = {
    Cashier = 0,
    Cook = 0,
    Delivery = 0,
	Boxing = 0,
	Supplier = 0
}

local player = game:GetService("Players").LocalPlayer
local ffc = game.FindFirstChild
local RNG = Random.new()
local network
local character, root
do
    local reg = (getreg or debug.getregistry)()
    for i = 1, #reg do
        local f = reg[i]
        if type(f) == "function" and tostring(getfenv(f).script) == "Paycheck" then
            for k, v in next, getupvalues(f) do
                if tostring(v) == "CashOut" then
                    setupvalue(
                        f,
                        k,
                        {MouseButton1Click = {wait = function()
                                end, Wait = function()
                                end}}
                    )
                    break
                end
            end
        elseif type(f) == "table" and rawget(f, "FireServer") and rawget(f, "BindEvents") then
            network = f
        end
    end
    local mt = getrawmetatable(game)
    if setreadonly then
        setreadonly(mt, false)
    elseif make_writeable then
        make_writeable(mt)
    end
    local old__newindex = mt.__newindex
    if newcclosure then
        mt.__newindex =
            newcclosure(
            function(t, k, v)
                if t ~= workspace.CurrentCamera or tostring(getfenv(2).script) ~= "LocalMain" then
                    return old__newindex(t, k, v)
                end
            end
        )
    else
        mt.__newindex = function(t, k, v)
            if t ~= workspace.CurrentCamera or tostring(getfenv(2).script) ~= "LocalMain" then
                return old__newindex(t, k, v)
            end
        end
    end
    workspace.Main.RealignCamera.RealignCamera:Destroy()
    Instance.new("BindableEvent", workspace.Main.RealignCamera).Name = "RealignCamera"
end
assert(network, "failed to find network")
--//subroutines
local supplyCounts = {TomatoSauce=99,Cheese=99,Sausage=99,Pepperoni=99,Dough=99,Box=99,Dew=99}
for name in pairs(supplyCounts) do
	local lbl = workspace.SupplyCounters:GetChildren()[3][name=="Dew" and "CounterMountainDew" or "Counter"..name].a.SG.Counter
	supplyCounts[name]=tonumber(lbl.Text)
	lbl.Changed:Connect(function()
		supplyCounts[name]=tonumber(lbl.Text)
	end)
end

local function FindFirstCustomer()
	local children = workspace.Customers:GetChildren()
	for i=1,#children do
		local c = children[i]
		if ffc(c,"Head") and ffc(c,"Humanoid") and c.Head.CFrame.Z<102 and ffc(c.Head,"Dialog") and ffc(c.Head.Dialog,"Correct") and ((c.Humanoid.SeatPart and c.Humanoid.SeatPart.Anchored) or (c.Humanoid.SeatPart==nil and (c.Head.Velocity.Z^2)^.5<.0001)) then
			return c
		end
	end
end

local boxPtick=0
local boxDtick=0
local function FindBoxes()
	local c,o,f
	local children = workspace.AllBox:GetChildren()
	for i=1,#children do
		local b = children[i]
		if ffc(b,"HasPizzaInside") or ffc(b,"Pizza") then
			if c==nil and b.Name=="BoxClosed" and b.Anchored==false and not b.HasPizzaInside.Value then
				c=b
			elseif o==nil and b.Name=="BoxOpen" and b.Anchored==false and not b.Pizza.Value then
				o=b
			elseif f==nil and (b.Name=="BoxOpen" and b.Pizza.Value) or (b.Name=="BoxClosed" and b.HasPizzaInside.Value) then
				f=b
			end
			if c and o and f then
				return c,o,f
			end
		end
	end
	return c,o,f
end
local function FindBoxingFoods()
	local p,d
	local children = workspace.BoxingRoom:GetChildren()
	for i=1,#children do
		local f = children[i]
		if not f.Anchored then
			if p==nil and f.Name=="Pizza" then
				p=f
			elseif d==nil and f.Name=="Dew" then
				d=f
			end
			if p and d then
				return p,d
			end
		end
	end
	return p,d
end

local orderDict={["3540529228"]="Cheese",["3540530535"]="Sausage",["3540529917"]="Pepperoni",["2512571151"]="Dew",["2512441325"]="Dew"}
local cookingDict = {Cheese=0,Sausage=0,Pepperoni=0,Dew=0}
local cookPtick=0
local cookDtick=0
local cookWarned=false
local boxerWarned=false
local function getOrders()
	local orders={}
	local tempCookingDict = {}
	for i,v in pairs(cookingDict) do tempCookingDict[i]=v end
	local children = workspace.Orders:GetChildren()
	for i=1,#children do
		local o = orderDict[children[i].SG.ImageLabel.Image:match("%d+$")]
		if o then
			if tempCookingDict[o]>0 then
				--ignores oven pizzas, so new orders are priority
				tempCookingDict[o]=tempCookingDict[o]-1
			elseif (o=="Dew" and #workspace.AllMountainDew:GetChildren()>0) or (supplyCounts[o]>0 and supplyCounts.TomatoSauce>0 and supplyCounts.Cheese>0) then
				--need supplies
				orders[#orders+1]=o
			end
		end
	end
	return orders
end
local function FindFirstDew()
	local children = workspace.AllMountainDew:GetChildren()
	for i=1,#children do
		if not children[i].Anchored then
			return children[i]
		end
	end
end
local function FindDoughAndWithout(str)
	local goodraw,p,raw,trash
	local children = workspace.AllDough:GetChildren()
	for i = #children, 2, -1 do --shuffle
		local j = RNG:NextInteger(1, i)
		children[j], children[i] = children[i], children[j]
	end
	for i=1,#children do
		local d = children[i]
		if d.Anchored==false and #d:GetChildren()>9 then
			if d.IsBurned.Value or d.HasBugs.Value or d.Cold.Value or (d.BrickColor.Name=="Bright orange" and ffc(d,"XBillboard")) then
				if trash==nil and d.Position.Y > 0 then
					trash=d
				end
			elseif p==nil and d.BrickColor.Name=="Bright orange" then
				p=d
			elseif goodraw==nil and d.Position.X<55 and d.BrickColor.Name=="Brick yellow" and ((str and not ffc(d.SG.Frame,str)) or (str==nil and ffc(d.SG.Frame,"Sausage")==nil and ffc(d.SG.Frame,"Pepperoni")==nil)) then
				--prefers flat
				if d.Mesh.Scale.Y<1.1 then
					goodraw=d
				else
					raw=d
				end
			end
			if goodraw and p and trash then
				return goodraw,p,trash
			end
		end
	end
	return goodraw or raw,p,trash
end
local function getOvenNear(pos)
	local children = workspace.Ovens:GetChildren()
	for i=1,#children do
		if (children[i].Bottom.Position-pos).magnitude < 1.5 then
			return children[i]
		end
	end
end
local function getDoughNear(pos)
	local children = workspace.AllDough:GetChildren()
	for i=1,#children do
		if (children[i].Position-pos).magnitude < 1.5 then
			return children[i]
		end
	end
end
local function isFullyOpen(oven)
	return oven.IsOpen.Value==true and (oven.Door.Meter.RotVelocity.Z^2)^.5<.0001
end

local bcolorToSupply = {["Dark orange"]="Sausage",["Bright blue"]="Pepperoni",["Bright yellow"]="Cheese",["Bright red"]="TomatoSauce",["Dark green"]="Dew",["Brick yellow"]="Dough",["Light stone grey"]="Box",["Really black"]="Dew"}
local supplyButtons = {}
for _,button in ipairs(workspace.SupplyButtons:GetChildren()) do
	supplyButtons[bcolorToSupply[button.Unpressed.BrickColor.Name]] = button.Unpressed
end

local delTool
local function FindFirstDeliveryTool()
	local t
	local children = workspace:GetChildren()
	for i=1,#children do
		local v = children[i]
		if v.ClassName=="Tool" and v.Name:match("^%u%d$") and ffc(v,"House") and ffc(v,"Handle") and ffc(v,"Order") and v.Order.Value:match("%a") then
			if ffc(v.Handle,"X10") then
				return v
			end
			t = v
		end
	end
	return t
end
local function getHousePart(address)
    local houses = workspace.Houses:GetChildren()
    for i=1,#houses do
        local h = houses[i]
        if ffc(h,"Address") and h.Address.Value==address and ffc(h,"GivePizza",true) then
            return ffc(h,"GivePizza",true)
        end
    end
end
local delTouched=false
local function forgetDeliveryTool()
	if delTool then
		if delTool.Parent==player.Backpack then
			delTool.Parent = character
		end
		if delTool.Parent==character then
			wait(0.1)
			delTool.Parent = workspace
			wait(0.1)
		end
	end
	delTool=nil
	delTouched=false
	if ffc(character,"RightHand") and ffc(character.RightHand,"RightGrip") then
		character.RightHand.RightGrip:Destroy()
	end
end

local function FindAllDeliveryTools(parent)
	local t = {}
	local children = parent:GetChildren()
	for i=1,#children do
		local v = children[i]
		if v.ClassName=="Tool" and v.Name:match("^%u%d$") and ffc(v,"Handle") and ffc(v,"House") and (parent~=workspace or (v.Handle.Position-Vector3.new(54.45, 4.02, -16.56)).Magnitude < 30) then
			t[#t+1] = v
		end
	end
	return t
end

local function onCharacterAdded(char)
	if not char then return end
	character=char
	root = character:WaitForChild("HumanoidRootPart")
	character:WaitForChild("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if delTool then
			character.Humanoid.WalkSpeed=16
		end
	end)
end
onCharacterAdded(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(onCharacterAdded)

local function smoothTP2(cf)
	local cf0 = (cf-cf.p) + root.Position + Vector3.new(0,4,0)
	local diff = cf.p - root.Position
	local oldg = workspace.Gravity
	workspace.Gravity = 0
	for i=0,diff.Magnitude,0.9 do
		humanoid.Sit=false
		root.CFrame = cf0 + diff.Unit * i
		root.Velocity,root.RotVelocity=Vector3.new(),Vector3.new()
		wait()
	end
	root.CFrame = cf
	workspace.Gravity = oldg
end
local function smoothTP(cf)
    if (cf.p-root.Position).Magnitude > 95 then
        local btns = workspace.JobButtons:GetChildren()
        if player:FindFirstChild("House") and player.House.Value then
            btns[#btns+1] = player.House.Value:FindFirstChild("Marker") 
        end
        table.sort(btns,function(a,b) return (a.Position-cf.p).Magnitude < (b.Position-cf.p).Magnitude end)
        if (btns[1].Position-cf.p).Magnitude < (cf.p-root.Position).Magnitude then
            game:GetService("ReplicatedStorage").PlayerChannel:FireServer("TeleportToJob", ((btns[1].Name == "Marker") and "House" or btns[1].Name))
            wait(0.7)
            if (cf.p-root.Position).Magnitude < 8 then
                return
            end
        end
    end
    smoothTP2(cf)
end

local function simTouch(part)
	local oldcc = part.CanCollide
	local oldcf = part.CFrame
	part.CanCollide = false
	part.CFrame = root.CFrame
	delay(0.01,function()
		part.CFrame = oldcf
		part.CanCollide = oldcc
	end)
end

local SolarisLib =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/HoyoGey/My-Lua-Project/main/UiLibs/SolarisBest.lua"))(
    "Sex"
)

local Window =
    SolarisLib:New(
    {
        Title = "  Work At A Pizza Place | <b>Solvix Hub</b>",
        FolderToSave = "Solvix"
    }
)

local Main = Window:Tab("Main")
local Info = Main:Section("Info")

Info:Poragraph(
    {
        Title = "What is that",
        Desc = "Here is the count of the work done by the farm, here you will see how many times you have done your work"
    }
)

local startTime = os.time()

function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)
    local days = math.floor(hours / 24)

    seconds = seconds % 60
    minutes = minutes % 60
    hours = hours % 24

    return string.format("%02dd %02dh %02dm %02ds", days, hours, minutes, seconds)
end

-- Etc Info
local CountMoney = Info:Label("Loading...", Color3.fromRGB(255, 255, 255))
local PlayedTimes = Info:Label("Played Time: ...", Color3.fromRGB(255, 255, 255))

-- Work Count
local CountCashier = Info:Label("Cashier: 0", Color3.fromRGB(255, 255, 255))
local CountCook = Info:Label("Cook: 0", Color3.fromRGB(255, 255, 255))
local CountBoxing = Info:Label("Boxing: 0", Color3.fromRGB(255, 255, 255))
local CountDelivery = Info:Label("Delivery: 0", Color3.fromRGB(255, 255, 255))
local CountSupplier = Info:Label("Supplier: 0", Color3.fromRGB(255, 255, 255))

local AutoFarm = Window:Tab("AutoFarm")
local SettingsFarm = AutoFarm:Section("Settings Farm")

SettingsFarm:Slider(
    {
        Name = "Supplier ReFill At",
        Minimum = 1,
        Maximum = 100,
        Default = 5,
        Increment = 1,
        Flag = "334653654",
        Callback = function(t)
            getgenv().ReFillat = t
        end
    }
)

SettingsFarm:Slider(
    {
        Name = "Supplier ReFill End",
        Minimum = 1,
        Maximum = 100,
        Default = 5,
        Increment = 1,
        Flag = "3346453654",
        Callback = function(t)
            getgenv().ReFillend = t
        end
    }
)

SettingsFarm:Slider(
    {
        Name = "Deliver At Count",
        Minimum = 1,
        Maximum = 50,
        Default = 5,
        Increment = 1,
        Flag = "3346534654",
        Callback = function(t)
            getgenv().Deliver = t
        end
    }
)


local EnabledFarm = AutoFarm:Section("Enable Farm")

EnabledFarm:Toggle(
    {
        Name = "Cashier",
        Default = false,
        Flag = "738726587394653856",
        Callback = function(t)
            getgenv().Cashier = t
            local hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            while getgenv().Cashier do
                wait()
                local Costumer = FindFirstCustomer()
                if Costumer then
                    local dialog = Costumer.Head.Dialog.Correct.ResponseDialog or ""
                    local rootMoved = false
                    if
                        (game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position -
                            Vector3.new(46.34, 3.80, 82.02)).magnitude > 9
                     then
                        rootMoved = true
                        game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame =
                            CFrame.new(46.34, 3.80, 82.02)
                        wait(.1)
                    end
                    local order = "MountainDew"
                    if dialog:sub(-8) == "instead." then
                        dialog = dialog:sub(-30)
                    end
                    if dialog:find("pepperoni", 1, true) then
                        order = "PepperoniPizza"
                    elseif dialog:find("sausage", 1, true) then
                        order = "SausagePizza"
                    elseif dialog:find("cheese", 1, true) then
                        order = "CheesePizza"
                    end

                    network:FireServer("OrderComplete", Costumer, order, workspace.Register3)
                    if rootMoved then
                        wait(.1)
                    end
                    wait(0.5)
                    getgenv().TableCountWork.Cashier = getgenv().TableCountWork.Cashier + 1
                end
            end
        end
    }
)

EnabledFarm:Toggle(
    {
        Name = "Cook",
        Default = false,
        Flag = "7387265873956",
        Callback = function(t)
            getgenv().Cook = t
            while getgenv().Cook == true do
                wait(1.5)
                local order = getOrders()[1]
				local topping
				if order=="Pepperoni" or order=="Sausage" then topping=order end
				local cookD = FindFirstDew()
				local raw,cookP,trash
				if topping then
					--pepperoni order avoids sausage dough and vice verca
					raw,cookP,trash = FindDoughAndWithout(topping=="Pepperoni" and "Sausage" or "Pepperoni")
				else
					raw,cookP,trash = FindDoughAndWithout()
				end
				local rootMoved = false
				local ovens = workspace.Ovens:GetChildren()
				for i = #ovens, 2, -1 do --shuffle
					local j = RNG:NextInteger(1, i)
					ovens[j], ovens[i] = ovens[i], ovens[j]
				end
				--move final pizza
				if cookP and tick()-cookPtick>0.8 then
					local oven = getOvenNear(cookP.Position)
					if oven==nil or oven.IsOpen.Value then
						cookPtick=tick()
						if (root.Position-Vector3.new(44.63, 6.60, 45.20)).magnitude>9 then rootMoved = true root.CFrame = CFrame.new(44.63, 6.60, 45.20) wait(.1) end
						network:FireServer("UpdateProperty", cookP, "CFrame", CFrame.new(56,4.1,38))
						getgenv().TableCountWork.Cook = getgenv().TableCountWork.Cook + 1
					end
				end
				if order then
					if order=="Dew" and cookD and tick()-cookDtick>0.8 then
						--move dew if ordered
						cookDtick=tick()
						if (root.Position-Vector3.new(44.63, 6.60, 45.20)).magnitude>9 then rootMoved = true root.CFrame = CFrame.new(44.63, 6.60, 45.20) wait(.1) end
						network:FireServer("UpdateProperty", cookD, "CFrame", CFrame.new(53,4.68,36.5))
					elseif order~="Dew" and raw and raw.Parent and supplyCounts[order]>0 and supplyCounts.TomatoSauce>0 and supplyCounts.Cheese>0 then
						--make pizza
						if raw.Mesh.Scale.Y>1.5 then
							if (root.Position-Vector3.new(44.63, 6.60, 45.20)).magnitude>9 then rootMoved = true root.CFrame = CFrame.new(44.63, 6.60, 45.20) wait(.1) end
							network:FireServer("UpdateProperty", raw, "CFrame", CFrame.new(RNG:NextNumber(29.6,44.6),3.7,RNG:NextNumber(42.5,48.5)))
							wait()
							network:FireServer("SquishDough", raw)
						else
							--make sure it will have an oven
							local oven
							for _,o in ipairs(ovens) do
								if isFullyOpen(o) then
									local other = getDoughNear(o.Bottom.Position)
									if other==nil or not (other.BrickColor.Name=="Bright orange" and ffc(other.SG.Frame,"TomatoSauce") and ffc(other.SG.Frame,"MeltedCheese")) then
										if other then
											--replace mistaken dough
											if (root.Position-Vector3.new(44.63, 6.60, 45.20)).magnitude>9 then rootMoved = true root.CFrame = CFrame.new(44.63, 6.60, 45.20) wait(.1) end
											network:FireServer("UpdateProperty", other, "CFrame", CFrame.new(RNG:NextNumber(29.6,44.6),3.7,RNG:NextNumber(42.5,48.5)))
											wait()
										end
										oven=o
										break
									end
								end
							end
							if oven and raw.Parent==workspace.AllDough then
								--make
								if (root.Position-Vector3.new(44.63, 6.60, 45.20)).magnitude>9 then rootMoved = true root.CFrame = CFrame.new(44.63, 6.60, 45.20) wait(.1) end
								network:FireServer("AddIngredientToPizza", raw,"TomatoSauce")
								network:FireServer("AddIngredientToPizza", raw,"Cheese")
								network:FireServer("AddIngredientToPizza", raw,topping)
								network:FireServer("UpdateProperty", raw, "CFrame", oven.Bottom.CFrame+Vector3.new(0,0.7,0))
								oven.Door.ClickDetector.Detector:FireServer()
								--mark as cooking
								cookingDict[order]=cookingDict[order]+1
								local revoked=false
								spawn(function()
									raw.AncestryChanged:Wait()
									if not revoked then
										cookingDict[order]=cookingDict[order]-1
										revoked=true
									end
								end)
								delay(40, function()
									if not revoked then
										cookingDict[order]=cookingDict[order]-1
										revoked=true
									end
								end)
							end
						end
					end
				end
				--open unnecessarily closed ovens
				for _,o in ipairs(ovens) do
					local bar = o.Door.Meter.SurfaceGui.ProgressBar.Bar
					if o.IsOpen.Value==false and (o.IsCooking.Value==false or (Vector3.new(bar.ImageColor3.r,bar.ImageColor3.g,bar.ImageColor3.b)-Vector3.new(.871,.518,.224)).magnitude>.1) then
						if (root.Position-Vector3.new(44.63, 6.60, 45.20)).magnitude>9 then rootMoved = true root.CFrame = CFrame.new(44.63, 6.60, 45.20) wait(.1) end
						o.Door.ClickDetector.Detector:FireServer()
						break
					end
				end
				--trash
				if trash and (trash.IsBurned.Value==false or getOvenNear(trash.Position)==nil or getOvenNear(trash.Position).IsOpen.Value) then
					--closed oven breaks if you take burnt out of it
					if (root.Position-Vector3.new(44.63, 6.60, 45.20)).magnitude>9 then rootMoved = true root.CFrame = CFrame.new(44.63, 6.60, 45.20) wait(.1) end
					network:FireServer("UpdateProperty", trash, "CFrame", CFrame.new(47.9,RNG:NextNumber(-10,-30),72.5))
				end
				if rootMoved then wait(.1) end
            end
        end
    }
)

EnabledFarm:Toggle(
    {
        Name = "Boxing",
        Default = false,
        Flag = "1234567543243134565432",
        Callback = function(t)
            getgenv().Boxing = t
            while getgenv().Boxing do
                wait()
				local boxP,boxD = FindBoxingFoods()
				local closedBox,openBox,fullBox = FindBoxes()
				local rootMoved = false
				if boxD and tick()-boxDtick>0.8 then
					boxDtick=tick()
					if (root.Position-Vector3.new(54.09, 3.80, 23.150)).magnitude>9 then rootMoved = true root.CFrame = CFrame.new(54.09, 3.80, 23.15) wait(.1) end
					network:FireServer("UpdateProperty", boxD, "CFrame", CFrame.new(63,4.9,-1,-1,0,0,0,1,0,0,0,-1))
				end
				if fullBox then
					if fullBox.Name=="BoxOpen" then
						if (root.Position-Vector3.new(54.09, 3.80, 23.150)).magnitude>9 then rootMoved = true root.CFrame = CFrame.new(54.09, 3.80, 23.15) wait(.1) end 
						network:FireServer("CloseBox", fullBox)
                        wait(0.3)
						getgenv().TableCountWork.Boxing = getgenv().TableCountWork.Boxing + 1
						--will be moved next loop
					elseif tick()-boxPtick>0.8 then
						if (root.Position-Vector3.new(54.09, 3.80, 23.150)).magnitude>9 then rootMoved = true root.CFrame = CFrame.new(54.09, 3.80, 23.15) wait(.1) end
						network:FireServer("UpdateProperty", fullBox, "CFrame", CFrame.new(68.2,4.4,-1,-1,0,0,0,1,0,0,0,-1))
						boxPtick=tick()
					end
				end
				if closedBox and not openBox then
					if (root.Position-Vector3.new(54.09, 3.80, 23.150)).magnitude>9 then rootMoved = true root.CFrame = CFrame.new(54.09, 3.80, 23.15) wait(.1) end
					network:FireServer("UpdateProperty", closedBox, "CFrame", CFrame.new(RNG:NextNumber(62.5,70.5),3.5,RNG:NextNumber(11,25)))
					wait()
					network:FireServer("OpenBox", closedBox)
				end
				if openBox and boxP then
					if (root.Position-Vector3.new(54.09, 3.80, 23.150)).magnitude>9 then rootMoved = true root.CFrame = CFrame.new(54.09, 3.80, 23.15) wait(.1) end
					network:FireServer("UpdateProperty", boxP, "Anchored", true)
					network:FireServer("UpdateProperty", openBox, "Anchored", true)
					wait()
					network:FireServer("UpdateProperty", boxP, "CFrame", openBox.CFrame+Vector3.new(0,-2,0))
					wait()
					network:FireServer("AssignPizzaToBox", openBox, boxP)
				end
				if rootMoved then wait(.1) end
			end
        end
    }
)

EnabledFarm:Toggle(
    {
        Name = "Delivery [Not Work 💀, soon i can't fix it]",
        Default = false,
        Flag = "12345675432134565432",
        Callback = function(t)
            getgenv().Delivery = t
            while getgenv().Deliver == true do
                wait()
                local wstools = FindAllDeliveryTools(workspace)
                if #wstools > 1 or (wstools[1] and ffc(wstools[1].Handle,"X10")) then
                    --get tools
                    if (root.Position-Vector3.new(54.45, 4.02, -15)).magnitude>9 then smoothTP(CFrame.new(54.45, 4.02, -15)) wait(.1) end
                    for i=1,#wstools do
                        if wstools[i].Parent == workspace then
                            game.Players.LocalPlayer.Character:FindFirstChild("Humanoid"):EquipTool(wstools[i])
                            wait()
                        end
                    end
                    wait(0.3)
                    local t = FindAllDeliveryTools(character)
                    for i=1,#t do
                        t[i].Parent = player.Backpack
                    end
                    wait(0.1)
                    if ffc(character,"RightHand") and ffc(character.RightHand,"RightGrip") then
                        character.RightHand.RightGrip:Destroy()
                    end
                end
                local bptools = FindAllDeliveryTools(player.Backpack)
                if #bptools > getgenv().Deliver and #bptools > 0 and tick()-delTick > 30 then
                    --deliver to houses
                    table.sort(bptools,function(a,b)
                        a,b=tostring(a),tostring(b)
                        if (a:sub(1,1)=="B" and b:sub(1,1)=="B") then
                            return a < b
                        end
                        return a > b
                    end)
                    local fatass=false
                    for i=1,#bptools do
                        if not getgenv().Delivery then
                            break
                        end
                        local tool = bptools[i]
                        local giver = getHousePart(tool.Name)
                        local ogp = giver.Position
                        if giver then
                            if (giver.Position-root.Position).Magnitude > 9 then
                                smoothTP(giver.CFrame+Vector3.new(0,7,0))
                                if giver.Parent==nil or (giver.Position-ogp).Magnitude>1 then
                                    giver = getHousePart(tool.Name) or giver
                                    smoothTP(giver.CFrame+Vector3.new(0,7,0))
                                end
                                pcall(function() tool.Parent = character end)
                                wait(1.2)
                                local t = FindAllDeliveryTools(character)
                                for i=1,#t do
                                    if t[i] ~= tool then
                                        t[i].Parent = player.Backpack
                                    end
                                end
                                wait(2)
                                fatass=false
                            else
                                if fatass then
                                    wait(0.2)
                                else
                                    wait(0.7)
                                end
                                pcall(function() tool.Parent = character end)
                                wait()
                                fatass=true
                            end
                        end
                    end
                    delTick = tick()
                    getgenv().TableCountWork.Deliver = getgenv().TableCountWork.Deliver + 1
                end
            end
        end
    }
)

EnabledFarm:Toggle(
    {
        Name = "Supplier",
        Default = false,
        Flag = "12345467543243134565432",
        Callback = function(t)
            getgenv().Supplier = t
				local refill=false
				for s,c in pairs(supplyCounts) do
					if c <= getgenv().ReFillat then
						refill=true
						break
					end
				end
				if refill then
					local oldcf = root.CFrame
					local alt=0
					local waiting = false
					local waitingTick = 0
					local lastBox
					while getgenv().Supplier do
						--check if refill is done otherwise hit buttons
						local fulfilled=true
						local boxes = workspace.AllSupplyBoxes:GetChildren()
						for s,c in pairs(supplyCounts) do
							if c<getgenv().ReFillend then
								fulfilled=false
								local count = 0
								if #boxes > 30 then
									for i=1,#boxes do
										local box = boxes[i]
										if bcolorToSupply[box.BrickColor.Name]==s and box.Anchored==false and box.Position.Z < -940 then
											count=count+1
										end
									end
								end
								if count < 2 then
									root.CFrame = supplyButtons[s].CFrame;
									--simTouch(supplyButtons[s])
									wait(0.3)
								end
							end
						end
						if fulfilled then
							break
						end
						wait(1.5)
						--check if can finish waiting for boxes to move
						if waiting and (lastBox.Position.X>42 or tick()-waitingTick>5) then
							waiting=false
							if lastBox.Position.X<42 then
								--clear boxes if stuck
								root.CFrame=CFrame.new(20.5,8,-35)
								wait(0.1)
								local boxes = workspace.AllSupplyBoxes:GetChildren()
								for i=1,#boxes do
									local box = boxes[i]
									if box.Anchored==false and box.Position.Z>-55 then
										network:FireServer("UpdateProperty", box, "CFrame", CFrame.new(RNG:NextNumber(0,40),RNG:NextNumber(-10,-30),-70))
										wait()
									end
								end
								wait(0.1)
							end
						end
						if not waiting then
							--move boxes
							root.CFrame=CFrame.new(8,12.4,-1020)
							wait(0.1)
							alt=1-alt
							lastBox=nil
							local j=0
							local boxes = workspace.AllSupplyBoxes:GetChildren()
							for i=1,#boxes do
								local box = boxes[i]
								if box.Anchored==false and box.Position.Z < -940 and bcolorToSupply[box.BrickColor.Name] and supplyCounts[bcolorToSupply[box.BrickColor.Name]]<getgenv().ReFillend then
									box.CFrame = CFrame.new(38-4*j,5,-7-5*alt)
									network:FireServer("UpdateProperty", box, "CFrame", box.CFrame)
									lastBox=box
									j=j+1
									if j>8 then break end
								end
							end
							if alt==0 and lastBox then
								waiting=true
								waitingTick=tick()
							end
							getgenv().TableCountWork.Supplier = getgenv().TableCountWork.Supplier + 1
						end
					end
					root.CFrame=oldcf
				end
        end
    }
)

local LCP = Window:Tab("LocalPlayer")

local LCPGF = LCP:Section("Game Functions")

local PlayersTable = {}

for i, v in next, game.Players:GetChildren() do
    table.insert(PlayersTable, v.Name)
end

local playerdrop = LCPGF:Dropdown({
    Name = "Select Player",
    List = PlayersTable,
    Default = PlayersTable[1],
    Flag = "3423424234325245234",
    Callback = function(t)
        getgenv().SelectedPlayer = t
    end
})

game.Players.PlayerRemoving:Connect(function(plrD)
	table.remove(PlayersTable, table.find(plrD, plr.Name))
	wait(0.3)
	playerdrop:Set(PlayersTable, true)
end)

game.Players.PlayerAdded:Connect(function(plrD)
    table.insert(PlayersTable, plrD.Name)
    wait(0.3)
    playerdrop:Set(PlayersTable, true)
end)

LCPGF:Button({
    Name = "Teleport to Player",
    Callback = function()
        local Plrrr
        Plrrr = game.Players[getgenv().SelectedPlayer].Character.HumanoidRootPart.CFrame
        if Plrrr ~= nil then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Plrrr.X, Plrrr.Y, Plrrr.Z)
        end
    end
})

LCPGF:Button({
    Name = "Become A Manager",
    Callback = function()
        local f = game:GetService("Teams").Manager:GetPlayers()[1]
            if f.Character.Humanoid.Sit then
                SolarisLib:Notification("Failed", "Because Manager is Sitting", 5)
                return
            end
            yes = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame
            pcall(
                function()
                    local g = { [1] = "QuitJob", [2] = game:GetService("Players").LocalPlayer }
                    game:GetService("ReplicatedStorage").ManagerChannel:FireServer(unpack(g))
                    local g = { [1] = true }
                    workspace.MessageService.DialogButtonPressed:FireServer(unpack(g))
                    workspace.CurrentCamera.CameraSubject = game.Workspace.Street2
                    local g = { [1] = "GiveItem", [2] = 495886176 }
                    game:GetService("ReplicatedStorage").PlayerChannel:FireServer(unpack(g))
                    game.Players.LocalPlayer.Character.Humanoid.Name = 1
                    local h = game.Players.LocalPlayer.Character["1"]:Clone()
                    h.Parent = game.Players.LocalPlayer.Character
                    h.Name = "Humanoid"
                    wait(0.1)
                    game.Players.LocalPlayer.Character["1"]:Destroy()
                    workspace.CurrentCamera.CameraSubject = game.Workspace.Street2
                    game.Players.LocalPlayer.Character.Animate.Disabled = true
                    wait(0.1)
                    game.Players.LocalPlayer.Character.Animate.Disabled = false
                    game.Players.LocalPlayer.Character.Humanoid.DisplayDistanceType = "None"
                    wait(.20)
                    local i = "PaintBucket"
                    for j, k in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
                        if k:IsA("Tool") and k.Name == i then
                            k.Parent = game:GetService("Players").LocalPlayer.Character
                        end
                    end
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                    CFrame.new(f.Character.HumanoidRootPart.Position)
                    wait(.05)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                    CFrame.new(f.Character.HumanoidRootPart.Position)
                    wait(.05)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                    CFrame.new(f.Character.HumanoidRootPart.Position)
                    wait(.05)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                    CFrame.new(f.Character.HumanoidRootPart.Position)
                    wait(.05)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                    CFrame.new(f.Character.HumanoidRootPart.Position)
                    wait(.05)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                    CFrame.new(f.Character.HumanoidRootPart.Position)
                    wait(.05)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                    CFrame.new(f.Character.HumanoidRootPart.Position)
                    wait(2)
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame =
                    CFrame.new(11.819767951965, 1.1243584156036, 21.870401382446)
                    wait(.05)
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame =
                    CFrame.new(11.819767951965, 1.1243584156036, 21.870401382446)
                    wait(.05)
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame =
                    CFrame.new(11.819767951965, 1.1243584156036, 21.870401382446)
                    wait(2)
                    game.Players.LocalPlayer.Character:Destroy()
                    wait(2)
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame =
                    CFrame.new(23.7, 2.59944, 6.5)
                    wait(.50)
                    game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(
                        "Jumping"
                    )
                    wait(.20)
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = yes
                    game.Players.LocalPlayer.PlayerGui.MainGui.Menu.Backpack.Tools.Shortcut:Destroy()
                end
            )
    end
})

local LCPDF = LCP:Section("Default Functions")

LCPDF:Button(
    {
        Name = "BTools",
        Callback = function()
            local LocalPlayer = game:GetService("Players").LocalPlayer
            local mouse = LocalPlayer:GetMouse()
            local movetool = Instance.new("Tool", LocalPlayer.Backpack)
            local deletetool = Instance.new("Tool", LocalPlayer.Backpack)
            local undotool = Instance.new("Tool", LocalPlayer.Backpack)
            local identifytool = Instance.new("Tool", LocalPlayer.Backpack)
            local movedetect = false
            local movingpart = nil
            local movetransparency = 0
            if editedparts == nil then
                editedparts = {}
                parentfix = {}
                positionfix = {}
            end
            deletetool.Name = "Delete"
            undotool.Name = "Undo"
            identifytool.Name = "Identify"
            movetool.Name = "Move"
            undotool.CanBeDropped = false
            deletetool.CanBeDropped = false
            identifytool.CanBeDropped = false
            movetool.CanBeDropped = false
            undotool.RequiresHandle = false
            deletetool.RequiresHandle = false
            identifytool.RequiresHandle = false
            movetool.RequiresHandle = false
            local function createnotification(title, text)
                game:GetService("StarterGui"):SetCore(
                    "SendNotification",
                    {
                        Title = title,
                        Text = text,
                        Duration = 1
                    }
                )
            end
            deletetool.Activated:Connect(
                function()
                    createnotification("Delete Tool", "You have deleted " .. mouse.Target.Name)
                    table.insert(editedparts, mouse.Target)
                    table.insert(parentfix, mouse.Target.Parent)
                    table.insert(positionfix, mouse.Target.CFrame)
                    spawn(
                        function()
                            local deletedpart = mouse.Target
                            repeat
                                deletedpart.Anchored = true
                                deletedpart.CFrame = CFrame.new(1000000000, 1000000000, 1000000000)
                                wait()
                            until deletedpart.CFrame ~= CFrame.new(1000000000, 1000000000, 1000000000)
                        end
                    )
                end
            )
            undotool.Activated:Connect(
                function()
                    createnotification("Undo Tool", "You have undone " .. editedparts[#editedparts].Name)
                    editedparts[#editedparts].Parent = parentfix[#parentfix]
                    editedparts[#editedparts].CFrame = positionfix[#positionfix]
                    table.remove(positionfix, #positionfix)
                    table.remove(editedparts, #editedparts)
                    table.remove(parentfix, #parentfix)
                end
            )
            identifytool.Activated:Connect(
                function()
                    createnotification(
                        "Identify Tool",
                        "Instance: " .. mouse.Target.ClassName .. "\nName: " .. mouse.Target.Name
                    )
                end
            )
            movetool.Activated:Connect(
                function()
                    createnotification("Move Tool", "You are moving: " .. mouse.Target.Name)
                    movingpart = mouse.Target
                    movedetect = true
                    movingpart.CanCollide = false
                    movetransparency = movingpart.Transparency
                    movingpart.Transparency = 0.5
                    mouse.TargetFilter = movingpart
                    table.insert(editedparts, movingpart)
                    table.insert(parentfix, movingpart.Parent)
                    table.insert(positionfix, movingpart.CFrame)
                    movingpart.Transparency = movingpart.Transparency / 2
                    repeat
                        mouse.Move:Wait()
                        movingpart.CFrame = CFrame.new(mouse.Hit.p)
                    until movedetect == false
                end
            )
            movetool.Deactivated:Connect(
                function()
                    createnotification("Move Tool", "You have stopped moving: " .. mouse.Target.Name)
                    movingpart.CanCollide = true
                    movedetect = false
                    mouse.TargetFilter = nil
                    movingpart.Transparency = movetransparenc
                end
            )
        end
    }
)

LCPDF:Slider(
    {
        Name = "Set WalkSpeed",
        Minimum = 16,
        Maximum = 500,
        Default = 16,
        Increment = 1,
        Flag = "Speed",
        Callback = function(t)
            getgenv().speed = t
        end
    }
)

LCPDF:Toggle(
    {
        Name = "WalkSpeed",
        Default = false,
        Flag = "EnabledSpeed",
        Callback = function(t)
            getgenv().speedwb = t
            while getgenv().speedwb == true do
                wait()
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().speedwb and getgenv().speed or 16
            end
        end
    }
)

local infJump
LCPDF:Toggle(
    {
        Name = "InfJump",
        Default = false,
        Flag = "EnabledInfJump",
        Callback = function(t)
            getgenv().InfJump = t
            if infJump then
                infJump:Disconnect()
            end
            local infJumpDebounce = false
            infJump =
                game.UserInputService.JumpRequest:Connect(
                function()
                    if getgenv().InfJump == true then
                        if not infJumpDebounce then
                            infJumpDebounce = true
                            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(
                                Enum.HumanoidStateType.Jumping
                            )
                            wait()
                            infJumpDebounce = false
                        end
                    else
                        if infJump then
                            infJump:Disconnect()
                        end
                        infJumpDebounce = false
                    end
                end
            )
        end
    }
)

local cr = Window:Tab("Credits")
local sad = cr:Section("Yeah")

sad:Button(
    {
        Name = "Discord Server",
        Callback = function()
            local Request = http_request or syn and syn.request or request
            if Request then
                Request(
                    {
                        Url = "http://127.0.0.1:6463/rpc?v=1",
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json",
                            ["origin"] = "https://discord.com"
                        },
                        Body = game:GetService("HttpService"):JSONEncode(
                            {
                                ["args"] = {
                                    ["code"] = "ASeMjwW2qP"
                                },
                                ["cmd"] = "INVITE_BROWSER",
                                ["nonce"] = "."
                            }
                        )
                    }
                )
            else
                SolarisLib:Notification("Warning", "Your Exploit Shitty, Link Copied To Clipboard", 10)
                setclipboard("https://discord.gg/ASeMjwW2qP")
            end
        end
    }
)

sad:Poragraph(
    {
        Title = "Table Owner's And Dev's",
        Desc = "Owner's: \nMr.Xrer#0071 \nDev's: \nMr.Xrer#0071"
    }
)

local huyeyed = sad:Label("Random Words", Color3.fromRGB(44, 120, 224))

local randomwordsforsex = {
    "Dev: Mr.Xrer#0071",
    "Owner: Mr.Xrer#0071",
    "Mr.Xrer#0071 Want Sex With You",
    "I Love You My Swity",
    "LGBT ITS COOL?",
    "NezyGhoul My Wife)",
    "I Love NIGGERS",
    "My GirlFriend Its Leo",
    "Etc...",
    "I Fuck You In Your Ass Hole >:)"
}

-- While's

spawn(
    function()
        while true do
            wait(15)
            huyeyed:Set(randomwordsforsex[math.random(#randomwordsforsex)], Color3.fromRGB(44, 120, 224))
        end
    end
)

spawn(
    function()
        local currentTime = os.time()
        local elapsedTime = currentTime - startTime
        local formattedTime = formatTime(elapsedTime)
        while true do
            wait()
			CountMoney:Set("Paycheck Earned: " .. game:GetService("Players").LocalPlayer.PlayerGui.MainGui.Notifications.PaycheckCounter.PaycheckAmount.Text .. "$", Color3.fromRGB(255, 255, 255))
            PlayedTimes:Set("Played Time: " .. formattedTime, Color3.fromRGB(255, 255, 255))
            
            CountCashier:Set("Cashier: " .. getgenv().TableCountWork.Cashier, Color3.fromRGB(255, 255, 255))
            CountCook:Set("Cook: " .. getgenv().TableCountWork.Cook, Color3.fromRGB(255, 255, 255))
            CountDelivery:Set("Delivery: " .. getgenv().TableCountWork.Delivery, Color3.fromRGB(255, 255, 255))
			CountBoxing:Set("Boxing: " .. getgenv().TableCountWork.Boxing, Color3.fromRGB(255, 255, 255))
			CountSupplier:Set("Supplier: " .. getgenv().TableCountWork.Supplier, Color3.fromRGB(255, 255, 255))
            CountMoney:Set("Paycheck Earned: " .. game:GetService("Players").LocalPlayer.PlayerGui.MainGui.Notifications.PaycheckCounter.PaycheckAmount.Text .. "$", Color3.fromRGB(255, 255, 255))
        end
    end
)
