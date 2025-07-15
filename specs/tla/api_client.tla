------------------------------ MODULE api_client ------------------------------
EXTENDS Naturals, Sequences, TLC

CONSTANTS
    MaxRetries,
    TimeoutDuration

VARIABLES
    clientState,
    requestQueue,
    responseQueue,
    retryCount,
    lastError

States == {"idle", "sending", "waiting", "processing", "error", "timeout"}

TypeOK ==
    /\ clientState \in States
    /\ requestQueue \in Seq(STRING)
    /\ responseQueue \in Seq(STRING)
    /\ retryCount \in 0..MaxRetries
    /\ lastError \in STRING \cup {NULL}

Init ==
    /\ clientState = "idle"
    /\ requestQueue = <<>>
    /\ responseQueue = <<>>
    /\ retryCount = 0
    /\ lastError = NULL

QueueRequest(req) ==
    /\ clientState = "idle"
    /\ requestQueue' = Append(requestQueue, req)
    /\ UNCHANGED <<clientState, responseQueue, retryCount, lastError>>

SendRequest ==
    /\ clientState = "idle"
    /\ Len(requestQueue) > 0
    /\ clientState' = "sending"
    /\ UNCHANGED <<requestQueue, responseQueue, retryCount, lastError>>

WaitForResponse ==
    /\ clientState = "sending"
    /\ clientState' = "waiting"
    /\ UNCHANGED <<requestQueue, responseQueue, retryCount, lastError>>

ReceiveResponse(resp) ==
    /\ clientState = "waiting"
    /\ clientState' = "processing"
    /\ responseQueue' = Append(responseQueue, resp)
    /\ requestQueue' = Tail(requestQueue)
    /\ retryCount' = 0
    /\ UNCHANGED lastError

HandleTimeout ==
    /\ clientState = "waiting"
    /\ retryCount < MaxRetries
    /\ clientState' = "sending"
    /\ retryCount' = retryCount + 1
    /\ lastError' = "timeout"
    /\ UNCHANGED <<requestQueue, responseQueue>>

HandleError(error) ==
    /\ clientState \in {"sending", "waiting"}
    /\ clientState' = "error"
    /\ lastError' = error
    /\ UNCHANGED <<requestQueue, responseQueue, retryCount>>

ProcessResponse ==
    /\ clientState = "processing"
    /\ clientState' = "idle"
    /\ UNCHANGED <<requestQueue, responseQueue, retryCount, lastError>>

RecoverFromError ==
    /\ clientState = "error"
    /\ retryCount < MaxRetries
    /\ clientState' = "idle"
    /\ retryCount' = retryCount + 1
    /\ UNCHANGED <<requestQueue, responseQueue, lastError>>

Next ==
    \/ \E req \in STRING : QueueRequest(req)
    \/ SendRequest
    \/ WaitForResponse
    \/ \E resp \in STRING : ReceiveResponse(resp)
    \/ HandleTimeout
    \/ \E err \in STRING : HandleError(err)
    \/ ProcessResponse
    \/ RecoverFromError

Spec == Init /\ [][Next]_<<clientState, requestQueue, responseQueue, retryCount, lastError>>

(* Properties *)
EventuallyProcessed ==
    Len(requestQueue) > 0 ~> <>(Len(responseQueue) > 0)

NoInfiniteRetries ==
    [](retryCount <= MaxRetries)

=============================================================================