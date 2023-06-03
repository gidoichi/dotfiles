;;; -*- lexical-binding: t; -*-

;; clipboard functions

(defun save-clipboard-on-region (start end)
  (interactive "r")
  (cond
   ((zerop (call-process-shell-command (mapconcat #'shell-quote-argument '("type" "clip.exe") " ")))
    (shell-command-on-region start end (shell-quote-argument "clip.exe") nil nil))
   ((zerop (call-process-shell-command (mapconcat #'shell-quote-argument '("type" "pbcopy") " ")))
    (shell-command-on-region start end (shell-quote-argument "pbcopy") nil nil))
   ((zerop (call-process-shell-command (mapconcat #'shell-quote-argument '("type" "xsel") " ")))
    (shell-command-on-region start end (mapconcat #'shell-quote-argument '("xsel" "--clipboard" "--input") " ") nil nil))
   (t (error "Cannot use clipboard"))))

(defun get-clipboard ()
  (interactive)
  (cond
   ((zerop (call-process-shell-command (mapconcat #'shell-quote-argument '("type" "pbpaste") " ")))
    (shell-command-to-string (shell-quote-argument "pbpaste")))
   ((zerop (call-process-shell-command (mapconcat #'shell-quote-argument '("type" "powershell.exe") " ")))
    (shell-command-to-string (mapconcat #'shell-quote-argument '("powershell.exe" "-command" "Get-Clipboard") " ")))
   ((zerop (call-process-shell-command (mapconcat #'shell-quote-argument '("type" "xclip") " ")))
    (shell-command-to-string (mapconcat #'shell-quote-argument '("xclip" "-out" "-selection" "clipboard") " ")))
   ((zerop (call-process-shell-command (mapconcat #'shell-quote-argument '("type" "xsel") " ")))
    (shell-command-to-string (mapconcat #'shell-quote-argument '("xsel" "--clipboard" "--output") " ")))
   (t (error "Cannot use clipboard"))))

(defun clipboard-kill-ring-save (start end)
  (interactive "r")
  (save-clipboard-on-region start end))

(defun clipboard-kill-region (start end)
  (interactive "r")
  (save-clipboard-on-region start end)
  (kill-region start end))


;; buffer formatting functions

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))


;; environment detection functions

(defun on-wsl ()
  "Whether emacs running on WSL or not.

Returns non-nil if on WSL, others not."
  (and (getenv "WSL_DISTRO_NAME")
       (executable-find "wsl-open")))

(defun on-mac ()
  "Whether emacs running on Mac or not.

Returns non-nil if on Mac, others not."
  (equal "Darwin" (string-trim-right (shell-command-to-string (shell-quote-argument "uname")))))
