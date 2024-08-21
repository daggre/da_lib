
Lib.Stats.Get = function(skill)
    return LocalPlayer.state.rep and LocalPlayer.state.rep[skill] or 0
end

Lib.Stats.Add = function(skill, amount)
    Lib.API.AddSkill(skill, amount)
end

Lib.Stats.Set = function(skill, amount)
    Lib.API.SetSkill(skill, amount)
end
