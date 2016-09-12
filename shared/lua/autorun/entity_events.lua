local events = {
	attacked = "OnAttacked",
	death = "OnDeath",
	fall = "OnFall",
	jump = "OnJump",
	lightning = "OnStruckByLightning",
	removed = "OnRemove",
	spawned = "OnSpawn",
	update = "OnUpdate",
	dropall = "OnDropLoot",
	joinworld = "OnJoinWorld",
}

for event, entity_func in pairs(events) do
	hook.Add("entity." .. event, "entity_events", function(ent, ...)
		ent.temp_hack = true -- fixes newindex issues
		if ent and ent[entity_func] then
			ent[entity_func](ent, ...)
		end
	end)
end

hook.Add("player.interact", "entity_events", function(ply, ent)
	if ent and ent.OnPlayerInteract then
		ent:OnPlayerInteract(ply)
	end
end)