-- Written by Sinister Rectus - http://www.jc-mp.com/forums/index.php?action=profile;u=73431

class 'Tuner'

function Tuner:__init()

	self:InitGUI()

	local vehicle = LocalPlayer:GetVehicle()
	if IsValid(vehicle) and vehicle:GetDriver() == LocalPlayer and vehicle:GetClass() == VehicleClass.Land then
		self:InitVehicle(vehicle)
	end

	Events:Subscribe("KeyUp", self, self.KeyUp)
	Events:Subscribe("LocalPlayerEnterVehicle", self, self.EnterVehicle)
	Events:Subscribe("LocalPlayerExitVehicle", self, self.ExitVehicle)
	Events:Subscribe("EntityDespawn", self, self.VehicleDespawn)

end

function Tuner:InitGUI()

	self.gui = {veh = {}, trans = {}, aero = {}, susp = {}}
	
	self.gui.window = Window.Create()
	self.gui.window:SetVisible(false)
	self.gui.window:SetTitle("Vehicle Tuner")
	self.gui.window:SetPosition(Vector2(0.15 * Render.Width, 0.02 * Render.Height))
	
	self.gui.tabs = TabControl.Create(self.gui.window)
	self.gui.tabs:SetDock(GwenPosition.Fill)
	
	self.gui.veh.window = BaseWindow.Create(self.gui.window)
	self.gui.trans.window = BaseWindow.Create(self.gui.window)
	self.gui.aero.window = BaseWindow.Create(self.gui.window)
	self.gui.susp.window = BaseWindow.Create(self.gui.window)
	
	self.gui.veh.window:Subscribe("Render", self, self.VehicleUpdate)
	self.gui.trans.window:Subscribe("Render", self, self.TransmissionUpdate)
	self.gui.aero.window:Subscribe("Render", self, self.AerodynamicsUpdate)
	self.gui.susp.window:Subscribe("Render", self, self.SuspensionUpdate)
	
	self.gui.veh.button = self.gui.tabs:AddPage("Vehicle", self.gui.veh.window)
	self.gui.veh.button:Subscribe("Press", function()
		self.gui.window:SetSize(Vector2(315, 465))
	end)
	
	self.gui.trans.button = self.gui.tabs:AddPage("Transmission", self.gui.trans.window)
	self.gui.trans.button:Subscribe("Press", function()
		local gears = self.trans:GetMaxGear()
		for i = 7, 7 + gears - 1 do
			self.gui.trans.getters[i]:Show()
			self.gui.trans.setters[i]:Show()
		end
		for i = 7 + gears, 12 do
			self.gui.trans.getters[i]:Hide()
			self.gui.trans.setters[i]:Hide()
		end
		local count = self.veh:GetWheelCount()
		for i = 15, 15 + count - 1 do
			self.gui.trans.getters[i]:Show()
			self.gui.trans.setters[i]:Show()
		end
		for i = 15 + count, 22 do
			self.gui.trans.getters[i]:Hide()
			self.gui.trans.setters[i]:Hide()
		end
		self.gui.window:SetSize(Vector2(315, 555 - 22 * (8 - count)))	
	end)
	
	self.gui.aero.button = self.gui.tabs:AddPage("Aerodynamics", self.gui.aero.window)
	self.gui.aero.button:Subscribe("Press", function()
		self.gui.window:SetSize(Vector2(315, 224))
	end)

	self.gui.susp.button = self.gui.tabs:AddPage("Suspension", self.gui.susp.window)
	self.gui.susp.button:Subscribe("Press", function()
		local count = self.veh:GetWheelCount()
		for wheel = 1, count do
			for _,getter in ipairs(self.gui.susp[wheel].getters) do
				getter:Show()
			end
			for _,setter in ipairs(self.gui.susp[wheel].setters) do
				setter:Show()
			end
		end
		for wheel = count + 1, 8 do
			for _,getter in ipairs(self.gui.susp[wheel].getters) do
				getter:Hide()
			end
			for _,setter in ipairs(self.gui.susp[wheel].setters) do
				setter:Hide()
			end
		end
		self.gui.window:SetSize(Vector2(150 + 80 * count, 510))
	end)
	
	self:InitVehicleGUI()
	self:InitTransmissionGUI()
	self:InitAerodynamicsGUI()
	self:InitSuspensionGUI()

end

function Tuner:InitVehicleGUI()
	
	self.gui.veh.labels = {}
	self.gui.veh.getters = {}
	self.gui.veh.setters = {}
	
	for i = 1,18 do
		table.insert(self.gui.veh.labels, Label.Create(self.gui.veh.window))
		table.insert(self.gui.veh.getters, Label.Create(self.gui.veh.window))
	end
	
	self.gui.veh.labels[1]:SetText("Name")
	self.gui.veh.labels[2]:SetText("Driver")
	self.gui.veh.labels[3]:SetText("Model ID")
	self.gui.veh.labels[4]:SetText("Class")
	self.gui.veh.labels[5]:SetText("Template")	
	self.gui.veh.labels[6]:SetText("Decal")
	self.gui.veh.labels[7]:SetText("Health")
	self.gui.veh.labels[8]:SetText("Mass")
	self.gui.veh.labels[9]:SetText("Wheel Count")
	self.gui.veh.labels[10]:SetText("Max RPM")
	self.gui.veh.labels[11]:SetText("Current RPM")
	self.gui.veh.labels[12]:SetText("Torque")
	self.gui.veh.labels[13]:SetText("Peak Torque")
	self.gui.veh.labels[14]:SetText("Wheel Torque")
	self.gui.veh.labels[15]:SetText("Top Speed")
	self.gui.veh.labels[16]:SetText("Current Speed")
	self.gui.veh.labels[17]:SetText("Peak Speed")
	self.gui.veh.labels[18]:SetText("0-100 km/h")
	
	for i, label in ipairs(self.gui.veh.labels) do
		label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
		label:SizeToContents()
	end
	
	for i, getter in ipairs(self.gui.veh.getters) do
		getter:SetPosition(Vector2(120, 5 + 22 * (i - 1)))
		getter:SetSize(Vector2(200, 12))
	end

end

function Tuner:InitTransmissionGUI()
	
	self.gui.trans.labels = {}
	self.gui.trans.getters = {}
	self.gui.trans.setters = {}
	
	for i = 1,22 do
		table.insert(self.gui.trans.labels, Label.Create(self.gui.trans.window))
		table.insert(self.gui.trans.getters, Label.Create(self.gui.trans.window))
	end
	
	self.gui.trans.labels[1]:SetText("Upshift RPM")
	self.gui.trans.labels[2]:SetText("Downshift RPM")
	self.gui.trans.labels[3]:SetText("Max Gear")
	self.gui.trans.labels[4]:SetText("Is Manual")
	self.gui.trans.labels[5]:SetText("Clutch Delay")
	self.gui.trans.labels[6]:SetText("Current Gear")
	self.gui.trans.labels[7]:SetText("1st Gear Ratio")
	self.gui.trans.labels[8]:SetText("2nd Gear Ratio")
	self.gui.trans.labels[9]:SetText("3rd Gear Ratio")
	self.gui.trans.labels[10]:SetText("4th Gear Ratio")
	self.gui.trans.labels[11]:SetText("5th Gear Ratio")
	self.gui.trans.labels[12]:SetText("6th Gear Ratio")
	self.gui.trans.labels[13]:SetText("Reverse Ratio")
	self.gui.trans.labels[14]:SetText("Primary Ratio")
	self.gui.trans.labels[15]:SetText("Wheel 1 Torque Ratio")
	self.gui.trans.labels[16]:SetText("Wheel 2 Torque Ratio")
	self.gui.trans.labels[17]:SetText("Wheel 3 Torque Ratio")
	self.gui.trans.labels[18]:SetText("Wheel 4 Torque Ratio")
	self.gui.trans.labels[19]:SetText("Wheel 5 Torque Ratio")
	self.gui.trans.labels[20]:SetText("Wheel 6 Torque Ratio")
	self.gui.trans.labels[21]:SetText("Wheel 7 Torque Ratio")
	self.gui.trans.labels[22]:SetText("Wheel 8 Torque Ratio")
	
	self.gui.trans.setters[4] = CheckBox.Create(self.gui.trans.window)
	self.gui.trans.setters[4]:Subscribe("CheckChanged", function(args)
		self.trans:SetManual(args:GetChecked())
	end)
	
	self.gui.trans.setters[5] = TextBoxNumeric.Create(self.gui.trans.window)
	self.gui.trans.setters[5]:Subscribe("ReturnPressed", function(args)
		self.trans:SetClutchDelayTime(args:GetValue())
		args:SetText("")
	end)
	
	self.gui.trans.setters[6] = TextBoxNumeric.Create(self.gui.trans.window)
	self.gui.trans.setters[6]:Subscribe("ReturnPressed", function(args)
		self.trans:SetGear(args:GetValue())
		args:SetText("")
	end)
	
	for i = 7,12 do 
		self.gui.trans.setters[i] = TextBoxNumeric.Create(self.gui.trans.window)
		self.gui.trans.setters[i]:Subscribe("ReturnPressed", function(args)
			local gear_ratios = self.trans:GetGearRatios()
			gear_ratios[i - 6] = args:GetValue()
			self.trans:SetGearRatios(gear_ratios)
			args:SetText("")
		end)
	end
	
	self.gui.trans.setters[13] = TextBoxNumeric.Create(self.gui.trans.window)
	self.gui.trans.setters[13]:Subscribe("ReturnPressed", function(args)
		self.trans:SetReverseGearRatio(args:GetValue())
		args:SetText("")
	end)	
	
	self.gui.trans.setters[14] = TextBoxNumeric.Create(self.gui.trans.window)
	self.gui.trans.setters[14]:Subscribe("ReturnPressed", function(args)
		self.trans:SetPrimaryTransmissionRatio(args:GetValue())
		args:SetText("")
	end)
	
	for i = 15,22 do 
		self.gui.trans.setters[i] = TextBoxNumeric.Create(self.gui.trans.window)
		self.gui.trans.setters[i]:Subscribe("ReturnPressed", function(args)
			local wheel_ratios = self.trans:GetWheelTorqueRatios()
			wheel_ratios[i - 14] = args:GetValue()
			self.trans:SetWheelTorqueRatios(wheel_ratios)
			args:SetText("")
		end)
	end

	for i, label in ipairs(self.gui.trans.labels) do
		label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
		label:SizeToContents()
	end
	
	for i, getter in ipairs(self.gui.trans.getters) do
		getter:SetPosition(Vector2(150, 5 + 22 * (i - 1)))
	end
	
	for i, setter in pairs(self.gui.trans.setters) do
		if setter.__type == "TextBoxNumeric" then
			setter:SetPosition(Vector2(225, 0 + 22 * (i - 1)))
			setter:SetWidth(57)
			setter:SetText("")
		else
			setter:SetPosition(Vector2(228, 2 + 22 * (i - 1)))
		end
	end

end

function Tuner:InitAerodynamicsGUI()
	
	self.gui.aero.labels = {}
	self.gui.aero.getters = {}
	self.gui.aero.setters = {}
	
	for i = 1,7 do
		table.insert(self.gui.aero.labels, Label.Create(self.gui.aero.window))
		table.insert(self.gui.aero.getters, Label.Create(self.gui.aero.window))
		table.insert(self.gui.aero.setters, TextBoxNumeric.Create(self.gui.aero.window))
	end
	
	self.gui.aero.labels[1]:SetText("Air Density")
	self.gui.aero.labels[2]:SetText("Frontal Area")
	self.gui.aero.labels[3]:SetText("Drag Coeff")
	self.gui.aero.labels[4]:SetText("Lift Coeff")
	self.gui.aero.labels[5]:SetText("Extra Gravity X")
	self.gui.aero.labels[6]:SetText("Extra Gravity Y")
	self.gui.aero.labels[7]:SetText("Extra Gravity Z")
	
	self.gui.aero.setters[1]:Subscribe("ReturnPressed", function(args)
		self.aero:SetAirDensity(args:GetValue())
		args:SetText("")		
	end)
	
	self.gui.aero.setters[2]:Subscribe("ReturnPressed", function(args) 
		self.aero:SetFrontalArea(args:GetValue())
		args:SetText("")		
	end)
	
	self.gui.aero.setters[3]:Subscribe("ReturnPressed", function(args) 
		self.aero:SetDragCoefficient(args:GetValue())
		args:SetText("")		
	end)
	
	self.gui.aero.setters[4]:Subscribe("ReturnPressed", function(args) 
		self.aero:SetLiftCoefficient(args:GetValue())
		args:SetText("")		
	end)
	
	self.gui.aero.setters[5]:Subscribe("ReturnPressed", function(args) 
		local gravity = self.aero:GetExtraGravity()
		self.aero:SetExtraGravity(Vector3(args:GetValue(), gravity.y, gravity.z))
		args:SetText("")		
	end)
	
	self.gui.aero.setters[6]:Subscribe("ReturnPressed", function(args) 
		local gravity = self.aero:GetExtraGravity()
		self.aero:SetExtraGravity(Vector3(gravity.x, args:GetValue(), gravity.z))
		args:SetText("")		
	end)
	
	self.gui.aero.setters[7]:Subscribe("ReturnPressed", function(args) 
		local gravity = self.aero:GetExtraGravity()
		self.aero:SetExtraGravity(Vector3(gravity.x, gravity.y, args:GetValue()))
		args:SetText("")		
	end)
	
	for i, label in ipairs(self.gui.aero.labels) do
		label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
		label:SizeToContents()
	end
	
	for i, getter in ipairs(self.gui.aero.getters) do
		getter:SetPosition(Vector2(150, 5 + 22 * (i - 1)))
	end
	
	for i, setter in pairs(self.gui.aero.setters) do
		setter:SetPosition(Vector2(225, 0 + 22 * (i - 1)))
		setter:SetWidth(57)
		setter:SetText("")
	end

end

function Tuner:InitSuspensionGUI()
	
	self.gui.susp.labels = {}
	
	for i = 1,20 do
		table.insert(self.gui.susp.labels, Label.Create(self.gui.susp.window))
	end
	
	for wheel = 1,8 do
		self.gui.susp[wheel] = {}
		self.gui.susp[wheel] = {}
		self.gui.susp[wheel].getters = {}
		self.gui.susp[wheel].setters = {}
		for i = 1,10 do
			table.insert(self.gui.susp[wheel].getters, Label.Create(self.gui.susp.window))
			table.insert(self.gui.susp[wheel].setters, TextBoxNumeric.Create(self.gui.susp.window))
		end
	end
	
	self.gui.susp.labels[1]:SetText("Length")
	self.gui.susp.labels[2]:SetText("Strength")
	self.gui.susp.labels[3]:SetText("Chassis Direction X")
	self.gui.susp.labels[4]:SetText("Chassis Direction Y")
	self.gui.susp.labels[5]:SetText("Chassis Direction Z")
	self.gui.susp.labels[6]:SetText("Chassis Position X")
	self.gui.susp.labels[7]:SetText("Chassis Position Y")
	self.gui.susp.labels[8]:SetText("Chassis Position Z")
	self.gui.susp.labels[9]:SetText("Damping Compression")
	self.gui.susp.labels[10]:SetText("Damping Relaxation")
	
	self.gui.susp.labels[11]:SetText("Length")
	self.gui.susp.labels[12]:SetText("Strength")
	self.gui.susp.labels[13]:SetText("Chassis Direction X")
	self.gui.susp.labels[14]:SetText("Chassis Direction Y")
	self.gui.susp.labels[15]:SetText("Chassis Direction Z")
	self.gui.susp.labels[16]:SetText("Chassis Position X")
	self.gui.susp.labels[17]:SetText("Chassis Position Y")
	self.gui.susp.labels[18]:SetText("Chassis Position Z")
	self.gui.susp.labels[19]:SetText("Damping Compression")
	self.gui.susp.labels[20]:SetText("Damping Relaxation")

	for i, label in ipairs(self.gui.susp.labels) do
		label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
		label:SizeToContents()
	end
	
	for wheel in ipairs(self.gui.susp) do
		for i, getter in ipairs(self.gui.susp[wheel].getters) do
			getter:SetPosition(Vector2(150 + 75 * (wheel - 1), 5 + 22 * (i - 1)))
			getter:SetWidth(70)
		end
	end
	
	for wheel,v in ipairs(self.gui.susp) do
	
		v.setters[1]:Subscribe("ReturnPressed", function(args)
			self.susp:SetLength(wheel, args:GetValue())
			args:SetText("")
		end)
		
		v.setters[2]:Subscribe("ReturnPressed", function(args)
			self.susp:SetStrength(wheel, args:GetValue())
			args:SetText("")
		end)
		
		v.setters[3]:Subscribe("ReturnPressed", function(args)
			local direction = self.susp:GetChassisDirection(wheel)
			self.susp:SetChassisDirection(wheel, Vector3(args:GetValue(), direction.y, direction.z))
			args:SetText("")
		end)
		
		v.setters[4]:Subscribe("ReturnPressed", function(args)
			local direction = self.susp:GetChassisDirection(wheel)
			self.susp:SetChassisDirection(wheel, Vector3(direction.x, args:GetValue(), direction.z))
			args:SetText("")
		end)
		
		v.setters[5]:Subscribe("ReturnPressed", function(args)
			local direction = self.susp:GetChassisDirection(wheel)
			self.susp:SetChassisDirection(wheel, Vector3(direction.x, direction.y, args:GetValue()))
			args:SetText("")
		end)
		
		v.setters[6]:Subscribe("ReturnPressed", function(args)
			local position = self.susp:GetChassisPosition(wheel)
			self.susp:SetChassisPosition(wheel, Vector3(args:GetValue(), position.y, position.z))
			args:SetText("")
		end)
		
		v.setters[7]:Subscribe("ReturnPressed", function(args)
			local position = self.susp:GetChassisPosition(wheel)
			self.susp:SetChassisPosition(wheel, Vector3(position.x, args:GetValue(), position.z))
			args:SetText("")
		end)
		
		v.setters[8]:Subscribe("ReturnPressed", function(args)
			local position = self.susp:GetChassisPosition(wheel)
			self.susp:SetChassisPosition(wheel, Vector3(position.x, position.y, args:GetValue()))
			args:SetText("")
		end)
	
		v.setters[9]:Subscribe("ReturnPressed", function(args)
			self.susp:SetDampingCompression(wheel, args:GetValue())
			args:SetText("")
		end)

		v.setters[10]:Subscribe("ReturnPressed", function(args)
			self.susp:SetDampingRelaxation(wheel, args:GetValue())
			args:SetText("")
		end)		
	
		for i, setter in ipairs(self.gui.susp[wheel].setters) do
			setter:SetPosition(Vector2(150 + 75 * (wheel - 1), 220 + 22 * (i - 1)))
			setter:SetWidth(57)
			setter:SetText("")
		end
		
	end	
	
end

function Tuner:InitVehicle(vehicle)

	self.veh = vehicle
	self.trans = vehicle:GetTransmission()
	self.aero = vehicle:GetAerodynamics()
	self.susp = vehicle:GetSuspension()
	
	local f = string.format
	self.gui.veh.getters[1]:SetText(f("%s", vehicle:GetName()))
	self.gui.veh.getters[2]:SetText(f("%s", vehicle:GetDriver()))
	self.gui.veh.getters[3]:SetText(f("%i", vehicle:GetModelId()))
	self.gui.veh.getters[4]:SetText(f("%i", vehicle:GetClass()))
	self.gui.veh.getters[5]:SetText(f("%s", vehicle:GetTemplate()))
	self.gui.veh.getters[6]:SetText(f("%s", vehicle:GetDecal()))
	self.gui.veh.getters[9]:SetText(f("%i", vehicle:GetWheelCount()))
	self.gui.veh.getters[10]:SetText(f("%i", vehicle:GetMaxRPM()))
	self.gui.veh.getters[15]:SetText(f("%i m/s", vehicle:GetTopSpeed()))
	
end

function Tuner:VehicleUpdate()

	if not self.veh then return end
	
	local f = string.format 
	local t = self.veh:GetTorque()
	local ratios = self.trans:GetGearRatios()
	local s = self.veh:GetLinearVelocity():Length()
	local wt = t * self.trans:GetPrimaryTransmissionRatio() * ratios[self.trans:GetGear()]

	self.gui.veh.getters[7]:SetText(f("%i%s", self.veh:GetHealth() * 100, "%"))
	self.gui.veh.getters[8]:SetText(f("%i kg", self.veh:GetMass()))
	self.gui.veh.getters[11]:SetText(f("%i", self.veh:GetRPM()))
	self.gui.veh.getters[12]:SetText(f("%i N", t))
	
	self.peak_t = self.peak_t or 0
	if t > self.peak_t then 
		self.peak_t = t
		self.gui.veh.getters[13]:SetText(f("%i N", self.peak_t))
	end

	self.gui.veh.getters[14]:SetText(f("%i N", wt))
	self.gui.veh.getters[16]:SetText(f("%i m/s, %i, km/h, %i mi/h", s, s * 3.6, s * 2.234))
	
	self.peak_s = self.peak_s or 0
	if s > self.peak_s then
		self.peak_s = s
		self.gui.veh.getters[17]:SetText(f("%i m/s, %i km/h, %i mi/h", self.peak_s, self.peak_s * 3.6, self.peak_s * 2.234))
	end

	if s < 0.1 then 
		self.timer = Timer()
		self.gui.veh.getters[18]:SetText("")
	elseif self.timer and s > 100 / 3.6 then
		self.time = self.timer:GetSeconds()
		self.gui.veh.getters[18]:SetText(f("%.3f s", self.time))
		self.timer = nil
	end

end

function Tuner:TransmissionUpdate()

	if not self.trans then return end
	
	local f = string.format
	
	self.gui.trans.setters[4]:SetChecked(self.trans:GetManual())

	self.gui.trans.getters[1]:SetText(f("%i", self.trans:GetUpshiftRPM()))
	self.gui.trans.getters[2]:SetText(f("%i", self.trans:GetDownshiftRPM()))
	self.gui.trans.getters[3]:SetText(f("%i", self.trans:GetMaxGear()))
	self.gui.trans.getters[4]:SetText(f("%s", self.trans:GetManual()))
	self.gui.trans.getters[5]:SetText(f("%g", self.trans:GetClutchDelayTime()))
	self.gui.trans.getters[6]:SetText(f("%i", self.trans:GetGear()))
	
	local gear_ratios = self.trans:GetGearRatios()
	for wheel, ratio in ipairs(gear_ratios) do
		self.gui.trans.getters[6 + wheel]:SetText(f("%g", ratio))
	end

	self.gui.trans.getters[13]:SetText(f("%g", self.trans:GetReverseGearRatio()))
	self.gui.trans.getters[14]:SetText(f("%g", self.trans:GetPrimaryTransmissionRatio()))
	
	local wheel_ratios = self.trans:GetWheelTorqueRatios()
	for wheel, ratio in ipairs(wheel_ratios) do
		self.gui.trans.getters[14 + wheel]:SetText(f("%g", ratio))
	end

end

function Tuner:AerodynamicsUpdate()

	if not self.aero then return end
	
	local f = string.format

	self.gui.aero.getters[1]:SetText(f("%g", self.aero:GetAirDensity()))
	self.gui.aero.getters[2]:SetText(f("%g", self.aero:GetFrontalArea()))
	self.gui.aero.getters[3]:SetText(f("%g", self.aero:GetDragCoefficient()))
	self.gui.aero.getters[4]:SetText(f("%g", self.aero:GetLiftCoefficient()))
	
	local gravity = self.aero:GetExtraGravity()
	self.gui.aero.getters[5]:SetText(f("%.6f", gravity.x))
	self.gui.aero.getters[6]:SetText(f("%.6f", gravity.y))
	self.gui.aero.getters[7]:SetText(f("%.6f", gravity.z))

end

function Tuner:SuspensionUpdate()

	if not self.susp then return end

	local f = string.format
	
	for wheel = 1, self.veh:GetWheelCount() do

		self.gui.susp[wheel].getters[1]:SetText(f("%g", self.susp:GetLength(wheel)))
		self.gui.susp[wheel].getters[2]:SetText(f("%g", self.susp:GetStrength(wheel)))
		
		local direction = self.susp:GetChassisDirection(wheel)
		self.gui.susp[wheel].getters[3]:SetText(f("%.6f", direction.x))
		self.gui.susp[wheel].getters[4]:SetText(f("%.6f", direction.y))
		self.gui.susp[wheel].getters[5]:SetText(f("%.6f", direction.z))
		
		local position = self.susp:GetChassisPosition(wheel)
		self.gui.susp[wheel].getters[6]:SetText(f("%.6f", position.x))
		self.gui.susp[wheel].getters[7]:SetText(f("%.6f", position.y))
		self.gui.susp[wheel].getters[8]:SetText(f("%.6f", position.z))
		
		self.gui.susp[wheel].getters[9]:SetText(f("%g", self.susp:GetDampingCompression(wheel)))
		self.gui.susp[wheel].getters[10]:SetText(f("%g", self.susp:GetDampingRelaxation(wheel)))

	end

end

function Tuner:KeyUp(args)

	if args.key == string.byte("Z") and IsValid(self.veh) then
		local visible = self.gui.window:GetVisible()
		self.gui.window:SetVisible(not visible)
		Mouse:SetVisible(not visible)
		self.gui.tabs:SetCurrentTab(self.gui.veh.button)
		self.timer = nil
	end
	
end

function Tuner:EnterVehicle(args)

	if args.is_driver and args.vehicle:GetClass() == VehicleClass.Land then
		self:InitVehicle(args.vehicle)
	end
	
end

function Tuner:ExitVehicle(args)

	if self.veh and args.vehicle == self.veh then
		self:Disable()
	end
	
end

function Tuner:VehicleDespawn(args)

	if args.entity.__type == "Vehicle" and args.entity == self.veh then
		self:Disable()
	end
	
end

function Tuner:Disable()

	self.gui.window:SetVisible(false)
	Mouse:SetVisible(false)

	self.veh = nil
	self.trans = nil
	self.aero = nil
	self.susp = nil
	self.peak_s = nil
	self.peak_t = nil
	self.time = nil
	self.timer = nil

end

Tuner = Tuner()
