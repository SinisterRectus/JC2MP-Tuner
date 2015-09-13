class 'Tuner'

function Tuner:__init()

	self.enabled = false

	local vehicle = LocalPlayer:GetVehicle()
	if IsValid(vehicle) and vehicle:GetDriver() == LocalPlayer and vehicle:GetClass() == VehicleClass.Land then
		self.veh = vehicle
		self.trans = vehicle:GetTransmission()
		self.aero = vehicle:GetAerodynamics()
	end
	
	self.gui = {}

	self:InitVehicle()
	self:InitTransmission()
	self:InitAerodynamics()
	
	Events:Subscribe("KeyUp", self, self.KeyUp)
	Events:Subscribe("LocalPlayerEnterVehicle", self, self.EnterVehicle)
	Events:Subscribe("LocalPlayerExitVehicle", self, self.ExitVehicle)

end

function Tuner:InitVehicle()

	self.gui.veh = {}
	self.gui.veh.window = Window.Create()
	self.gui.veh.window:SetTitle("Vehicle")
	self.gui.veh.window:SetVisible(self.enabled)
	self.gui.veh.window:SetSize(Vector2(250, 295))
	self.gui.veh.window:SetPosition(Vector2(0.15 * Render.Width + 550, 0))
	self.gui.veh.window:Subscribe("Render", self, self.VehicleUpdate)
	
	self.gui.veh.labels = {}
	self.gui.veh.getters = {}
	self.gui.veh.setters = {}
	
	for i = 1,12 do
		table.insert(self.gui.veh.labels, Label.Create(self.gui.veh.window))
		table.insert(self.gui.veh.getters, Label.Create(self.gui.veh.window))
	end
	
	self.gui.veh.labels[1]:SetText("Name")
	self.gui.veh.labels[2]:SetText("Model ID")
	self.gui.veh.labels[3]:SetText("Template")	
	self.gui.veh.labels[4]:SetText("Class")
	self.gui.veh.labels[5]:SetText("Decal")
	self.gui.veh.labels[6]:SetText("Health")
	self.gui.veh.labels[7]:SetText("Driver")
	self.gui.veh.labels[8]:SetText("Mass")
	self.gui.veh.labels[9]:SetText("Top Speed")
	self.gui.veh.labels[10]:SetText("Max RPM")
	self.gui.veh.labels[11]:SetText("Current RPM")
	self.gui.veh.labels[12]:SetText("Torque")
	
	for i, label in ipairs(self.gui.veh.labels) do
		label:SetPosition(Vector2(2, 5 + 22 * (i - 1)))
		label:SizeToContents()
	end
	
	for i, getter in ipairs(self.gui.veh.getters) do
		getter:SetPosition(Vector2(90, 5 + 22 * (i - 1)))
		getter:SetSize(Vector2(150, 12))
	end

end

function Tuner:InitTransmission()

	self.gui.trans = {}

	self.gui.trans.window = Window.Create()
	self.gui.trans.window:SetTitle("Transmission")
	self.gui.trans.window:SetVisible(self.enabled)
	self.gui.trans.window:SetSize(Vector2(260, 515))
	self.gui.trans.window:SetPosition(Vector2(0.15 * Render.Width, 0))
	self.gui.trans.window:Subscribe("Render", self, self.TransmissionUpdate)
	
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
		label:SetPosition(Vector2(2, 5 + 22 * (i - 1)))
		label:SizeToContents()
	end
	
	for i, getter in ipairs(self.gui.trans.getters) do
		getter:SetPosition(Vector2(130, 5 + 22 * (i - 1)))
	end
	
	for i, setter in pairs(self.gui.trans.setters) do
		if setter.__type == "TextBoxNumeric" then
			setter:SetPosition(Vector2(190, 0 + 22 * (i - 1)))
			setter:SetWidth(55)
			setter:SetText("")
		else
			setter:SetPosition(Vector2(193, 2 + 22 * (i - 1)))
		end
	end

end

function Tuner:InitAerodynamics()

	self.gui.aero = {}

	self.gui.aero.window = Window.Create()
	self.gui.aero.window:SetTitle("Aerodynamics")
	self.gui.aero.window:SetVisible(self.enabled)
	self.gui.aero.window:SetSize(Vector2(235, 190))
	self.gui.aero.window:SetPosition(Vector2(0.15 * Render.Width + 290, 0))
	self.gui.aero.window:Subscribe("Render", self, self.AerodynamicsUpdate)
	
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
		label:SetPosition(Vector2(2, 5 + 22 * (i - 1)))
		label:SizeToContents()
	end
	
	for i, getter in ipairs(self.gui.aero.getters) do
		getter:SetPosition(Vector2(100, 5 + 22 * (i - 1)))
	end
	
	for i, setter in pairs(self.gui.aero.setters) do
		setter:SetPosition(Vector2(165, 0 + 22 * (i - 1)))
		setter:SetWidth(55)
		setter:SetText("")
	end

end

function Tuner:VehicleUpdate()

	if not self.veh then return end
	
	self.gui.veh.getters[1]:SetText(string.format("%s", self.veh:GetName()))
	self.gui.veh.getters[2]:SetText(string.format("%i", self.veh:GetModelId()))
	self.gui.veh.getters[3]:SetText(string.format("%s", self.veh:GetTemplate()))
	self.gui.veh.getters[4]:SetText(string.format("%s", self.veh:GetClass()))
	self.gui.veh.getters[5]:SetText(string.format("%s", self.veh:GetDecal()))
	self.gui.veh.getters[6]:SetText(string.format("%i", self.veh:GetHealth()))
	self.gui.veh.getters[7]:SetText(string.format("%s", self.veh:GetDriver()))
	self.gui.veh.getters[8]:SetText(string.format("%i", self.veh:GetMass()))
	self.gui.veh.getters[9]:SetText(string.format("%i", self.veh:GetTopSpeed()))
	self.gui.veh.getters[10]:SetText(string.format("%i", self.veh:GetMaxRPM()))
	self.gui.veh.getters[11]:SetText(string.format("%i", self.veh:GetRPM()))
	self.gui.veh.getters[12]:SetText(string.format("%i", self.veh:GetTorque()))

end

function Tuner:TransmissionUpdate()

	if not self.trans then return end

	self.gui.trans.getters[1]:SetText(string.format("%g", self.trans:GetUpshiftRPM()))
	self.gui.trans.getters[2]:SetText(string.format("%g", self.trans:GetDownshiftRPM()))
	self.gui.trans.getters[3]:SetText(string.format("%g", self.trans:GetMaxGear()))
	self.gui.trans.getters[4]:SetText(string.format("%s", self.trans:GetManual()))
	self.gui.trans.getters[5]:SetText(string.format("%g", self.trans:GetClutchDelayTime()))
	self.gui.trans.getters[6]:SetText(string.format("%g", self.trans:GetGear()))
	
	local gear_ratios = self.trans:GetGearRatios()
	for i = 1,6 do
		if gear_ratios[i] then
			self.gui.trans.getters[6 + i]:SetText(string.format("%g", gear_ratios[i]))
			self.gui.trans.getters[6 + i]:SetVisible(true)
			self.gui.trans.setters[6 + i]:SetVisible(true)
		else
			self.gui.trans.getters[6 + i]:SetVisible(false)
			self.gui.trans.setters[6 + i]:SetVisible(false)
		end
	end

	self.gui.trans.getters[13]:SetText(string.format("%g", self.trans:GetReverseGearRatio()))
	self.gui.trans.getters[14]:SetText(string.format("%g", self.trans:GetPrimaryTransmissionRatio()))
	
	local wheel_ratios = self.trans:GetWheelTorqueRatios()
	
	for i = 1,8 do
		if wheel_ratios[i] then
			self.gui.trans.getters[14 + i]:SetText(string.format("%g", wheel_ratios[i]))
			self.gui.trans.getters[14 + i]:SetVisible(true)
			self.gui.trans.setters[14 + i]:SetVisible(true)
		else
			self.gui.trans.getters[14 + i]:SetVisible(false)
			self.gui.trans.setters[14 + i]:SetVisible(false)
		end
	end

end

function Tuner:AerodynamicsUpdate()

	if not self.aero then return end

	self.gui.aero.getters[1]:SetText(string.format("%g", self.aero:GetAirDensity()))
	self.gui.aero.getters[2]:SetText(string.format("%g", self.aero:GetFrontalArea()))
	self.gui.aero.getters[3]:SetText(string.format("%g", self.aero:GetDragCoefficient()))
	self.gui.aero.getters[4]:SetText(string.format("%g", self.aero:GetLiftCoefficient()))
	
	local gravity = self.aero:GetExtraGravity()
	self.gui.aero.getters[5]:SetText(string.format("%f", gravity.x))
	self.gui.aero.getters[6]:SetText(string.format("%f", gravity.y))
	self.gui.aero.getters[7]:SetText(string.format("%f", gravity.z))

end

function Tuner:KeyUp(args)

	if args.key == string.byte("Z") and IsValid(self.veh) then
		self.enabled = not self.enabled
		self.gui.veh.window:SetVisible(self.enabled)
		self.gui.trans.window:SetVisible(self.enabled)
		self.gui.aero.window:SetVisible(self.enabled)
		Mouse:SetVisible(self.enabled)
	end
	
end

function Tuner:EnterVehicle(args)

	if args.is_driver and args.vehicle:GetClass() == VehicleClass.Land then
		self.veh = args.vehicle
		self.trans = args.vehicle:GetTransmission()
		self.aero = args.vehicle:GetAerodynamics()
	end
	
end

function Tuner:ExitVehicle(args)

	self.enabled = false
	self.gui.veh.window:SetVisible(self.enabled)
	self.gui.trans.window:SetVisible(self.enabled)
	self.gui.aero.window:SetVisible(self.enabled)
	Mouse:SetVisible(self.enabled)
	self.veh = nil
	self.trans = nil
	self.aero = nil
	
end

Tuner = Tuner()
