-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy  = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("routes_v2")

-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local PanelOpen      = false
local InviteOpen     = false
local RouteActive    = false
local RouteBlip      = nil
local RouteCoords    = {}
local RouteIndex     = 1
local IsCollecting   = false
local GroupLeader    = false
local InGroup        = false
local MyName         = ""

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
function Draw3DText(x, y, z, text, scale)
	local onScreen, sx, sy = World3dToScreen2d(x, y, z)
	if onScreen then
		SetTextScale(scale or 0.5, scale or 0.5)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextOutline()
		SetTextEntry("STRING")
		AddTextComponentString(text)
		DrawText(sx, sy - 0.015)
	end
end

local function CloseFocus()
	PanelOpen  = false
	InviteOpen = false
	SetNuiFocus(false, false)
	SetNuiFocusKeepInput(false)
end

function ResetRouteState()
	RouteActive = false
	RouteCoords = {}
	RouteIndex  = 1
	if RouteBlip and DoesBlipExist(RouteBlip) then
		RemoveBlip(RouteBlip)
		RouteBlip = nil
	end
end

function UpdateRouteBlip()
	if RouteBlip and DoesBlipExist(RouteBlip) then
		RemoveBlip(RouteBlip)
		RouteBlip = nil
	end

	if RouteActive and RouteCoords and #RouteCoords > 0 then
		local Target = RouteCoords[RouteIndex]
		if Target then
			RouteBlip = AddBlipForCoord(Target.x, Target.y, Target.z)
			SetBlipSprite(RouteBlip, 1)
			SetBlipColour(RouteBlip, 77)
			SetBlipScale(RouteBlip, 0.6)
			SetBlipRoute(RouteBlip, true)
			SetBlipAsShortRange(RouteBlip, false)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Ponto de Coleta")
			EndTextCommandSetBlipName(RouteBlip)
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Ped    = PlayerPedId()
		local Coords = GetEntityCoords(Ped)
		local Near   = false

		for _, loc in ipairs(RouteConfig.Locations) do
			local pos  = vec3(loc.x, loc.y, loc.z)
			local dist = #(Coords - pos)

			if dist <= 8.0 then
				Draw3DText(pos.x, pos.y, pos.z + 0.4, "🗺️", 0.40)
			end

			if dist <= RouteConfig.InteractRadius then
				Near = true
				if IsControlJustPressed(1, 38) and not PanelOpen and not InviteOpen then
					MyName = vSERVER.GetMyName() or "Jogador"
					PanelOpen = true
					SetNuiFocus(true, true)
					SendNUIMessage({
						type     = "routes:Open",
						items    = RouteConfig.Items,
						max      = RouteConfig.MaxSelect,
						active   = RouteActive and true or false,
						inGroup  = InGroup and true or false,
						isLeader = GroupLeader and true or false,
						myName   = MyName,
					})
				end
			end
		end
		Wait(Near and 0 or 200)
	end
end)

CreateThread(function()
	while true do
		if RouteActive and RouteCoords and #RouteCoords > 0 then
			local Ped    = PlayerPedId()
			local Coords = GetEntityCoords(Ped)
			local Target = RouteCoords[RouteIndex]
			
			if Target then
				local dist = #(Coords - vec3(Target.x, Target.y, Target.z))

				if dist <= 15.0 then
					Draw3DText(Target.x, Target.y, Target.z + 0.3, "🎯", 0.42)
				end

				if dist <= 2.0 and IsControlJustPressed(1, 38) and not IsCollecting then
					if IsPedInAnyVehicle(Ped) then
						TriggerEvent("Notify", "Rotas", "Saia do veículo!", "amarelo", 3000)
					else
						IsCollecting = true
						RequestAnimDict("amb@prop_human_bum_bin@base")
						while not HasAnimDictLoaded("amb@prop_human_bum_bin@base") do Wait(10) end
						TaskPlayAnim(Ped, "amb@prop_human_bum_bin@base", "base", 3.0, -3.0, 2000, 1, 0, false, false, false)
						Wait(1800)

						if vSERVER.Collect(RouteIndex) then
							RouteIndex = RouteIndex + 1
							if RouteIndex > #RouteCoords then
								RouteIndex = 1
								TriggerEvent("Notify", "Rotas", "Rota concluída! Voltando ao início.", "verde", 4000)
							end
							UpdateRouteBlip()
						end
						ClearPedTasks(Ped)
						IsCollecting = false
					end
				end
			end
			Wait(0)
		else
			Wait(500)
		end
	end
end)

CreateThread(function()
	while true do
		if RouteActive and (IsDisabledControlJustPressed(0, 168) or IsControlJustPressed(0, 168)) then
			if vSERVER.CancelRoute(GroupLeader) then
				ResetRouteState()
				SendNUIMessage({ type = "routes:RouteEnded" })
			end
		end
		Wait(RouteActive and 0 or 500)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("routes:Start", function(Data, Callback)
	if not Data.selected or #Data.selected == 0 then Callback(false) return end
	CloseFocus()
	local Result = vSERVER.StartRoute(Data.selected)
	if Result and Result.coords then
		RouteActive, InGroup, GroupLeader = true, false, false
		RouteCoords, RouteIndex = Result.coords, 1
		UpdateRouteBlip()
		Callback(true)
	else Callback(false) end
end)

RegisterNUICallback("routes:CreateGroup", function(Data, Callback)
	if not Data.selected or #Data.selected == 0 then Callback(false) return end
	if vSERVER.CreateGroup(Data.selected) then
		InGroup, GroupLeader = true, true
		Callback(true)
	else Callback(false) end
end)

RegisterNUICallback("routes:Invite", function(Data, Callback)
	local target = tonumber(Data.targetPassport)
	if target and vSERVER.InvitePlayer(target) then Callback(true) else Callback(false) end
end)

RegisterNUICallback("routes:StartGroup", function(Data, Callback)
	CloseFocus()
	local Result = vSERVER.StartGroupRoute()
	if Result and Result.coords then
		RouteActive, RouteCoords, RouteIndex = true, Result.coords, 1
		UpdateRouteBlip()
		Callback(true)
	else Callback(false) end
end)

RegisterNUICallback("routes:Cancel", function(Data, Callback)
	if vSERVER.CancelRoute(GroupLeader) then ResetRouteState() end
	CloseFocus()
	Callback(true)
end)

RegisterNUICallback("routes:LeaveGroup", function(Data, Callback)
	vSERVER.LeaveGroup()
	InGroup, GroupLeader = false, false
	CloseFocus()
	Callback(true)
end)

RegisterNUICallback("routes:Close", function(Data, Callback) 
	CloseFocus() 
	Callback("ok") 
end)

RegisterNUICallback("routes:AcceptInvite", function(Data, Callback)
	if vSERVER.AcceptInvite() then 
		InGroup, GroupLeader = true, false 
	end
	InviteOpen = false
	CloseFocus()
	Callback(true)
end)

RegisterNUICallback("routes:DeclineInvite", function(Data, Callback)
	vSERVER.DeclineInvite()
	InviteOpen = false
	CloseFocus()
	Callback(true)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("routes:InviteReceived")
AddEventHandler("routes:InviteReceived", function(LeaderName, LeaderSrc)
	InviteOpen = true
	SetNuiFocus(true, true)
	SendNUIMessage({ type = "routes:InviteReceived", leaderName = LeaderName, leaderSrc = LeaderSrc })
end)

RegisterNetEvent("routes:GroupStarted")
AddEventHandler("routes:GroupStarted", function(Coords)
	RouteActive, RouteCoords, RouteIndex = true, Coords, 1
	UpdateRouteBlip()
	SendNUIMessage({ type = "routes:HudShow", isLeader = false })
end)

RegisterNetEvent("routes:GroupCancelled")
AddEventHandler("routes:GroupCancelled", function()
	ResetRouteState()
	SendNUIMessage({ type = "routes:RouteEnded" })
	TriggerEvent("Notify", "Rotas", "O líder cancelou a rota.", "vermelho", 4000)
end)

RegisterNetEvent("routes:MemberLeft")
AddEventHandler("routes:MemberLeft", function(MemberName)
	SendNUIMessage({ type = "routes:MemberLeft", name = MemberName })
	TriggerEvent("Notify", "Rotas", MemberName .. " saiu.", "amarelo", 4000)
end)

RegisterNetEvent("routes:MemberJoined")
AddEventHandler("routes:MemberJoined", function(MemberName, MemberSrc)
	SendNUIMessage({ type = "routes:MemberJoined", name = MemberName, src = MemberSrc })
	TriggerEvent("Notify", "Rotas", MemberName .. " entrou!", "verde", 4000)
end)

RegisterNetEvent("routes:NotifyInviteAccepted")
AddEventHandler("routes:NotifyInviteAccepted", function(MemberName)
	TriggerEvent("Notify", "Rotas", MemberName .. " aceitou o convite!", "verde", 4000)
end)

RegisterNetEvent("routes:NotifyInviteDeclined")
AddEventHandler("routes:NotifyInviteDeclined", function(MemberName)
	TriggerEvent("Notify", "Rotas", MemberName .. " recusou o convite.", "amarelo", 4000)
	SendNUIMessage({ type = "routes:InviteDeclined", name = MemberName })
end)