dofile("scanner.lua")
dofile("parser.lua")
dofile("interpreter.lua")
local m = {
    Scanner = lua_scanner,
    Parser = lua_parser,
    Interpreter = lua_interpreter
}



---Parses string input and returns a tree
---@param input string
---@return table "Tree representation"
function m:getTree(input)
    local tokens = self.Scanner:scan(input)
    return self.Parser:parse(tokens)
end

---
---Runs a lua string, `environment` should be a table with variables and functions that will be used as the global environment
---
---@param input string
---@param environment table
---@return ...
function m:run(input, environment, ...)
    local tokens = self.Scanner:scan(input)
    local tree = self.Parser:parse(tokens)
    local env = self.Interpreter:encloseEnvironment(environment)
    self.Interpreter:setEnvMeta(env, "varargs", {...})
    env.arg = {...}
    return self.Interpreter:evaluate(tree, env)
end

---
---Runs a lua file, `environment` should be a table with variables and functions that will be used as the global environment
---
---@param file_path string
---@param environment table
---@return ...
function m:dofile(file_path, environment, ...)
    dofile(file_path)
    local source = lua_dofile
    lua_dofile = nil
    return self:run(source, environment, ...)
end

function m:tick()
    for i, loop in ipairs(self.Interpreter.loops) do
            if  loop() then
                table.remove(self.Interpreter.loops, i)
            end
    end
end

lua_in_lua = m