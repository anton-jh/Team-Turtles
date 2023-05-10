-- CONSTANTS --


Filenames = {
    project = "tt_project",
    state = "tt_state",
    turnFile = "tt_turns"
}



-- FUNCTIONS --


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
