-- Builder: dump every BasePart under workspace.BuilderSandbox.<model> into _G.BUILDEXPORT (JSON, positions relative
-- to the model's build origin attribute "BuildOrigin", default 0,0,500). Read back by tools/builder/build_run.py.
local HS = game:GetService("HttpService")
local sb = workspace:FindFirstChild("BuilderSandbox")
local out = {}
local function r(v) return math.floor(v * 1000 + 0.5) / 1000 end
if sb then
	for _, d in ipairs(sb:GetDescendants()) do
		if d:IsA("BasePart") then
			local origin = sb:GetAttribute("BuildOrigin") or Vector3.new(0, 0, 500)
			local cf = CFrame.new(origin):ToObjectSpace(d.CFrame)
			local comps = { cf:GetComponents() }
			for i, v in ipairs(comps) do comps[i] = r(v) end
			local kind = "block"
			if d:IsA("WedgePart") then
				kind = "wedge"
			elseif d:IsA("CornerWedgePart") then
				kind = "cornerwedge"
			elseif d:IsA("Part") and d.Shape == Enum.PartType.Cylinder then
				kind = "cyl"
			elseif d:IsA("Part") and d.Shape == Enum.PartType.Ball then
				kind = "ball"
			end
			table.insert(out, {
				n = d.Name, k = kind, s = { r(d.Size.X), r(d.Size.Y), r(d.Size.Z) }, cf = comps,
				c = d.Color:ToHex(), t = r(d.Transparency), m = d.Material.Name,
			})
		end
	end
end
_G.BUILDEXPORT = HS:JSONEncode(out)
return "parts " .. #out
