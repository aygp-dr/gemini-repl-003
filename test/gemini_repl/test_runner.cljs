(ns gemini-repl.test-runner
  (:require [cljs.test :as t]
            [gemini-repl.core-test]))

(defn main []
  (t/run-tests 'gemini-repl.core-test))

(set! *main-cli-fn* main)
