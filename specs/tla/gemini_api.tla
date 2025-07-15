------------------------------ MODULE gemini_api ------------------------------
EXTENDS Naturals, Sequences, FiniteSets

CONSTANTS
    MaxTokens,
    Models,
    Temperature

VARIABLES
    apiState,
    currentModel,
    conversationHistory,
    tokenCount,
    temperature

MessageType == [role: {"user", "assistant"}, content: STRING]

TypeOK ==
    /\ apiState \in {"ready", "processing", "rate_limited", "error"}
    /\ currentModel \in Models
    /\ conversationHistory \in Seq(MessageType)
    /\ tokenCount \in 0..MaxTokens
    /\ temperature \in {t \in Real : 0 <= t /\ t <= 1}

Init ==
    /\ apiState = "ready"
    /\ currentModel = CHOOSE m \in Models : TRUE
    /\ conversationHistory = <<>>
    /\ tokenCount = 0
    /\ temperature = 0.7

SendMessage(msg) ==
    /\ apiState = "ready"
    /\ tokenCount < MaxTokens
    /\ apiState' = "processing"
    /\ conversationHistory' = Append(conversationHistory, [role |-> "user", content |-> msg])
    /\ tokenCount' = tokenCount + Len(msg)
    /\ UNCHANGED <<currentModel, temperature>>

GenerateResponse ==
    /\ apiState = "processing"
    /\ \E response \in STRING :
        /\ conversationHistory' = Append(conversationHistory, [role |-> "assistant", content |-> response])
        /\ tokenCount' = tokenCount + Len(response)
    /\ apiState' = IF tokenCount' >= MaxTokens THEN "rate_limited" ELSE "ready"
    /\ UNCHANGED <<currentModel, temperature>>

HandleRateLimit ==
    /\ apiState = "rate_limited"
    /\ apiState' = "ready"
    /\ tokenCount' = 0
    /\ UNCHANGED <<currentModel, conversationHistory, temperature>>

ChangeModel(model) ==
    /\ apiState = "ready"
    /\ model \in Models
    /\ currentModel' = model
    /\ UNCHANGED <<apiState, conversationHistory, tokenCount, temperature>>

AdjustTemperature(temp) ==
    /\ apiState = "ready"
    /\ temp \in {t \in Real : 0 <= t /\ t <= 1}
    /\ temperature' = temp
    /\ UNCHANGED <<apiState, currentModel, conversationHistory, tokenCount>>

HandleError ==
    /\ apiState \in {"processing", "ready"}
    /\ apiState' = "error"
    /\ UNCHANGED <<currentModel, conversationHistory, tokenCount, temperature>>

RecoverFromError ==
    /\ apiState = "error"
    /\ apiState' = "ready"
    /\ UNCHANGED <<currentModel, conversationHistory, tokenCount, temperature>>

Next ==
    \/ \E msg \in STRING : SendMessage(msg)
    \/ GenerateResponse
    \/ HandleRateLimit
    \/ \E m \in Models : ChangeModel(m)
    \/ \E t \in {0.0, 0.3, 0.5, 0.7, 1.0} : AdjustTemperature(t)
    \/ HandleError
    \/ RecoverFromError

Spec == Init /\ [][Next]_<<apiState, currentModel, conversationHistory, tokenCount, temperature>>

(* Invariants *)
TokensWithinLimit ==
    tokenCount <= MaxTokens

ConversationAlternates ==
    \A i \in 1..(Len(conversationHistory)-1) :
        conversationHistory[i].role # conversationHistory[i+1].role

=============================================================================