function tableprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tableprint(v, indent+1)
    elseif (not type(v) == "function") then
      print(formatting .. v)
    end
  end
end
