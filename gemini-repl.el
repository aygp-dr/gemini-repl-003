;;; gemini-repl.el --- Emacs configuration for Gemini REPL Clojure development

;; Set up package archives
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; Install required packages if not already installed
(defvar gemini-repl-packages
  '(clojure-mode
    cider
    paredit
    company
    rainbow-delimiters))

(dolist (pkg gemini-repl-packages)
  (unless (package-installed-p pkg)
    (package-refresh-contents)
    (package-install pkg)))

;; Basic Emacs settings
(setq inhibit-startup-message t)
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq column-number-mode t)
(setq line-number-mode t)
(global-display-line-numbers-mode 1)

;; Enable paredit for Clojure
(add-hook 'clojure-mode-hook #'paredit-mode)
(add-hook 'cider-repl-mode-hook #'paredit-mode)
(add-hook 'emacs-lisp-mode-hook #'paredit-mode)

;; Enable rainbow delimiters
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;; Company mode for auto-completion
(add-hook 'after-init-hook 'global-company-mode)

;; CIDER configuration
(setq cider-repl-display-help-banner nil)
(setq cider-repl-pop-to-buffer-on-connect t)
(setq cider-show-error-buffer t)
(setq cider-auto-select-error-buffer t)
(setq cider-repl-history-file "~/.cider-repl-history")
(setq cider-repl-wrap-history t)
(setq cider-font-lock-dynamically '(macro core function var))

;; ClojureScript specific settings
(setq cider-cljs-lein-repl
      "(do (require 'figwheel-sidecar.repl-api)
           (figwheel-sidecar.repl-api/start-figwheel!)
           (figwheel-sidecar.repl-api/cljs-repl))")

;; Custom key bindings
(global-set-key (kbd "C-c C-j") 'cider-jack-in)
(global-set-key (kbd "C-c C-J") 'cider-jack-in-cljs)
(global-set-key (kbd "C-c C-q") 'cider-quit)

;; Set project root
(setq default-directory (or (getenv "PROJECT_ROOT") default-directory))

;; Org mode support for literate programming
(require 'org)
(require 'ob-clojure)
(setq org-babel-clojure-backend 'cider)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((clojure . t)))

;; TRAMP configuration for remote development
(require 'tramp)
(setq tramp-default-method "ssh")
(setq tramp-verbose 6)

;; Display welcome message
(message "Gemini REPL Emacs environment loaded!")
(message "Project root: %s" default-directory)
(message "Use C-c C-j for cider-jack-in, C-c C-J for ClojureScript")

;; Open the main source file
(when (file-exists-p "src/gemini_repl/core.cljs")
  (find-file "src/gemini_repl/core.cljs"))

(provide 'gemini-repl)
;;; gemini-repl.el ends here