(ns gemini-repl.specs-test
  "Generative checks for every pure s/fdef'd fn, plus data-spec sanity.
  Per https://clojure.org/guides/spec (Testing). No test here touches the
  network: make-request and everything that calls it are never invoked."
  (:require [cljs.test :refer [deftest is testing]]
            [clojure.set :as set]
            [clojure.spec.alpha :as s]
            [clojure.spec.test.alpha :as stest]
            [clojure.string :as str]
            [clojure.test.check]
            [clojure.test.check.clojure-test :refer [defspec]]
            [clojure.test.check.properties :as prop]
            [gemini-repl.core :as core]
            [gemini-repl.specs :as specs]))

(def ^:private check-opts {:clojure.spec.test.check/opts {:num-tests 50}})

;; Side-effecting fns: fdef'd for instrumentation, never generatively checked.
(def ^:private side-effecting
  `#{core/log-to-fifo core/log-to-file core/log               ; file/FIFO writes
     core/make-request core/process-input                     ; HTTPS to the Gemini API
     core/create-interface core/display-banner core/main})    ; stdin / print / exit

(defn- fdefd []
  (set (filter s/get-spec (stest/enumerate-namespace 'gemini-repl.core))))

;; cljs stest/check is a macro, so the checked fns are listed literally; the
;; last assertion keeps this list in sync with the fdefs in core.
(deftest fdefs-hold-under-generative-testing
  (let [results (stest/check `[core/log-entry] check-opts)]
    (is (seq results) "expected at least one fdef'd fn to check")
    (doseq [r results]
      (testing (str (:sym r))
        (is (nil? (:failure r))
            (pr-str (stest/abbrev-result r)))))
    (is (= (set/difference (fdefd) side-effecting) (set (map :sym results)))
        "every fdef in core is either checked or listed as side-effecting")))

(deftest data-specs-generate-and-conform
  (doseq [k [::specs/command-name ::specs/command ::specs/commands
             ::specs/repl-state ::specs/log-entry]]
    (testing (str k)
      (is (every? (fn [[v _]] (s/valid? k v)) (s/exercise k 10))))))

(defn- run-command
  "Runs a slash command's handler (as process-input does) and returns what it printed."
  [cmd]
  (with-out-str ((get-in core/commands [cmd :handler]) cmd)))

;; State transition: /debug flips :debug and leaves the rest of repl-state
;; alone. Runs against a scratch state and restores repl-state afterwards.
(defspec debug-command-toggles-only-debug 50
  (prop/for-all [state (s/gen ::specs/repl-state)]
                (let [saved @core/repl-state]
                  (try
                    (reset! core/repl-state state)
                    (let [out (run-command "/debug")]
                      (and (= (update state :debug not) @core/repl-state)
                           (str/includes? out (if (:debug state) "OFF" "ON"))))
                    (finally (reset! core/repl-state saved))))))

;; Formatting: /stats prints each counter from repl-state on its own line and
;; changes nothing.
(defspec stats-command-prints-counters 50
  (prop/for-all [state (s/gen ::specs/repl-state)]
                (let [saved @core/repl-state
                      {:keys [total-tokens total-cost request-count]} (:stats state)]
                  (try
                    (reset! core/repl-state state)
                    (let [out (run-command "/stats")]
                      (and (str/includes? out (str "  Requests: " request-count "\n"))
                           (str/includes? out (str "  Tokens: " total-tokens "\n"))
                           (str/includes? out (str "  Cost: $" (.toFixed total-cost 4) "\n"))
                           (= state @core/repl-state)))
                    (finally (reset! core/repl-state saved))))))

(deftest help-lists-every-command
  (let [out (run-command "/help")]
    (doseq [[cmd {:keys [description]}] core/commands]
      (is (str/includes? out (str "  " cmd " - " description))))))

(deftest real-values-conform
  (testing "the command table and REPL state"
    (is (s/valid? ::specs/commands core/commands))
    (is (s/valid? ::specs/repl-state {:running true :debug false
                                      :stats {:total-tokens 0 :total-cost 0 :request-count 0}}))
    (is (s/valid? ::specs/repl-state @core/repl-state)))
  (testing "log entries as make-request and process-input build them"
    (is (s/valid? ::specs/log-entry (core/log-entry "INFO" "api" "request" {:prompt "hi"})))
    (is (s/valid? ::specs/log-entry (core/log-entry "WARN" "command" "unknown" {:command "/nope"}))))
  (testing "core_test commands"
    (is (every? #(s/valid? ::specs/command-name %) ["/help" "/exit" "/clear" "/stats" "/debug"]))))
