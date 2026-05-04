-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy  = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface("routes_v2", Creative)

-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local ActiveRoutes  = {}
local Groups        = {}
local PlayerGroup   = {}
local PendingInvites= {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function GetPassport()
	return vRP.Passport(source)
end

local function GetName(passport)
	return vRP.GetName(passport) or "Jogador"
end

local function PickRoute()
	local routeIdx = math.random(#RouteConfig.Routes)
	return RouteConfig.Routes[routeIdx]
end

local function GiveItems(passport, selectedIdxs, groupBonus)
	local amounts = {}
	for _, idx in ipairs(selectedIdxs) do
		local def = RouteConfig.Items[idx]
		if def then
			amounts[idx] = math.random(def.Min, def.Max)
		end
	end

	if groupBonus and #selectedIdxs > 0 then
		local bonusIdx = selectedIdxs[math.random(#selectedIdxs)]
		if amounts[bonusIdx] then
			amounts[bonusIdx] = amounts[bonusIdx] + 1
		end
	end

	for idx, amount in pairs(amounts) do
		local def = RouteConfig.Items[idx]
		if def then
			vRP.GenerateItem(passport, def.Item, amount, true)
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.GetMyName()
	local passport = GetPassport()
	if not passport then return "Jogador" end
	return GetName(passport)
end

function Creative.StartRoute(Selected)
	local passport = GetPassport()
	if not passport then return false end

	local coords = PickRoute()
	ActiveRoutes[passport] = { Selected = Selected, Coords = coords }

	local plain = {}
	for i, v in ipairs(coords) do
		plain[i] = { x = v.x, y = v.y, z = v.z }
	end
	
	return { coords = plain }
end

function Creative.Collect(RouteIndex)
	local passport = GetPassport()
	if not passport then return false end

	local route = ActiveRoutes[passport]
	if not route then return false end

	local leader      = PlayerGroup[passport]
	local inGroup     = leader ~= nil
	local groupBonus  = inGroup

	GiveItems(passport, route.Selected, groupBonus)
	return true
end

function Creative.CancelRoute(IsLeader)
	local passport = GetPassport()
	if not passport then return false end

	ActiveRoutes[passport] = nil

	if IsLeader then
		local group = Groups[passport]
		if group then
			for _, memberPassport in ipairs(group.Members) do
				ActiveRoutes[memberPassport] = nil
				PlayerGroup[memberPassport]  = nil
				local memberSrc = vRP.Source(memberPassport)
				if memberSrc then
					TriggerClientEvent("routes:GroupCancelled", memberSrc)
				end
			end
			Groups[passport] = nil
		end
		PlayerGroup[passport] = nil
	else
		local leader = PlayerGroup[passport]
		if leader then
			PlayerGroup[passport] = nil
			local group = Groups[leader]
			if group then
				for i, m in ipairs(group.Members) do
					if m == passport then
						table.remove(group.Members, i)
						break
					end
				end
				local leaderSrc = vRP.Source(leader)
				if leaderSrc then
					TriggerClientEvent("routes:MemberLeft", leaderSrc, GetName(passport))
				end
			end
		end
	end

	return true
end

function Creative.CreateGroup(Selected)
	local passport = GetPassport()
	if not passport then return false end

	if Groups[passport] then
		Groups[passport] = nil
	end

	Groups[passport] = {
		Members  = {},
		Selected = Selected,
		Started  = false,
	}
	PlayerGroup[passport] = passport 
	return true
end

function Creative.InvitePlayer(TargetPassport)
	local source = source
	local passport = vRP.Passport(source)
	if not passport then return false end

	local group = Groups[passport]
	if not group then return false end

	local targetSrc = vRP.Source(TargetPassport)
	if not targetSrc then return false end
	if TargetPassport == passport then return false end

	PendingInvites[TargetPassport] = passport

	local leaderName = GetName(passport)
	TriggerClientEvent("routes:InviteReceived", targetSrc, leaderName, passport)
	return true
end

function Creative.AcceptInvite()
	local source = source
	local passport = vRP.Passport(source)
	if not passport then return false end

	local leader = PendingInvites[passport]
	if not leader then return false end

	PendingInvites[passport] = nil
	local group = Groups[leader]
	if not group then return false end

	table.insert(group.Members, passport)
	PlayerGroup[passport] = leader

	local leaderSrc = vRP.Source(leader)
	if leaderSrc then
		TriggerClientEvent("routes:MemberJoined", leaderSrc, GetName(passport), passport)
		TriggerClientEvent("routes:NotifyInviteAccepted", leaderSrc, GetName(passport))
	end

	return true
end

function Creative.DeclineInvite()
	local passport = GetPassport()
	if passport then
		PendingInvites[passport] = nil
	end
end

function Creative.StartGroupRoute()
	local source = source
	local passport = vRP.Passport(source)
	if not passport then return false end

	local group = Groups[passport]
	if not group then return false end

	local coords = PickRoute()
	group.Started = true

	local plain = {}
	for i, v in ipairs(coords) do
		plain[i] = { x = v.x, y = v.y, z = v.z }
	end

	ActiveRoutes[passport] = { Selected = group.Selected, Coords = coords }

	for _, memberPassport in ipairs(group.Members) do
		ActiveRoutes[memberPassport] = { Selected = group.Selected, Coords = coords }
		local memberSrc = vRP.Source(memberPassport)
		if memberSrc then
			TriggerClientEvent("routes:GroupStarted", memberSrc, plain)
		end
	end

	return { coords = plain }
end

function Creative.LeaveGroup()
	local passport = GetPassport()
	if not passport then return end

	local leader = PlayerGroup[passport]
	if not leader then return end

	PlayerGroup[passport] = nil
	local group = Groups[leader]
	if group then
		for i, m in ipairs(group.Members) do
			if m == passport then
				table.remove(group.Members, i)
				break
			end
		end
		local leaderSrc = vRP.Source(leader)
		if leaderSrc then
			TriggerClientEvent("routes:MemberLeft", leaderSrc, GetName(passport))
		end
	end
end

AddEventHandler("Disconnect", function(Passport)
	ActiveRoutes[Passport]   = nil
	PendingInvites[Passport] = nil

	if Groups[Passport] then
		local group = Groups[Passport]
		for _, m in ipairs(group.Members) do
			PlayerGroup[m] = nil
			ActiveRoutes[m] = nil
			local mSrc = vRP.Source(m)
			if mSrc then TriggerClientEvent("routes:GroupCancelled", mSrc) end
		end
		Groups[Passport] = nil
	end

	local leader = PlayerGroup[Passport]
	if leader then
		PlayerGroup[Passport] = nil
		local group = Groups[leader]
		if group then
			for i, m in ipairs(group.Members) do
				if m == Passport then table.remove(group.Members, i) break end
			end
			local lSrc = vRP.Source(leader)
			if lSrc then TriggerClientEvent("routes:MemberLeft", lSrc, GetName(Passport)) end
		end
	end
end)