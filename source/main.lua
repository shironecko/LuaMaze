local function has_matching_arg(query)
    for i,val in ipairs(arg) do
        if val == query then
            return true
        end
    end
end
if has_matching_arg('tile') then
    require "main_tile"
else
    require "main_draw"
end
