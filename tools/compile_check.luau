-- Studio 편집 모드에서 실행: 동기화한 모든 스크립트가 컴파일되는지 본다 (Studio MCP execute_luau, Edit)
-- 각 소스를 `return function(...) <소스> end`로 감싼 임시 ModuleScript로 require한다 (실행은 안 함).
local roots = { game.ServerScriptService, game.ReplicatedStorage, game.StarterPlayer.StarterPlayerScripts }
local bad, n = {}, 0
local holder = Instance.new("Folder")
holder.Name = "_compile"
holder.Parent = game.ServerStorage
for _, r in roots do
	for _, d in r:GetDescendants() do
		if d:IsA("LuaSourceContainer") then
			n += 1
			local m = Instance.new("ModuleScript")
			m.Name = d.Name
			m.Source = "return function(...)\n" .. d.Source .. "\nend"
			m.Parent = holder
			local ok, err = pcall(require, m)
			if not ok then
				table.insert(bad, d:GetFullName() .. ": " .. tostring(err))
			end
		end
	end
end
holder:Destroy()
return n .. " scripts, errors: " .. (if #bad == 0 then "none" else table.concat(bad, "\n"))
