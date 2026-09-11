(ns gemini-repl.specs
  "Data specs for gemini-repl (https://clojure.org/guides/spec).
  Function specs (s/fdef) live next to each defn in gemini-repl.core.
  Generators are built inside thunks, so loading this ns never needs
  test.check (it is part of the release build)."
  (:require [clojure.spec.alpha :as s]
            [clojure.spec.gen.alpha :as gen]
            [clojure.string :as str]))

;; --- Slash commands (gemini-repl.core/commands) ---

(s/def ::command-name
  (s/with-gen (s/and string? #(str/starts-with? % "/"))
    #(gen/fmap (fn [s] (str "/" s)) (gen/string-alphanumeric))))

(s/def :gemini-repl.command/description string?)
;; a handler takes the command string; its return value is ignored
(s/def :gemini-repl.command/handler (s/with-gen fn? #(gen/return (fn [_] nil))))
(s/def ::command
  (s/keys :req-un [:gemini-repl.command/description :gemini-repl.command/handler]))
(s/def ::commands (s/map-of ::command-name ::command :gen-max 6))

;; --- REPL state (gemini-repl.core/repl-state) ---

(s/def :gemini-repl.stats/total-tokens nat-int?)
(s/def :gemini-repl.stats/total-cost (s/double-in :min 0 :infinite? false :NaN? false))
(s/def :gemini-repl.stats/request-count nat-int?)
(s/def ::stats
  (s/keys :req-un [:gemini-repl.stats/total-tokens :gemini-repl.stats/total-cost
                   :gemini-repl.stats/request-count]))

(s/def :gemini-repl.state/running boolean?)
(s/def :gemini-repl.state/debug boolean?)
(s/def ::repl-state
  (s/keys :req-un [:gemini-repl.state/running :gemini-repl.state/debug ::stats]))

;; --- Log entries (gemini-repl.core/log-entry builds them) ---

(s/def ::level #{"INFO" "WARN" "ERROR"})
(s/def ::component #{"api" "command"})
(s/def ::event #{"request" "response" "parse-error" "request-error" "execute" "unknown"})
;; e.g. {:prompt "hi"}, {:text nil} (no candidate text), {:command "/help"}
(s/def ::log-data (s/map-of simple-keyword? (s/nilable string?) :gen-max 3))

;; Date.toISOString, e.g. "2025-07-13T12:00:00.000Z"
(s/def ::timestamp
  (s/with-gen (s/and string? #(re-matches #"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z" %))
    #(gen/fmap (fn [ms] (.toISOString (js/Date. ms)))
               (gen/large-integer* {:min 0 :max 4102444800000}))))

(s/def :gemini-repl.log/data ::log-data)
(s/def ::log-entry
  (s/keys :req-un [::timestamp ::level ::component ::event :gemini-repl.log/data]))
