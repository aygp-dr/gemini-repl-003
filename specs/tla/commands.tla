------------------------------ MODULE commands ------------------------------
EXTENDS Naturals, Sequences, TLC

CONSTANTS Commands, MaxHistory

VARIABLES
    commandHistory,
    currentCommand,
    commandState

TypeOK ==
    /\ commandHistory \in Seq(Commands)
    /\ currentCommand \in Commands \cup {NULL}
    /\ commandState \in {"idle", "processing", "completed", "error"}

Init ==
    /\ commandHistory = <<>>
    /\ currentCommand = NULL
    /\ commandState = "idle"

ProcessCommand(cmd) ==
    /\ commandState = "idle"
    /\ currentCommand' = cmd
    /\ commandState' = "processing"
    /\ UNCHANGED commandHistory

CompleteCommand ==
    /\ commandState = "processing"
    /\ commandState' = "completed"
    /\ commandHistory' = Append(commandHistory, currentCommand)
    /\ currentCommand' = NULL

HandleError ==
    /\ commandState = "processing"
    /\ commandState' = "error"
    /\ UNCHANGED <<commandHistory, currentCommand>>

ResetAfterError ==
    /\ commandState = "error"
    /\ commandState' = "idle"
    /\ currentCommand' = NULL
    /\ UNCHANGED commandHistory

Next ==
    \/ \E cmd \in Commands : ProcessCommand(cmd)
    \/ CompleteCommand
    \/ HandleError
    \/ ResetAfterError

Spec == Init /\ [][Next]_<<commandHistory, currentCommand, commandState>>

(* Safety Properties *)
HistoryBounded == Len(commandHistory) <= MaxHistory

NoLostCommands ==
    [](commandState = "completed" => currentCommand = NULL)

(* Liveness Properties *)
EventuallyIdle ==
    <>(commandState = "idle")

=============================================================================