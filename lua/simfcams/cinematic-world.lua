local Cam = {}
Cam.Name = "Cinematic-World"

Cam.CamChangeDel = CurTime() 
Cam.CurCam = 1
Cam.LastCam = 1
Cam.NrOfCams = 2
Cam.CamFuncs = {}
Cam.LookPos = Vector(0,0,0)

function Cam:Init()
	print("Cinematic (world only) camera started.")
end

--random placement cam
Cam.CamFuncs[1] = function(self, ply, view, vehicle, change)	

	if change then
		self.LookPos = vehicle:GetPos() + Vector( math.random(-500,500) ,math.random(-500,500),math.random(-100,100))
		
		local Trace = {}
		Trace.start = vehicle:GetPos()
		Trace.endpos = self.LookPos
		Trace.mask = MASK_NPCWORLDSTATIC
		local tr = util.TraceLine(Trace)
		
		if tr.Hit then
			self.LookPos = tr.HitPos + tr.HitNormal * 20
		end				
		self.CamChangeDel = CurTime() + math.random(3,5)
	end

	view.angles = vehicle:GetPos() - self.LookPos
	view.angles = view.angles:Angle()
	view.origin = self.LookPos
	
	local Trace = {}
	Trace.start = vehicle:GetPos()
	Trace.endpos = self.LookPos
	Trace.mask = MASK_NPCWORLDSTATIC
	local tr = util.TraceLine(Trace)
	
	if tr.Hit then
		self.CamChangeDel = 0
	end
	
	return view
end

--driveby front cam, place camera randomly in front
Cam.CamFuncs[2] = function(self, ply, view, vehicle, change)	

	if change then
		self.LookPos = vehicle:GetPos() + SimfCamManager.FindForward(vehicle) * 500 + Vector( math.random(-50,50) ,math.random(-50,50),math.random(-50,50) )

		local tr = util.TraceLine({
			start = vehicle:GetPos(),
			endpos = self.LookPos,
			mask = MASK_NPCWORLDSTATIC,
		})
		
		if tr.Hit then
			self.LookPos = tr.HitPos + tr.HitNormal * 20
		end				
		self.CamChangeDel = CurTime() + math.random(3,5)
	end

	view.angles = vehicle:GetPos() - self.LookPos
	view.angles = view.angles:Angle()
	view.origin = self.LookPos

	local tr = util.TraceLine({
		start = vehicle:GetPos(),
		endpos = self.LookPos,
		mask = MASK_NPCWORLDSTATIC,
	})

	if tr.Hit then
		self.CamChangeDel = 0
	end		

	return view
end

--logic for choosing the camera, forwards values to calcvehicleview hook
function Cam:CinematicWorldFunc(ply, view, vehicle)	
	if self.CamChangeDel < CurTime() then
		local camnum = math.random(1, self.NrOfCams)

		if self.CamFuncs[camnum]( self, ply, view, vehicle, false) then
			self.CurCam = camnum
		end

		return self.CamFuncs[self.CurCam]( self, ply, view, vehicle, true)
	end
	
	if ply:KeyPressed( 1 ) then
		self.CamChangeDel = CurTime() + 0.2
	end

	return self.CamFuncs[self.CurCam]( self, ply, view, vehicle, false)
end

function Cam:FirstPerson(ply, view, vehicle)	
	return Cam:CinematicWorldFunc(ply, view, vehicle)	
end

function Cam:ThirdPerson(ply, view, vehicle)	
	return Cam:CinematicWorldFunc(ply, view, vehicle)	
end

SimfCamManager:RegisterCam(Cam)