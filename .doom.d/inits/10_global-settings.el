;;; -*- lexical-binding: t; -*-

(setq confirm-kill-emacs nil)
(setq max-specpdl-size 5000)

(use-package! anzu-mode
  :hook
  (after-init . global-anzu-mode)
  :init
  (map! :g
        "M-%" 'anzu-query-replace
        "C-M-%" 'anzu-query-replace-regexp)
  :config
  (setq anzu-search-threshold 1000)
  (setq anzu-minimum-input-length 3)
  )

(use-package! browse-url
  :config
  (advice-add 'browse-url-can-use-xdg-open
              :after-until 'on-wsl)
  )

(use-package! centaur-tabs
  :hook
  (special-mode . centaur-tabs-mode)
  :config
  (map! :g
        "<C-left>" 'centaur-tabs-backward-tab
        "<C-right>" 'centaur-tabs-forward-tab)
  ;; workaround https://github.com/doomemacs/doomemacs/issues/6280
  (centaur-tabs-group-by-projectile-project)

  (unless window-system
    (setq centaur-tabs-set-close-button nil)
    (setq centaur-tabs-show-new-tab-button nil))
  )

(use-package! eaw
  :config
  (unless window-system
    (eaw-fullwidth)))

(use-package! flycheck
  :config
  (if (/= 0 (call-process-shell-command "type textlint"))
      (display-warning (if load-file-name (intern load-file-name)
                         'my-init)
                       "cannot find 'textlint' command to use 'flycheck-define-checker textlint'"
                       :warning "*Messages*")
    (setq textlint-config-file (expand-file-name ".textlintrc" (getenv "HOME")))
    (flycheck-define-checker textlint
      "A linter for Markdown."
      :command ("textlint" "--format" "unix" "--config" (eval textlint-config-file) source)
      :error-patterns
      ((warning line-start (file-name) ":" line ":" column ": "
                (message (minimal-match (one-or-more anychar)))
                "[" (id (one-or-more (not ?\s))) "]"
                line-end))
      :modes (text-mode markdown-mode gfm-mode))
    ))

(use-package! helm
  :config
  (map! :g
        "C-x b" 'helm-buffers-list
        "M-y" 'helm-show-kill-ring)
  (setq helm-grep-file-path-style 'relative)
  (if (/= 0 (call-process-shell-command "type ag"))
      (display-warning (if load-file-name (intern load-file-name)
                         'my-init)
                       "cannot find 'ag' command to use 'helm-do-grep-ag'"
                       :warning "*Messages*")
    (fset 'find-grep 'helm-do-grep-ag)))

(use-package! helm-ghq
  :config
  (defun ghq ()
    "Extend original helm-ghq function to show without full path.
see: https://github.com/masutaka/emacs-helm-ghq/blob/7b47ac91e42762f2ecbbceeaadc05b86c9fe5f14/helm-ghq.el#L229-L238"
    (interactive)
    (let* ((helm-ghq-command-ghq-arg-list '("list"))
           (repo (expand-file-name
                  (helm-comp-read "ghq-list: "
                                  (helm-ghq--list-candidates)
                                  :name "ghq list"
                                  :must-match t)
                  (helm-ghq--root))))
      (let ((default-directory (file-name-as-directory repo)))
        (helm :sources (list (helm-ghq--source default-directory)
                             (helm-ghq--source-update repo))
              :buffer "*helm-ghq-list*"))))

  ;; In vterm-mode, default-directory is overwritten by current directory indicator inside terminal.
  ;; To avoid this, remove default-directory from helm-ghq function.
  (advice-add 'helm-ghq--source
              :around (lambda (_ repo)
                        "Refactored version of the original helm-ghq--source."
                        (let ((name (file-name-nondirectory (directory-file-name repo))))
                          (helm-build-in-buffer-source name
                            :init #'helm-ghq--ls-files
                            :display-to-real (lambda (selected)
                                               (expand-file-name selected repo))
                            :action helm-ghq--action))))
  )

(use-package! helm-git-grep
  :config
  (fset 'git-grep 'helm-git-grep))

(use-package! helm-ls-git
  :config
  (fset 'git-ls-files 'helm-ls-git))

(use-package! hide-mode-line
  :config
  ;; want to just disable hide-mode-line-mode at vterm-mode
  ;; workaround https://github.com/doomemacs/doomemacs/issues/6209
  (advice-add 'hide-mode-line-mode :around #'ignore)
  )

(use-package! multi-vterm
  :config
  (map! :g "C-x m" 'multi-vterm))

(use-package! nhexl-mode
  :hook
  (nhexl-mode . nhexl-mode-hooks)
  :config
  (defun nhexl-mode-hooks ()

    ;; warkaround https://emacs.stackexchange.com/questions/19290/nhexl-mode-shows-bytes-80-ff-with-6-digit-hex-3fff80-3fffff
    (when nhexl-mode
      ;; Turn off multibyte, otherwise nhexl 0.1 displays non-ASCII characters
      ;; in hexa as values in the range 3fff80-3fffff instead of 80-ff.
      (if (and (fboundp 'toggle-enable-multibyte-characters)
               enable-multibyte-characters)
          (toggle-enable-multibyte-characters)))

    ))

(use-package! prog-mode
  :hook
  (prog-mode . prog-mode-hooks)
  :config
  (defun prog-mode-hooks ()
    (setq show-trailing-whitespace t)))

(use-package! server
  :config
  (unless (server-running-p)
  (server-start)))

(use-package! simple
  :config
  (map! :g
        "C-h" 'delete-backward-char
        "C-c t t" 'toggle-truncate-lines
        "C-x j" 'goto-line)
  (map! :mode special-mode "q" 'kill-buffer-and-window)
  (if (on-wsl)
      (advice-add 'kill-new
                  :after (lambda (&rest _)
                           "Get latest one form kill-ring and save to clipboard."
                           (with-temp-buffer
                             (insert (current-kill 0 t))
                             (save-clipboard-on-region (point-min) (point-max))))))
  )

(use-package! tab-bar
  :config
  (setq tab-bar-show 1)
  (unless window-system
    (setq tab-bar-close-button-show nil)
    (setq tab-bar-format (delq 'tab-bar-format-add-tab tab-bar-format)))
  )

(use-package! treemacs
  :config
  (setq doom-themes-treemacs-theme "doom-colors")
  (pcase (cons (not (null (executable-find "git")))
               (not (null treemacs-python-executable)))
    (`(t . t) (treemacs-git-mode 'deferred))
    (`(t . _) (treemacs-git-mode 'simple)))
  (treemacs-follow-mode t)
  (treemacs-project-follow-mode t)
  )

(use-package! text-mode
  :hook
  (text-mode . text-mode-hooks)
  :config
  (remove-hook 'text-mode-hook 'visual-line-mode)
  (defun text-mode-hooks ()
    (setq show-trailing-whitespace t)
    (setq truncate-lines nil)
    (setq word-wrap nil)))

(use-package! transient
  :init
  (setq transient-values-file (expand-file-name "etc/transient/values.el" doom-user-dir)))

(use-package! tty-format
  :init
  ;; remove necessarily settings at
  ;; https://github.com/emacs-mirror/emacs/commit/35ed01dfb3f811a997e26d843e9971eb6b81b125
  (defconst ansi-color-regexp "\033\\[\\([0-9;]*m\\)"
    "Regexp that matches SGR control sequences."))

(use-package! undo-tree
  :hook
  (prog-mode . undo-tree-mode)
  (text-mode . undo-tree-mode)
  :config
  (add-to-list 'undo-tree-history-directory-alist
               `(".*" . ,(expand-file-name "undo-tree-history" doom-user-dir))))

(use-package! which-func
  :config
  (if (not (listp which-func-modes))
      (setq which-func-modes '()))
  (which-function-mode))

(use-package! whitespace
  :hook
  (whitespace-mode . whitespace-mode-hooks)
  :config
  (defun whitespace-mode-hooks ()
    (add-hook! before-save :local 'doom/delete-trailing-newlines)))
