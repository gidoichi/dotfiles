;;; -*- lexical-binding: t; -*-

(use-package! emacs-pager
  :mode
  ("\\.emacs-pager\\'" . emacs-pager-mode)
  :config
  ;; overwrite mode
  (define-derived-mode emacs-pager-mode fundamental-mode "Pager"
    "Mode for viewing data paged by emacs-pager"
    (setq-local make-backup-files nil)
    (when (save-excursion
          (goto-char (point-min))
          (re-search-forward "[^\b]\b[^\b]" nil t))
        (format-decode-buffer 'backspace-overstrike)
        ;; no error disables format-decode-buffer
        (error nil))
    (when (save-excursion
          (goto-char (point-min))
          (re-search-forward ansi-color-regexp nil t))
        (ansi-color-apply-on-region (point-min) (point-max)))
    (read-only-mode)
    (set-buffer-modified-p nil)))

(use-package! go-mode
  :hook
  (go-mode . go-mode-hooks)
  :config
  (defun go-mode-hooks ()
    (add-hook! before-save
               :local
               'gofmt-before-save
               'lsp-organize-imports
               )))

(use-package! magit
  :config
  (unless (getenv "GIT_AUTHOR_NAME")
    (display-warning 'my-init
                     "cannot find 'GIT_AUTHOR_NAME' env var to use 'magit'"
                     :warning "*Messages*"))
  (unless (getenv "GIT_COMMITTER_NAME")
    (display-warning 'my-init
                     "cannot find 'GIT_COMMITTER_NAME' env var to use 'magit'"
                     :warning "*Messages*")))

(use-package! markdown-mode
  :hook
  (markdown-mode . markdown-mode-hooks)
  :mode
  ("\\.Rmd\\'" . markdown-mode)
  :init
  (when window-system
    (setq markdown-header-scaling t))
  :config
  (setq markdown-fontify-code-blocks-natively t)
  (unless window-system
    (add-to-ordered-list 'markdown-url-compose-char 8943 1))
  (defun markdown-mode-hooks ()
    (setq markdown-hide-urls t)
    (when (flycheck-registered-checker-p 'textlint)
      (setq flycheck-checker 'textlint))
    ))

(use-package! org
  :config
  (setq org-startup-folded 'content))

;; python-mode
(use-package! elpy
  :hook
  (python-mode . elpy-enable)
  (python-mode . elpy-mode-hooks)
  :config
  (defun elpy-mode-hooks ()
    (assq-delete-all 'elpy-mode minor-mode-map-alist))
  )
(use-package! lsp-pyright
  ;; :init npm install pyright
  :hook
  (python-mode . lsp-deferred)
  )
(use-package! py-isort
  ;; :init pip install isort
  :hook
  (before-save . py-isort-before-save))

;; c.f. following other implementations
;; Prism: https://github.com/PrismJS/prism/blob/master/components/prism-shell-session.js
;; Rouge: https://github.com/rouge-ruby/rouge/blob/master/lib/rouge/lexers/console.rb
(define-generic-mode shell-session-mode
  nil nil
  '(("\\(^.*?\\)\\(\\$\\|#\\|>\\)\\(.*\\)"
     (1 font-lock-comment-face t)
     (2 font-lock-comment-face t)
     (3 font-lock-string-face t))
    )
  '("\\.sh-session\\'" "\\.console\\'")
  nil
  "shell-session-mode for hilighting console log")
(define-derived-mode console-mode shell-session-mode "console")

(defun term-mode-quoted-insert (ch)
  "Send any char (as CH) in term mode."
  (interactive "c")
  (term-send-raw-string (char-to-string ch)))
(defun term-send-clipboard ()
  "Send clipboard to terminal."
  (interactive)
  (term-send-raw-string (get-clipboard)))
(defun term-mode-hooks ()
  (read-only-mode t)
  (setq term-bind-key-alist (delq (assoc "C-r" term-bind-key-alist) term-bind-key-alist))
  (add-to-list 'term-bind-key-alist '("C-c C-j" . term-line-mode))
  (add-to-list 'term-bind-key-alist '("C-c C-k" . term-char-mode))
  (add-to-list 'term-bind-key-alist '("C-c C-y" . term-send-clipboard))
  (add-to-list 'term-bind-key-alist '("C-h" . term-send-backspace))
  (add-to-list 'term-bind-key-alist '("C-q" . term-mode-quoted-insert))
  (add-to-list 'term-bind-key-alist '("<C-left>" . centaur-tabs-backward-tab))
  (add-to-list 'term-bind-key-alist '("<C-right>" . centaur-tabs-forward-tab))
  )
(add-hook 'term-mode-hook 'term-mode-hooks)

(use-package! typescript-mode
  :hook
  (typescript-mode . lsp-deferred)
  (typescript-mode . prettier-mode)
  (typescript-mode . typescript-mode-hooks)
  :config
  (defun typescript-mode-hooks ()
    (add-hook! before-save
               :local 'prettier-prettify))
  )

(use-package! vterm
  :hook
  (vterm-mode . goto-address-mode)
  (vterm-mode . vterm-mode-hooks)
  (vterm-copy-mode . vterm-copy-mode-hooks)
  :config
  (defun vterm-mode-quoted-insert (ch)
    "Send any char (as CH) in term mode."
    (interactive "c")
    (vterm-send-string (char-to-string ch)))
  (defun vterm-not-copy-mode-kill-line ()
    "Kill line in vterm mode with the possibility to paste it like in a normal shell."
    (interactive)
    (when vterm-copy-mode
      (user-error "This command is effective only not in vterm-copy-mode"))
    (vterm-copy-mode 1)
    (set-mark-command nil)
    (goto-char (vterm--get-end-of-line))
    (if vterm-copy-exclude-prompt
        (vterm-copy-mode-done nil)
      (vterm-copy-mode-done t))
    (vterm-send-C-k))
  (defun vterm-send-clipboard ()
    "Send clipboard to terminal."
    (interactive)
    (vterm-send-string (get-clipboard)))
  (defun vterm-update-mode-line ()
    (setq mode-line-process (list ": " (if vterm-copy-mode
                                           "cp" ;; copy-mode
                                         "ia" ;; interactive mode
                                         ))))
  (defun vterm-mode-hooks ()
    (define-key vterm-mode-map (kbd "C-c C-y") 'vterm-send-clipboard)
    (define-key vterm-mode-map (kbd "C-h") 'vterm-send-C-h)
    (define-key vterm-mode-map (kbd "C-k") 'vterm-not-copy-mode-kill-line)
    (define-key vterm-mode-map (kbd "C-q") 'vterm-mode-quoted-insert)
    (define-key vterm-mode-map (kbd "<C-left>") 'centaur-tabs-backward-tab)
    (define-key vterm-mode-map (kbd "<C-right>") 'centaur-tabs-forward-tab)
    (face-remap-set-base 'link nil)
    (face-remap-add-relative 'link 'underline 'italic)
    (vterm-update-mode-line)
    )
  (defun vterm-copy-mode-hooks ()
    (vterm-update-mode-line))
  )

(use-package! yaml-mode
  :hook
  (yaml-mode . yaml-path-which-func)
  :config
  (if (/= 0 (call-process-shell-command "type yaml-path"))
      (display-warning 'my-init
                       "cannot find 'yaml-path' command to use 'yaml-path-which-func'"
                       :warning "*Messages*")
    (defalias 'find-grep 'helm-do-grep-ag)))
