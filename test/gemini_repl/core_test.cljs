(ns gemini-repl.core-test
  (:require [cljs.test :refer-macros [deftest is testing use-fixtures]]
            [clojure.spec.test.alpha :as stest]
            [gemini-repl.core :as core]))

;; Exercise every s/fdef :args spec while the unit tests run.
(use-fixtures :once
  (fn [f] (stest/instrument) (try (f) (finally (stest/unstrument)))))

(deftest test-commands-exist
  (testing "Slash commands are defined"
    (is (contains? core/commands "/help"))
    (is (contains? core/commands "/exit"))
    (is (contains? core/commands "/clear"))
    (is (contains? core/commands "/stats"))
    (is (contains? core/commands "/debug"))))

(deftest test-initial-state
  (testing "Initial REPL state"
    (is (true? (:running @core/repl-state)))
    (is (false? (:debug @core/repl-state)))
    (is (= 0 (get-in @core/repl-state [:stats :total-tokens])))
    (is (= 0 (get-in @core/repl-state [:stats :request-count])))))

(deftest test-command-handlers
  (testing "Command handlers exist and are functions"
    (doseq [[cmd {:keys [handler]}] core/commands]
      (is (fn? handler) (str "Handler for " cmd " should be a function")))))

(deftest test-debug-toggle
  (testing "Debug mode toggle"
    (let [initial-debug (:debug @core/repl-state)]
      ;; Execute debug command handler
      ((get-in core/commands ["/debug" :handler]) "/debug")
      (is (not= initial-debug (:debug @core/repl-state)) "Debug mode should toggle")
      ;; Toggle back
      ((get-in core/commands ["/debug" :handler]) "/debug")
      (is (= initial-debug (:debug @core/repl-state)) "Debug mode should toggle back"))))

(deftest test-api-configuration
  (testing "API configuration"
    (is (string? core/api-endpoint) "API endpoint should be a string")
    (is (= "generativelanguage.googleapis.com" core/api-endpoint) "API endpoint should be correct")))
