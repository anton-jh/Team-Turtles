-- CONSTANTS --


Filenames = {
    project = "tt_project",
    state = "tt_state",
    turnFile = "tt_turns"
}



-- FUNCTIONS --


function PersistProject()
    local fileHandle = fs.open(Filenames.project, "w")

    fileHandle.write(textutils.serialize(Project))
    fileHandle.close()
end

function LoadProject()
    local fileHandle = fs.open(Filenames.project, "r")

    Project = textutils.unserialize(fileHandle.readAll())
    fileHandle.close()
end

function PersistState()
    local fileHandle = fs.open(Filenames.state, "w")
    local state = {
        previousLayer = PreviousLayer,
        assignedLayer = AssignedLayer,
        initialFuel = InitialFuel,
        activePhase = ActivePhase.name,
    }
    local serializedState = textutils.serialize(state)

    fileHandle.write(serializedState)
    fileHandle.close()
end

function LoadState()
    local fileHandle = fs.open(Filenames.state, "r")
    local serializedState = fileHandle.readAll()
    fileHandle.close()

    local state = textutils.unserialize(serializedState)

    PreviousLayer = state.previousLayer
    AssignedLayer = state.assignedLayer
    InitialFuel = state.initialFuel
    ActivePhase = Phase[state.activePhase]
end

function LoadTurns()
    if not fs.exists(Filenames.turnFile) then
        return 0
    end

    local fileHandle = fs.open(Filenames.turnFile, "r")
    local contents = fileHandle.readAll()

    return #contents
end
