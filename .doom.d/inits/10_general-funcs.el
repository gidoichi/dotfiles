;;; -*- lexical-binding: t; -*-

;; clipboard functions

(defun get-clipboard ()
  (cond
   ((functionp 'xclip-get-selection)
    (xclip-get-selection 'clipboard))
   ((functionp 'clipboard-yank)
    (with-temp-buffer
      (clipboard-yank)
      (buffer-string)))))


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
  (featurep :system 'macos))
