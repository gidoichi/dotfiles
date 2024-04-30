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
    (display-warning (if load-file-name (intern load-file-name)
                       'my-init)
                     "cannot find 'GIT_AUTHOR_NAME' env var to use 'magit'"
                     :warning "*Messages*"))
  (unless (getenv "GIT_COMMITTER_NAME")
    (display-warning (if load-file-name (intern load-file-name)
                       'my-init)
                     "cannot find 'GIT_COMMITTER_NAME' env var to use 'magit'"
                     :warning "*Messages*"))
  (setq magit-diff-paint-whitespace-lines 'all)
  (defun magit-open-repo ()
    "open remote repo URL in browser."
    (interactive)
    (let* ((remote (magit-get "remote" "origin" "url"))
           ;; assumed "remote" are:
           ;; - https://github.com/user/repository.git
           ;; - ssh://git@github.com/user/repository.git
           ;; - git@github.com:user/repository.git
           ;; then url="https://github.com/user/repository.git"
           (url (if (string-match "^http" remote)
                    remote
                  (replace-regexp-in-string "\\(.*\\)@\\([^:/]*\\)[:/]\\(.*\\)" "https://\\2/\\3" remote))))
      (browse-url url)
      (message "opening repo %s" url)))
  (map! :mode magit-mode "C-o" 'magit-open-repo)
  (add-to-list 'helm-boring-buffer-regexp-list "\\`\\magit-[a-z0-9-]+: ")
  )

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

(define-derived-mode whexl-mode fundamental-mode "Whexl"
  "writable hexl-mode based on nhexl-mode."
  (nhexl-mode))

(use-package! org
  :config
  (setq org-startup-folded 'content)
  (advice-add #'org-agenda-switch-to :around
              (lambda (orig-fun &rest args)
                "Open org file and close buffers used to visit agenda."
                (let* ((orig-buffer (current-buffer))
                       (orig-point (point))
                       (marker (org-get-at-bol 'org-marker))
                       (target-buffer (marker-buffer marker))
                       (buffer-updated))
                  (if target-buffer
                      (progn
                        (org-release-buffers (remove target-buffer org-agenda-new-buffers))
                        (setq org-agenda-new-buffers nil)
                        (apply orig-fun args))
                    (with-temp-buffer
                      (let ((temp-buffer (current-buffer)))
                        (with-current-buffer orig-buffer
                          (copy-to-buffer temp-buffer (point-min) (point-max)))
                        (org-todo-list)
                        (setq buffer-updated
                              (not (string= (with-current-buffer temp-buffer (buffer-string))
                                            (with-current-buffer orig-buffer (buffer-string)))))))
                    (goto-char orig-point)
                    (if buffer-updated
                        (progn
                          (org-release-buffers org-agenda-new-buffers)
                          (setq org-agenda-new-buffers nil)
                          (error "Update org-todo-list"))

                      (setq marker (org-get-at-bol 'org-marker)
                            target-buffer (marker-buffer marker))
                      (org-release-buffers (remove target-buffer org-agenda-new-buffers))
                      (setq org-agenda-new-buffers nil)
                      (apply orig-fun args))))))

  ;; Call org-todo-list without new buffers when it called from org-agenda.
  ;; Using advice-remove is to avoid to call this cusomized org-todo-list recursively.
  (advice-add #'org-agenda :around
              (lambda (orig-fun &rest args)
                (advice-add #'org-todo-list :override #'my-org-todo-list-without-new-burrers)
                (apply orig-fun args)
                (advice-remove #'org-todo-list #'my-org-todo-list-without-new-burrers)))
  (defun my-org-todo-list-without-new-burrers (&rest _)
    (advice-remove 'org-todo-list 'my-org-todo-list-without-new-burrers)
    (org-todo-list)
    (org-release-buffers org-agenda-new-buffers)
    (setq org-agenda-new-buffers nil)
    (advice-add #'org-todo-list :override #'my-org-todo-list-without-new-burrers)
    )
  )

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

(use-package! term
  :hook
  (term-mode . term-mode-hooks)
  :config
  (defun term-mode-quoted-insert (ch)
    "Send char CH in term mode."
    (interactive "c")
    (term-send-raw-string (char-to-string ch)))
  (defun term-send-clipboard ()
    "Send clipboard to terminal."
    (interactive)
    (term-send-raw-string (get-clipboard)))
  (defun term-mode-hooks ()
    (read-only-mode t)

    ;; term-bind-key-alist is only used in multi-term not term
    (when (boundp 'term-bind-key-alist)
      (setq term-bind-key-alist (delq (assoc "C-r" term-bind-key-alist) term-bind-key-alist))
      (add-to-list 'term-bind-key-alist '("C-c C-j" . term-line-mode))
      (add-to-list 'term-bind-key-alist '("C-c C-k" . term-char-mode))
      (add-to-list 'term-bind-key-alist '("C-c C-y" . term-send-clipboard))
      (add-to-list 'term-bind-key-alist '("C-h" . term-send-backspace))
      (add-to-list 'term-bind-key-alist '("C-q" . term-mode-quoted-insert))
      (add-to-list 'term-bind-key-alist '("<C-left>" . centaur-tabs-backward-tab))
      (add-to-list 'term-bind-key-alist '("<C-right>" . centaur-tabs-forward-tab)))
    )
  )

(use-package! terraform-mode
  :hook
  (terraform-mode . terraform-mode-hooks)
  :config
  (defun terraform-mode-hooks ()
    (add-hook! before-save :local 'terraform-format-buffer)))

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
  (setq vterm-copy-mode-remove-fake-newlines t)
  (defun before-vterm-send-C-k (&rest _)
    "Save to kill-ring."
    (let* ((whole-content (buffer-substring (point) (vterm-end-of-line)))
           (trimmed-content (string-trim-right whole-content)))
      (with-temp-buffer
        (insert trimmed-content)
        (kill-ring-save (point-min) (point-max)))))
  (advice-add #'vterm-send-C-k :before #'before-vterm-send-C-k)
  (advice-add #'vterm-send-key :before
              (lambda (&rest r)
                "Save to kill-ring with C-k."
                (when (equal r '("k" nil nil (control)))
                  (apply #'before-vterm-send-C-k r))))
  (defun vterm-mode-helm-show-kill-ring ()
    "Send kill-ring to vterm again after helm."
    (interactive)
    (helm-show-kill-ring)
    (vterm-send-string (car kill-ring)))
  (defun vterm-mode-quoted-insert (ch)
    "Send char CH in term mode."
    (interactive "c")
    (vterm-send-string (char-to-string ch)))
  (defun vterm-send-clipboard ()
    "Send clipboard to terminal."
    (interactive)
    (vterm-send-string (get-clipboard)))
  (defun vterm-update-mode-line ()
    (setq mode-line-process (list ": " (if vterm-copy-mode
                                           "cp" ;; copy-mode
                                         "ia" ;; interactive mode
                                         ))))
  (map! :mode vterm-mode
        "C-c C-y" #'vterm-send-clipboard
        "C-h" #'vterm-send-C-h
        "C-q" #'vterm-mode-quoted-insert
        "M-y" #'vterm-mode-helm-show-kill-ring
        "<C-left>" #'centaur-tabs-backward-tab
        "<C-right>" #'centaur-tabs-forward-tab)
  (defun vterm-mode-hooks ()
    (setq confirm-kill-processes t)
    (face-remap-set-base 'link nil)
    (face-remap-add-relative 'link 'underline 'italic)
    (vterm-update-mode-line)
    )
  (defun vterm-copy-mode-hooks ()
    (vterm-update-mode-line))
  )

(use-package! wgrep
  :config
  (setq wgrep-enable-key (kbd "e")
        wgrep-auto-save-buffer t))

(use-package! yaml-mode
  :hook
  (yaml-mode . yaml-path-which-func)
  :config
  (if (not (zerop (call-process-shell-command (mapconcat #'shell-quote-argument '("type" "yaml-path") " "))))
      (display-warning (if load-file-name (intern load-file-name)
                         'my-init)
                       "cannot find 'yaml-path' command to use 'yaml-path-which-func'"
                       :warning "*Messages*")
    (add-to-list 'which-func-modes 'yaml-mode)))
