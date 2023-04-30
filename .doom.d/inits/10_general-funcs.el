;;; -*- lexical-binding: t; -*-

;; clipboard functions

(defun save-clipboard-on-region (start end)
  (interactive "r")
  (cond
   ((= 0 (call-process-shell-command "type clip.exe"))
    (shell-command-on-region start end "clip.exe" nil nil))
   ((= 0 (call-process-shell-command "type pbcopy"))
    (shell-command-on-region start end "pbcopy" nil nil))
   ((= 0 (call-process-shell-command "type xsel"))
    (shell-command-on-region start end "xsel --clipboard --input" nil nil))
   (t (error "Cannot use clipboard"))))

(defun get-clipboard ()
  (interactive)
  (cond
   ((= 0 (call-process-shell-command "type pbpaste"))
    (shell-command-to-string "pbpaste"))
   ((= 0 (call-process-shell-command "type powershell.exe"))
    (shell-command-to-string "powershell.exe -command Get-Clipboard"))
   ((= 0 (call-process-shell-command "type xclip"))
    (shell-command-to-string "xclip -out -selection clipboard"))
   ((= 0 (call-process-shell-command "type xsel"))
    (shell-command-to-string "xsel --clipboard --output"))
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
