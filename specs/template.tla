---- MODULE template ----
EXTENDS Naturals, Sequences, TLC

\* Module documentation
\* This is a template for TLA+ specifications

CONSTANTS
    \* Define constants here
    MAX_VALUE

VARIABLES
    \* Define state variables here
    state

----
\* Type invariant
TypeInvariant ==
    /\ state \in 0..MAX_VALUE

\* Initial state
Init ==
    /\ state = 0

\* State transitions
Next ==
    /\ state' = state + 1
    /\ state < MAX_VALUE

\* Specification
Spec == Init /\ [][Next]_state

====
