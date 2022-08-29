;;; -*- lexical-binding: t; -*-

(setq confirm-kill-emacs nil)

(setq tab-bar-show 1)
(unless window-system
  (setq tab-bar-close-button-show nil)
  (setq tab-bar-format (delq 'tab-bar-format-add-tab tab-bar-format)))

(map! :g
      "C-h" 'delete-backward-char
      "C-c t t" 'toggle-truncate-lines
      "C-x b" 'helm-buffers-list
      "C-x j" 'goto-line
      "C-x m" 'multi-vterm
      "<C-left>" 'centaur-tabs-backward-tab
      "<C-right>" 'centaur-tabs-forward-tab
      "M-y" 'helm-show-kill-ring
      )

(use-package! anzu-mode
  :hook
  (after-init . global-anzu-mode)
  :config
  (setq anzu-search-threshold 1000)
  (setq anzu-minimum-input-length 3)
  )
(map! :g
      "M-%" 'anzu-query-replace
      "C-M-%" 'anzu-query-replace-regexp)

(use-package! centaur-tabs
  :hook
  (special-mode . centaur-tabs-mode)
  :config

  ;; workaround https://github.com/doomemacs/doomemacs/issues/6280
  (centaur-tabs-group-by-projectile-project)

  (unless window-system
    (setq centaur-tabs-set-close-button nil)
    (setq centaur-tabs-show-new-tab-button nil)
    ))

(use-package! eaw
  :config
  (unless window-system
    (eaw-fullwidth)))

(use-package! flycheck
  :config
  (if (/= 0 (call-process-shell-command "type textlint"))
      (display-warning load-file-name "cannot find 'textlint' command to use 'flycheck-define-checker textlint'")
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
  (setq helm-grep-file-path-style 'relative)
  (if (/= 0 (call-process-shell-command "type ag"))
      (display-warning load-file-name "cannot find 'ag' command to use 'helm-do-grep-ag'")
    (defalias 'find-grep 'helm-do-grep-ag)))

(use-package! helm-ghq
  :config
  (defalias 'ghq 'helm-ghq))

(use-package! helm-git-grep
  :config
  (defalias 'git-grep 'helm-git-grep))

(use-package! helm-ls-git
  :config
  (defalias 'git-ls-files 'helm-ls-git))

(use-package! server
  :config
  (unless (server-running-p)
  (server-start)))

(map! :mode special-mode
      "q" 'kill-buffer-and-window)

(use-package! switch-buffer-functions
  :hook
  (switch-buffer-functions . switch-buffer-functions-hooks)
  :config
  (defun switch-buffer-functions-hooks (prev cur)
    (if (eq major-mode 'yaml-mode)
        (which-function-mode +1)
      (which-function-mode -1))
    (setq word-wrap nil)
    (global-visual-line-mode -1)))

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

(use-package! undo-tree
  :hook
  (prog-mode . undo-tree-mode)
  (text-mode . undo-tree-mode)
  :config
  (add-to-list 'undo-tree-history-directory-alist
               `(".*" . ,(expand-file-name "undo-tree-history" doom-user-dir))))

(use-package! visws
  :hook
  (prog-mode . visible-whitespace-mode)
  (text-mode . visible-whitespace-mode)
  :config
  (setq visible-whitespace-mappings '((?\u3000 [?\u25a1]))))
