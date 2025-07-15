------------------------------ MODULE interfaces ------------------------------
EXTENDS Naturals, Sequences, FiniteSets

CONSTANTS
    Interfaces,
    Methods,
    Parameters

VARIABLES
    activeInterfaces,
    pendingCalls,
    completedCalls,
    errorLog

TypeOK ==
    /\ activeInterfaces \subseteq Interfaces
    /\ pendingCalls \in [Interfaces -> SUBSET Methods]
    /\ completedCalls \in Seq([interface: Interfaces, method: Methods])
    /\ errorLog \in Seq([interface: Interfaces, method: Methods, error: STRING])

Init ==
    /\ activeInterfaces = {}
    /\ pendingCalls = [i \in Interfaces |-> {}]
    /\ completedCalls = <<>>
    /\ errorLog = <<>>

ActivateInterface(iface) ==
    /\ iface \in Interfaces
    /\ iface \notin activeInterfaces
    /\ activeInterfaces' = activeInterfaces \cup {iface}
    /\ UNCHANGED <<pendingCalls, completedCalls, errorLog>>

CallMethod(iface, method) ==
    /\ iface \in activeInterfaces
    /\ method \in Methods
    /\ pendingCalls' = [pendingCalls EXCEPT ![iface] = @ \cup {method}]
    /\ UNCHANGED <<activeInterfaces, completedCalls, errorLog>>

CompleteCall(iface, method) ==
    /\ iface \in activeInterfaces
    /\ method \in pendingCalls[iface]
    /\ pendingCalls' = [pendingCalls EXCEPT ![iface] = @ \ {method}]
    /\ completedCalls' = Append(completedCalls, [interface |-> iface, method |-> method])
    /\ UNCHANGED <<activeInterfaces, errorLog>>

LogError(iface, method, error) ==
    /\ iface \in activeInterfaces
    /\ method \in pendingCalls[iface]
    /\ pendingCalls' = [pendingCalls EXCEPT ![iface] = @ \ {method}]
    /\ errorLog' = Append(errorLog, [interface |-> iface, method |-> method, error |-> error])
    /\ UNCHANGED <<activeInterfaces, completedCalls>>

Next ==
    \/ \E i \in Interfaces : ActivateInterface(i)
    \/ \E i \in activeInterfaces, m \in Methods : CallMethod(i, m)
    \/ \E i \in activeInterfaces, m \in pendingCalls[i] : CompleteCall(i, m)
    \/ \E i \in activeInterfaces, m \in pendingCalls[i] : LogError(i, m, "error")

Spec == Init /\ [][Next]_<<activeInterfaces, pendingCalls, completedCalls, errorLog>>

(* Invariants *)
NoPendingOnInactive ==
    \A i \in Interfaces : i \notin activeInterfaces => pendingCalls[i] = {}

=============================================================================