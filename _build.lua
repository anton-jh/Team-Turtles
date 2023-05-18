function Build(filename)
    local mainFile = io.open("src/" .. filename, "r")
    local outputFile = io.open("build/" .. filename, "w")

    outputFile:write("-- ### Evil_Bengt, " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n\n")

    while true do
        local line = mainFile:read("*line")
        local match = string.find(line, "^require")

        if not match then
            break
        end

        local moduleName = string.sub(line, 10, string.len(line) - 2)
        print(moduleName)

        local modulePath = "./src/" .. string.gsub(moduleName, "%.", "/") .. ".lua"
        print(modulePath)

        local moduleFile = io.open(modulePath , "r")
        local moduleContent = moduleFile:read("*all")

        outputFile:write("-- ### MODULE: " .. moduleName .. "\n")
        outputFile:write("-- ### PATH: " .. modulePath .. "\n\n\n")
        outputFile:write(moduleContent)
        outputFile:write("\n\n\n")

        moduleFile:close()
    end

    local mainContent = mainFile:read("*all")
    outputFile:write("-- ### MAIN MODULE\n")
    outputFile:write("-- ### " .. filename .. "\n\n\n")
    outputFile:write(mainContent)

    mainFile:close()
    outputFile:close()
end


Build("turtle.lua")
Build("server.lua")
