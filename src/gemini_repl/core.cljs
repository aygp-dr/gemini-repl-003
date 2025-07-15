(ns gemini-repl.core
  (:require [cljs.nodejs :as nodejs]
            [clojure.string :as str]))

;; Node.js requires
(def readline (nodejs/require "readline"))
(def https (nodejs/require "https"))
(def fs (nodejs/require "fs"))

;; Configuration
(def api-key (or js/process.env.GEMINI_API_KEY ""))
(def api-endpoint "generativelanguage.googleapis.com")

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

;; API interaction
(defn make-request [prompt callback]
  (let [data (js/JSON.stringify 
               #js {:contents 
                    #js [#js {:parts 
                              #js [#js {:text prompt}]}]})]
    (.request https
              #js {:hostname api-endpoint
                   :path (str "/v1beta/models/gemini-pro:generateContent?key=" 
                             api-key)
                   :method "POST"
                   :headers #js {"Content-Type" "application/json"
                                "Content-Length" (.-length data)}}
              (fn [res]
                (let [chunks #js []]
                  (.on res "data" (fn [chunk]
                                   (.push chunks chunk)))
                  (.on res "end" (fn []
                                  (try
                                    (let [response (js/JSON.parse 
                                                   (.toString (.concat js/Buffer chunks)))
                                          text (-> response
                                                 (.-candidates)
                                                 (aget 0)
                                                 (.-content)
                                                 (.-parts)
                                                 (aget 0)
                                                 (.-text))]
                                      (callback nil text))
                                    (catch js/Error e
                                      (callback e nil))))))))))

;; REPL interface
(defn create-interface []
  (.createInterface readline
                   #js {:input js/process.stdin
                        :output js/process.stdout
                        :prompt "gemini> "}))

(defn process-input [rl input]
  (let [trimmed (str/trim input)]
    (cond
      ;; Empty input
      (empty? trimmed) 
      (.prompt rl)
      
      ;; Slash command
      (str/starts-with? trimmed "/")
      (if-let [command (get commands trimmed)]
        (do
          ((:handler command) trimmed)
          (when (:running @repl-state)
            (.prompt rl)))
        (do
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
  
  (let [rl (create-interface)]
    (.prompt rl)
    (.on rl "line" (partial process-input rl))
    (.on rl "close" (fn []
                     (println "\nGoodbye!")
                     (.exit js/process 0)))))

;; Enable direct execution
(set! *main-cli-fn* main)
