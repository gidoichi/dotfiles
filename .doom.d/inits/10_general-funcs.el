;;; -*- lexical-binding: t; -*-

(defun save-clipboard-on-region (start end)
  (interactive "r")
  (cond
   ((= 0 (call-process-shell-command "type xsel"))
    (shell-command-on-region (region-beginning) (region-end) "xsel --clipboard --input" nil nil))
   ((= 0 (call-process-shell-command "type pbcopy"))
    (shell-command-on-region (region-beginning) (region-end) "pbcopy" nil nil))
   ((= 0 (call-process-shell-command "type clip.exe"))
    (shell-command-on-region (region-beginning) (region-end) "clip.exe" nil nil))
   (t (error "Cannot use clipboard"))))

(defun get-clipboard ()
  (interactive "r")
  (cond
   ((= 0 (call-process-shell-command "type xsel"))
    (shell-command-to-string "xsel --clipboard --output"))
   ((= 0 (call-process-shell-command "type pbpaste"))
    (shell-command-to-string "pbpaste"))
   ((= 0 (call-process-shell-command "type powershell.exe"))
    (shell-command-to-string "powershell.exe -command Get-Clipboard"))
   (t (error "Cannot use clipboard"))))

(defun clipboard-kill-ring-save (start end)
  (interactive "r")
  (save-clipboard-on-region (region-beginning) (region-end)))

(defun clipboard-kill-region (start end)
  (interactive "r")
  (save-clipboard-on-region (region-beginning) (region-end))
  (kill-region (region-beginning) (region-end)))