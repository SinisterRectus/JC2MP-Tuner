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

	local veh = {labels = {}, getters = {}}
	local trans = {labels = {}, getters = {}, setters = {}}
	local aero = {labels = {}, getters = {}, setters = {}}
	local susp = {labels = {}}

	local window = Window.Create()
	window:SetVisible(false)
	window:SetTitle("Vehicle Tuner")
	window:SetPosition(Vector2(0.15 * Render.Width, 0.02 * Render.Height))

	local tabs = TabControl.Create(window)
	tabs:SetDock(GwenPosition.Fill)

	veh.window = BaseWindow.Create(window)
	trans.window = BaseWindow.Create(window)
	aero.window = BaseWindow.Create(window)
	susp.window = BaseWindow.Create(window)

	veh.window:Subscribe("Render", self, self.VehicleUpdate)
	trans.window:Subscribe("Render", self, self.TransmissionUpdate)
	aero.window:Subscribe("Render", self, self.AerodynamicsUpdate)
	susp.window:Subscribe("Render", self, self.SuspensionUpdate)

	veh.button = tabs:AddPage("Vehicle", veh.window)
	veh.button:Subscribe("Press", function()
		window:SetSize(Vector2(315, 465))
	end)

	trans.button = tabs:AddPage("Transmission", trans.window)
	trans.button:Subscribe("Press", function()
		local gears = self.trans:GetMaxGear()
		for i = 7, 7 + gears - 1 do
			trans.getters[i]:Show()
			trans.setters[i]:Show()
		end
		for i = 7 + gears, 12 do
			trans.getters[i]:Hide()
			trans.setters[i]:Hide()
		end
		local count = self.veh:GetWheelCount()
		for i = 15, 15 + count - 1 do
			trans.getters[i]:Show()
			trans.setters[i]:Show()
		end
		for i = 15 + count, 22 do
			trans.getters[i]:Hide()
			trans.setters[i]:Hide()
		end
		window:SetSize(Vector2(315, 555 - 22 * (8 - count)))
	end)

	aero.button = tabs:AddPage("Aerodynamics", aero.window)
	aero.button:Subscribe("Press", function()
		window:SetSize(Vector2(315, 224))
	end)

	susp.button = tabs:AddPage("Suspension", susp.window)
	susp.button:Subscribe("Press", function()
		local count = self.veh:GetWheelCount()
		for wheel = 1, count do
			for _,getter in ipairs(susp[wheel].getters) do
				getter:Show()
			end
			for _,setter in ipairs(susp[wheel].setters) do
				setter:Show()
			end
		end
		for wheel = count + 1, 8 do
			for _,getter in ipairs(susp[wheel].getters) do
				getter:Hide()
			end
			for _,setter in ipairs(susp[wheel].setters) do
				setter:Hide()
			end
		end
		window:SetSize(Vector2(150 + 80 * count, 510))
	end)

	self.gui = {
		window = window,
		tabs = tabs,
		veh = veh,
		trans = trans,
		aero = aero,
		susp = susp,
	}

	self:InitVehicleGUI()
	self:InitTransmissionGUI()
	self:InitAerodynamicsGUI()
	self:InitSuspensionGUI()

end

function Tuner:InitVehicleGUI()

	local veh = self.gui.veh
	local window = veh.window
	local labels = veh.labels
	local getters = veh.getters

	for i = 1, 18 do
		labels[i] = Label.Create(window)
		getters[i] = Label.Create(window)
	end

	labels[1]:SetText("Name")
	labels[2]:SetText("Driver")
	labels[3]:SetText("Model ID")
	labels[4]:SetText("Class")
	labels[5]:SetText("Template")
	labels[6]:SetText("Decal")
	labels[7]:SetText("Health")
	labels[8]:SetText("Mass")
	labels[9]:SetText("Wheel Count")
	labels[10]:SetText("Max RPM")
	labels[11]:SetText("Current RPM")
	labels[12]:SetText("Torque")
	labels[13]:SetText("Peak Torque")
	labels[14]:SetText("Wheel Torque")
	labels[15]:SetText("Top Speed")
	labels[16]:SetText("Current Speed")
	labels[17]:SetText("Peak Speed")
	labels[18]:SetText("0-100 km/h")

	for i, label in ipairs(labels) do
		label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
		label:SizeToContents()
	end

	for i, getter in ipairs(getters) do
		getter:SetPosition(Vector2(120, 5 + 22 * (i - 1)))
		getter:SetSize(Vector2(200, 12))
	end

end

function Tuner:InitTransmissionGUI()

	local trans = self.gui.trans
	local window = trans.window
	local labels = trans.labels
	local getters = trans.getters
	local setters = trans.setters

	for i = 1, 22 do
		labels[i] = Label.Create(window)
		getters[i] = Label.Create(window)
	end

	labels[1]:SetText("Upshift RPM")
	labels[2]:SetText("Downshift RPM")
	labels[3]:SetText("Max Gear")
	labels[4]:SetText("Is Manual")
	labels[5]:SetText("Clutch Delay")
	labels[6]:SetText("Current Gear")
	labels[7]:SetText("1st Gear Ratio")
	labels[8]:SetText("2nd Gear Ratio")
	labels[9]:SetText("3rd Gear Ratio")
	labels[10]:SetText("4th Gear Ratio")
	labels[11]:SetText("5th Gear Ratio")
	labels[12]:SetText("6th Gear Ratio")
	labels[13]:SetText("Reverse Ratio")
	labels[14]:SetText("Primary Ratio")
	labels[15]:SetText("Wheel 1 Torque Ratio")
	labels[16]:SetText("Wheel 2 Torque Ratio")
	labels[17]:SetText("Wheel 3 Torque Ratio")
	labels[18]:SetText("Wheel 4 Torque Ratio")
	labels[19]:SetText("Wheel 5 Torque Ratio")
	labels[20]:SetText("Wheel 6 Torque Ratio")
	labels[21]:SetText("Wheel 7 Torque Ratio")
	labels[22]:SetText("Wheel 8 Torque Ratio")

	setters[4] = CheckBox.Create(window)
	setters[4]:Subscribe("CheckChanged", function(args)
		self.trans:SetManual(args:GetChecked())
	end)

	setters[5] = TextBoxNumeric.Create(window)
	setters[5]:Subscribe("ReturnPressed", function(args)
		self.trans:SetClutchDelayTime(args:GetValue())
		args:SetText("")
	end)

	setters[6] = TextBoxNumeric.Create(window)
	setters[6]:Subscribe("ReturnPressed", function(args)
		self.trans:SetGear(args:GetValue())
		args:SetText("")
	end)

	for i = 7, 12 do
		setters[i] = TextBoxNumeric.Create(window)
		setters[i]:Subscribe("ReturnPressed", function(args)
			local gear_ratios = self.trans:GetGearRatios()
			gear_ratios[i - 6] = args:GetValue()
			self.trans:SetGearRatios(gear_ratios)
			args:SetText("")
		end)
	end

	setters[13] = TextBoxNumeric.Create(window)
	setters[13]:Subscribe("ReturnPressed", function(args)
		self.trans:SetReverseGearRatio(args:GetValue())
		args:SetText("")
	end)

	setters[14] = TextBoxNumeric.Create(window)
	setters[14]:Subscribe("ReturnPressed", function(args)
		self.trans:SetPrimaryTransmissionRatio(args:GetValue())
		args:SetText("")
	end)

	for i = 15, 22 do
		setters[i] = TextBoxNumeric.Create(window)
		setters[i]:Subscribe("ReturnPressed", function(args)
			local wheel_ratios = self.trans:GetWheelTorqueRatios()
			wheel_ratios[i - 14] = args:GetValue()
			self.trans:SetWheelTorqueRatios(wheel_ratios)
			args:SetText("")
		end)
	end

	for i, label in ipairs(labels) do
		label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
		label:SizeToContents()
	end

	for i, getter in ipairs(getters) do
		getter:SetPosition(Vector2(150, 5 + 22 * (i - 1)))
	end

	for i, setter in pairs(setters) do
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

	local aero = self.gui.aero
	local window = aero.window
	local labels = aero.labels
	local getters = aero.getters
	local setters = aero.setters

	for i = 1, 7 do
		labels[i] = Label.Create(window)
		getters[i] = Label.Create(window)
		setters[i] = TextBoxNumeric.Create(window)
	end

	labels[1]:SetText("Air Density")
	labels[2]:SetText("Frontal Area")
	labels[3]:SetText("Drag Coeff")
	labels[4]:SetText("Lift Coeff")
	labels[5]:SetText("Extra Gravity X")
	labels[6]:SetText("Extra Gravity Y")
	labels[7]:SetText("Extra Gravity Z")

	setters[1]:Subscribe("ReturnPressed", function(args)
		self.aero:SetAirDensity(args:GetValue())
		args:SetText("")
	end)

	setters[2]:Subscribe("ReturnPressed", function(args)
		self.aero:SetFrontalArea(args:GetValue())
		args:SetText("")
	end)

	setters[3]:Subscribe("ReturnPressed", function(args)
		self.aero:SetDragCoefficient(args:GetValue())
		args:SetText("")
	end)

	setters[4]:Subscribe("ReturnPressed", function(args)
		self.aero:SetLiftCoefficient(args:GetValue())
		args:SetText("")
	end)

	setters[5]:Subscribe("ReturnPressed", function(args)
		local gravity = self.aero:GetExtraGravity()
		self.aero:SetExtraGravity(Vector3(args:GetValue(), gravity.y, gravity.z))
		args:SetText("")
	end)

	setters[6]:Subscribe("ReturnPressed", function(args)
		local gravity = self.aero:GetExtraGravity()
		self.aero:SetExtraGravity(Vector3(gravity.x, args:GetValue(), gravity.z))
		args:SetText("")
	end)

	setters[7]:Subscribe("ReturnPressed", function(args)
		local gravity = self.aero:GetExtraGravity()
		self.aero:SetExtraGravity(Vector3(gravity.x, gravity.y, args:GetValue()))
		args:SetText("")
	end)

	for i, label in ipairs(labels) do
		label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
		label:SizeToContents()
	end

	for i, getter in ipairs(getters) do
		getter:SetPosition(Vector2(150, 5 + 22 * (i - 1)))
	end

	for i, setter in pairs(setters) do
		setter:SetPosition(Vector2(225, 0 + 22 * (i - 1)))
		setter:SetWidth(57)
		setter:SetText("")
	end

end

function Tuner:InitSuspensionGUI()

	local susp = self.gui.susp
	local window = susp.window
	local labels = susp.labels

	for i = 1, 20 do
		labels[i] = Label.Create(window)
	end

	for wheel = 1, 8 do
		susp[wheel] = {getters = {}, setters = {}}
		for i = 1, 10 do
			susp[wheel].getters[i] = Label.Create(window)
			susp[wheel].setters[i] = TextBoxNumeric.Create(window)
		end
	end

	labels[1]:SetText("Length")
	labels[2]:SetText("Strength")
	labels[3]:SetText("Chassis Direction X")
	labels[4]:SetText("Chassis Direction Y")
	labels[5]:SetText("Chassis Direction Z")
	labels[6]:SetText("Chassis Position X")
	labels[7]:SetText("Chassis Position Y")
	labels[8]:SetText("Chassis Position Z")
	labels[9]:SetText("Damping Compression")
	labels[10]:SetText("Damping Relaxation")

	labels[11]:SetText("Length")
	labels[12]:SetText("Strength")
	labels[13]:SetText("Chassis Direction X")
	labels[14]:SetText("Chassis Direction Y")
	labels[15]:SetText("Chassis Direction Z")
	labels[16]:SetText("Chassis Position X")
	labels[17]:SetText("Chassis Position Y")
	labels[18]:SetText("Chassis Position Z")
	labels[19]:SetText("Damping Compression")
	labels[20]:SetText("Damping Relaxation")

	for i, label in ipairs(labels) do
		label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
		label:SizeToContents()
	end

	for wheel, v in ipairs(susp) do

		local getters = v.getters
		local setters = v.setters

		for i, getter in ipairs(getters) do
			getter:SetPosition(Vector2(150 + 75 * (wheel - 1), 5 + 22 * (i - 1)))
			getter:SetWidth(70)
		end

		setters[1]:Subscribe("ReturnPressed", function(args)
			self.susp:SetLength(wheel, args:GetValue())
			args:SetText("")
		end)

		setters[2]:Subscribe("ReturnPressed", function(args)
			self.susp:SetStrength(wheel, args:GetValue())
			args:SetText("")
		end)

		setters[3]:Subscribe("ReturnPressed", function(args)
			local direction = self.susp:GetChassisDirection(wheel)
			self.susp:SetChassisDirection(wheel, Vector3(args:GetValue(), direction.y, direction.z))
			args:SetText("")
		end)

		setters[4]:Subscribe("ReturnPressed", function(args)
			local direction = self.susp:GetChassisDirection(wheel)
			self.susp:SetChassisDirection(wheel, Vector3(direction.x, args:GetValue(), direction.z))
			args:SetText("")
		end)

		setters[5]:Subscribe("ReturnPressed", function(args)
			local direction = self.susp:GetChassisDirection(wheel)
			self.susp:SetChassisDirection(wheel, Vector3(direction.x, direction.y, args:GetValue()))
			args:SetText("")
		end)

		setters[6]:Subscribe("ReturnPressed", function(args)
			local position = self.susp:GetChassisPosition(wheel)
			self.susp:SetChassisPosition(wheel, Vector3(args:GetValue(), position.y, position.z))
			args:SetText("")
		end)

		setters[7]:Subscribe("ReturnPressed", function(args)
			local position = self.susp:GetChassisPosition(wheel)
			self.susp:SetChassisPosition(wheel, Vector3(position.x, args:GetValue(), position.z))
			args:SetText("")
		end)

		setters[8]:Subscribe("ReturnPressed", function(args)
			local position = self.susp:GetChassisPosition(wheel)
			self.susp:SetChassisPosition(wheel, Vector3(position.x, position.y, args:GetValue()))
			args:SetText("")
		end)

		setters[9]:Subscribe("ReturnPressed", function(args)
			self.susp:SetDampingCompression(wheel, args:GetValue())
			args:SetText("")
		end)

		setters[10]:Subscribe("ReturnPressed", function(args)
			self.susp:SetDampingRelaxation(wheel, args:GetValue())
			args:SetText("")
		end)

		for i, setter in ipairs(setters) do
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
	local getters = self.gui.veh.getters

	getters[1]:SetText(f("%s", vehicle:GetName()))
	getters[2]:SetText(f("%s", vehicle:GetDriver()))
	getters[3]:SetText(f("%i", vehicle:GetModelId()))
	getters[4]:SetText(f("%i", vehicle:GetClass()))
	getters[5]:SetText(f("%s", vehicle:GetTemplate()))
	getters[6]:SetText(f("%s", vehicle:GetDecal()))
	getters[9]:SetText(f("%i", vehicle:GetWheelCount()))
	getters[10]:SetText(f("%i", vehicle:GetMaxRPM()))
	getters[15]:SetText(f("%i m/s", vehicle:GetTopSpeed()))

end

function Tuner:VehicleUpdate()

	local vehicle = self.veh
	if not vehicle then return end
	local transmission = self.trans
	local getters = self.gui.veh.getters

	local f = string.format
	local t = vehicle:GetTorque()
	local ratios = transmission:GetGearRatios()
	local s = vehicle:GetLinearVelocity():Length()
	local wt = t * transmission:GetPrimaryTransmissionRatio() * ratios[transmission:GetGear()]

	getters[7]:SetText(f("%i%s", vehicle:GetHealth() * 100, "%"))
	getters[8]:SetText(f("%i kg", vehicle:GetMass()))
	getters[11]:SetText(f("%i", vehicle:GetRPM()))
	getters[12]:SetText(f("%i N", t))

	local peak_t = self.peak_t or 0
	if t > peak_t then
		peak_t = t
		getters[13]:SetText(f("%i N", peak_t))
	end
	self.peak_t = peak_t

	getters[14]:SetText(f("%i N", wt))
	getters[16]:SetText(f("%i m/s, %i, km/h, %i mi/h", s, s * 3.6, s * 2.234))

	local peak_s = self.peak_s or 0
	if s > peak_s then
		peak_s = s
		getters[17]:SetText(f("%i m/s, %i km/h, %i mi/h", peak_s, peak_s * 3.6, peak_s * 2.234))
	end
	self.peak_s = peak_s

	local timer = self.timer
	if s < 0.1 then
		getters[18]:SetText("")
		if timer then
			timer:Restart()
		else
			timer = Timer()
		end
	else
		if timer and s > 100 / 3.6 then
			getters[18]:SetText(f("%.3f s", timer:GetSeconds()))
			timer = nil
		end
	end
	self.timer = timer

end

function Tuner:TransmissionUpdate()

	local transmission = self.trans
	if not transmission then return end
	local getters = self.gui.trans.getters
	local f = string.format

	self.gui.trans.setters[4]:SetChecked(transmission:GetManual())

	getters[1]:SetText(f("%i", transmission:GetUpshiftRPM()))
	getters[2]:SetText(f("%i", transmission:GetDownshiftRPM()))
	getters[3]:SetText(f("%i", transmission:GetMaxGear()))
	getters[4]:SetText(f("%s", transmission:GetManual()))
	getters[5]:SetText(f("%g", transmission:GetClutchDelayTime()))
	getters[6]:SetText(f("%i", transmission:GetGear()))

	local gear_ratios = transmission:GetGearRatios()
	for wheel, ratio in ipairs(gear_ratios) do
		getters[6 + wheel]:SetText(f("%g", ratio))
	end

	getters[13]:SetText(f("%g", transmission:GetReverseGearRatio()))
	getters[14]:SetText(f("%g", transmission:GetPrimaryTransmissionRatio()))

	local wheel_ratios = transmission:GetWheelTorqueRatios()
	for wheel, ratio in ipairs(wheel_ratios) do
		getters[14 + wheel]:SetText(f("%g", ratio))
	end

end

function Tuner:AerodynamicsUpdate()

	local aerodynamics = self.aero
	if not aerodynamics then return end
	local getters = self.gui.aero.getters
	local f = string.format

	getters[1]:SetText(f("%g", aerodynamics:GetAirDensity()))
	getters[2]:SetText(f("%g", aerodynamics:GetFrontalArea()))
	getters[3]:SetText(f("%g", aerodynamics:GetDragCoefficient()))
	getters[4]:SetText(f("%g", aerodynamics:GetLiftCoefficient()))

	local gravity = aerodynamics:GetExtraGravity()
	getters[5]:SetText(f("%.6f", gravity.x))
	getters[6]:SetText(f("%.6f", gravity.y))
	getters[7]:SetText(f("%.6f", gravity.z))

end

function Tuner:SuspensionUpdate()

	local suspension = self.susp
	if not suspension then return end
	local f = string.format
	local susp = self.gui.susp

	for wheel = 1, self.veh:GetWheelCount() do

		local getters = susp[wheel].getters

		getters[1]:SetText(f("%g", suspension:GetLength(wheel)))
		getters[2]:SetText(f("%g", suspension:GetStrength(wheel)))

		local direction = suspension:GetChassisDirection(wheel)
		getters[3]:SetText(f("%.6f", direction.x))
		getters[4]:SetText(f("%.6f", direction.y))
		getters[5]:SetText(f("%.6f", direction.z))

		local position = suspension:GetChassisPosition(wheel)
		getters[6]:SetText(f("%.6f", position.x))
		getters[7]:SetText(f("%.6f", position.y))
		getters[8]:SetText(f("%.6f", position.z))

		getters[9]:SetText(f("%g", suspension:GetDampingCompression(wheel)))
		getters[10]:SetText(f("%g", suspension:GetDampingRelaxation(wheel)))

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
	self.veh, self.trans, self.aero, self.susp = nil, nil, nil, nil
	self.peak_s, self.peak_t = nil, nil
	self.timer = nil
end

Tuner = Tuner()
