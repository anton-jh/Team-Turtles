-- FUNCTIONS --


function PersistProject()
    local fileHandle = fs.open(Filenames.project, "w")

    fileHandle.write(textutils.serialize(Project))
    fileHandle.close()
end

function LoadProject()
    if not fs.exists(Filenames.project) then
        BroadcastFatalError("Cannot load project file.")
    end
    local fileHandle = fs.open(Filenames.project, "r")

    Project = textutils.unserialize(fileHandle.readAll())
    fileHandle.close()
end


function PersistState()
    local fileHandle = fs.open(Filenames.state, "w")
    local state = {
        assignedLayer = AssignedLayer,
        initialFuel = InitialFuel,
        activePhase = ActivePhase.name,
        phaseArgs = PhaseArgs
    }
    local serializedState = textutils.serialize(state)

    fileHandle.write(serializedState)
    fileHandle.close()
end

function LoadState()
    if not fs.exists(Filenames.state) then
        BroadcastFatalError("Cannot load state.")
    end
    local fileHandle = fs.open(Filenames.state, "r")
    local serializedState = fileHandle.readAll()
    fileHandle.close()

    local state = textutils.unserialize(serializedState)

    AssignedLayer = state.assignedLayer
    InitialFuel = state.initialFuel
    ActivePhase = Phase[state.activePhase]
    PhaseArgs = state.phaseArgs
end


function LoadTurnFile()
    local unfinished = nil
    local turns = 0
    if fs.exists(Filenames.turnFile) then
        local handle = fs.open(Filenames.turnFile, "r")
        local line = nil
        repeat
            line = handle.readLine()
            if line == "ok" then
                turns = turns + 1
                unfinished = nil
            elseif line ~= nil then
                unfinished = line
            end
        until line == nil
        handle.close()
    end
    return unfinished and textutils.unserialize(unfinished) or turns
end


function SaveTable(filename, tbl)
    ClearTable(filename)

    local fileHandle = fs.open(filename, "w")
    fileHandle.write(textutils.serialize(tbl))
    fileHandle.close()
end

function LoadTable(filename)
    if not fs.exists(filename) then
        return nil
    end

    local fileHandle = fs.open(filename, "r")
    local contents = fileHandle.readAll()

    return textutils.unserialize(contents)
end

function ClearTable(filename)
    if fs.exists(filename) then
        fs.delete(filename)
        return true
    end
    return false
end
