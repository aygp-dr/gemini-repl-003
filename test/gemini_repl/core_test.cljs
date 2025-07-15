(ns gemini-repl.core-test
  (:require [cljs.test :refer-macros [deftest is testing]]
            [gemini-repl.core :as core]))

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
