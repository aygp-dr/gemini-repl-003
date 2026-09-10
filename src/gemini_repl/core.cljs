(ns gemini-repl.core
  (:require [cljs.nodejs :as nodejs]
            [clojure.string :as str]))

;; Node.js requires
(def readline (nodejs/require "readline"))
(def https (nodejs/require "https"))
(def ^js fs (nodejs/require "fs"))
(def ^js path (nodejs/require "path"))

;; Configuration
(def api-key (or js/process.env.GEMINI_API_KEY ""))
(def api-endpoint "generativelanguage.googleapis.com")

;; Logging configuration
(def log-level (or js/process.env.GEMINI_LOG_LEVEL "info"))
(def log-enabled (not= js/process.env.GEMINI_LOG_ENABLED "false"))
(def fifo-path (or js/process.env.GEMINI_LOG_FIFO "/tmp/gemini-repl.fifo"))
(def log-file-path (or js/process.env.GEMINI_LOG_FILE "logs/gemini-repl.log"))

;; State
(defonce repl-state (atom {:running true
                           :debug false
                           :stats {:total-tokens 0
                                   :total-cost 0
                                   :request-count 0}}))

;; Slash commands
(def commands
  {"/help" {:description "Show available commands"
            :handler (fn [_]
                       (println "\nAvailable commands:")
                       (doseq [[cmd {:keys [description]}] commands]
                         (println (str "  " cmd " - " description))))}

   "/exit" {:description "Exit the REPL"
            :handler (fn [_]
                       (println "Goodbye!")
                       (swap! repl-state assoc :running false)
                       (.exit js/process 0))}

   "/clear" {:description "Clear the screen"
             :handler (fn [_]
                        (print "\033[2J\033[H"))}

   "/stats" {:description "Show usage statistics"
             :handler (fn [_]
                        (let [{:keys [total-tokens total-cost request-count]}
                              (:stats @repl-state)]
                          (println "\nUsage Statistics:")
                          (println (str "  Requests: " request-count))
                          (println (str "  Tokens: " total-tokens))
                          (println (str "  Cost: $" (.toFixed total-cost 4)))))}

   "/debug" {:description "Toggle debug mode"
             :handler (fn [_]
                        (swap! repl-state update :debug not)
                        (println (str "Debug mode: "
                                      (if (:debug @repl-state) "ON" "OFF"))))}})

;; Logging functions
(defn log-entry [level component event data]
  {:timestamp (.toISOString (js/Date.))
   :level level
   :component component
   :event event
   :data data})

(defn log-to-fifo [entry]
  (when (and log-enabled (.existsSync fs fifo-path))
    (try
      (.appendFileSync fs fifo-path (str (.stringify js/JSON (clj->js entry)) "\n"))
      (catch js/Error _
        ;; Silently fail if FIFO not available
        nil))))

(defn log-to-file [entry]
  (when log-enabled
    (try
      ;; Ensure logs directory exists
      (let [log-dir (.dirname path log-file-path)]
        (when-not (.existsSync fs log-dir)
          (.mkdirSync fs log-dir #js {:recursive true})))
      ;; Append to log file
      (.appendFileSync fs log-file-path
                       (str (.toISOString (js/Date.)) " "
                            (:level entry) " "
                            "[" (:component entry) "] "
                            (:event entry) " "
                            (.stringify js/JSON (clj->js (:data entry))) "\n"))
      (catch js/Error _
        ;; Silently fail if can't write to file
        nil))))

(defn log [level component event data]
  (when log-enabled
    (let [entry (log-entry level component event data)]
      (log-to-fifo entry)
      (log-to-file entry))))

;; API interaction
(defn make-request [prompt callback]
  (log "INFO" "api" "request" {:prompt prompt})
  (let [data (js/JSON.stringify
              #js {:contents
                   #js [#js {:parts
                             #js [#js {:text prompt}]}]})
        ^js req (.request https
                          #js {:hostname api-endpoint
                               :path (str "/v1beta/models/gemini-2.0-flash-exp:generateContent?key="
                                          api-key)
                               :method "POST"
                               :headers #js {"Content-Type" "application/json"
                                             "Content-Length" (.-length data)}}
                          (fn [^js res]
                            (let [chunks #js []]
                              (.on res "data" (fn [chunk]
                                                (.push chunks chunk)))
                              (.on res "end" (fn []
                                               (try
                                                 (let [^js response (js/JSON.parse
                                                                     (.toString (.concat js/Buffer chunks)))
                                                       text (-> response
                                                                (.-candidates)
                                                                (aget 0)
                                                                ^js (.-content)
                                                                (.-parts)
                                                                (aget 0)
                                                                (.-text))]
                                                   (log "INFO" "api" "response" {:text text})
                                                   (callback nil text))
                                                 (catch js/Error e
                                                   (log "ERROR" "api" "parse-error" {:error (.-message e)})
                                                   (callback e nil))))))))]
    (.on req "error" (fn [e]
                       (log "ERROR" "api" "request-error" {:error (.-message e)})
                       (callback e nil)))
    (.write req data)
    (.end req)))

;; REPL interface
(defn create-interface []
  (let [^js rl-module readline]
    (.createInterface rl-module
                      #js {:input js/process.stdin
                           :output js/process.stdout
                           :prompt "gemini> "})))

(defn process-input [^js rl input]
  (let [trimmed (str/trim input)]
    (cond
      ;; Empty input
      (empty? trimmed)
      (.prompt rl)

      ;; Slash command
      (str/starts-with? trimmed "/")
      (if-let [command (get commands trimmed)]
        (do
          (log "INFO" "command" "execute" {:command trimmed})
          ((:handler command) trimmed)
          (when (:running @repl-state)
            (.prompt rl)))
        (do
          (log "WARN" "command" "unknown" {:command trimmed})
          (println (str "Unknown command: " trimmed))
          (.prompt rl)))

      ;; Regular prompt
      :else
      (do
        (when (:debug @repl-state)
          (println "[DEBUG] Sending to Gemini API..."))
        (make-request trimmed
                      (fn [err response]
                        (if err
                          (println (str "Error: " (.-message err)))
                          (do
                            (println response)
                            (swap! repl-state update-in [:stats :request-count] inc)))
                        (.prompt rl)))))))

(defn display-banner []
  (println "")
  (println "=== Gemini REPL ===")
  (println "Type /help for commands")
  (println ""))

(defn main []
  (when (empty? api-key)
    (println "Error: GEMINI_API_KEY environment variable not set")
    (.exit js/process 1))

  (display-banner)

  (let [^js rl (create-interface)]
    (.prompt rl)
    (.on rl "line" (partial process-input rl))
    (.on rl "close" (fn []
                      (println "\nGoodbye!")
                      (.exit js/process 0)))))

;; Enable direct execution
(set! *main-cli-fn* main)
