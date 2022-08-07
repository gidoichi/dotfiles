;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name (getenv "USERFULLNAME")
      user-mail-address (getenv "EMAIL"))

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq confirm-kill-emacs nil)

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

(use-package! flycheck
  :config
  (if (/= 0 (call-process-shell-command "type textlint"))
      (display-warning load-file-name "cannot find 'textlint' command to use 'flycheck-define-checker textlint'")
    (flycheck-define-checker textlint
      "A linter for Markdown."
      :command ("textlint" "--format" "unix" source)
      :error-patterns
      ((warning line-start (file-name) ":" line ":" column ": "
                (message (minimal-match (one-or-more anychar)))
                "[" (id (one-or-more (not ?\s))) "]"
                line-end))
      :modes (text-mode markdown-mode gfm-mode))
    ))

(use-package! helm-ghq
  :config
  (defalias 'ghq 'helm-ghq))

(use-package! helm-git-grep
  :config
  (defalias 'git-grep 'helm-git-grep))

(use-package! helm-ls-git
  :config
  (defalias 'git-ls-files 'helm-ls-git))

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

(use-package! helm
  :config
  (setq helm-grep-file-path-style 'relative)
  (if (/= 0 (call-process-shell-command "type ag"))
      (display-warning load-file-name "cannot find 'ag' command to use 'helm-do-grep-ag'")
    (defalias 'find-grep 'helm-do-grep-ag)))

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

(map! :mode special-mode
      "q" 'kill-buffer-and-window)

(add-hook 'switch-buffer-functions 'switch-buffer-functions-hooks)
(defun switch-buffer-functions-hooks (prev cur)
  (if (eq major-mode 'yaml-mode)
      (which-function-mode +1)
    (which-function-mode -1)))

(use-package! undo-tree
  :hook
  (prog-mode . undo-tree-mode)
  (text-mode . undo-tree-mode)
  :config
  (add-to-list 'undo-tree-history-directory-alist
               `(".*" . ,(expand-file-name "undo-tree-history" doom-private-dir))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAJOR MODE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    (display-warning load-file-name "cannot find 'GIT_AUTHOR_NAME' env var to use 'magit'"))
  (unless (getenv "GIT_COMMITTER_NAME")
    (display-warning load-file-name "cannot find 'GIT_COMMITTER_NAME' env var to use 'magit'")))

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
  :hook
  (before-save . py-isort-before-save))

(defun term-mode-quoted-insert (ch)
  "Send any char (as CH) in term mode."
  (interactive "c")
  (term-send-raw-string (char-to-string ch)))
(defun term-send-clipboard ()
  "Send clipboard to terminal."
  (interactive)
  (term-send-raw-string
   (cond
    ((= 0 (call-process-shell-command "type xsel"))
     (shell-command-to-string "xsel --clipboard --output"))
    ((= 0 (call-process-shell-command "type pbpaste"))
     (shell-command-to-string "pbpaste"))
    ((= 0 (call-process-shell-command "type powershell.exe"))
     (shell-command-to-string "powershell.exe -command Get-Clipboard"))
    (t (error "Cannot use clipboard"))
    )))
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
    (vterm-send-string
     (cond
      ((= 0 (call-process-shell-command "type xsel"))
       (shell-command-to-string "xsel --clipboard --output"))
      ((= 0 (call-process-shell-command "type pbpaste"))
       (shell-command-to-string "pbpaste"))
      ((= 0 (call-process-shell-command "type powershell.exe"))
       (shell-command-to-string "powershell.exe -command Get-Clipboard"))
      (t (error "Cannot use clipboard"))
      )))
  (defun vterm-mode-hooks ()
    (define-key vterm-mode-map (kbd "C-c C-y") 'vterm-send-clipboard)
    (define-key vterm-mode-map (kbd "C-h") 'vterm-send-C-h)
    (define-key vterm-mode-map (kbd "C-k") 'vterm-not-copy-mode-kill-line)
    (define-key vterm-mode-map (kbd "C-q") 'vterm-mode-quoted-insert)
    (define-key vterm-mode-map (kbd "<C-left>") 'centaur-tabs-backward-tab)
    (define-key vterm-mode-map (kbd "<C-right>") 'centaur-tabs-forward-tab)
    (face-remap-set-base 'link nil)
    (face-remap-add-relative 'link 'underline 'italic)
    )
  )

(use-package! yaml-mode
  :hook
  (yaml-mode . yaml-path-which-func)
  :config
  (if (/= 0 (call-process-shell-command "type yaml-path"))
      (display-warning load-file-name "cannot find 'yaml-path' command to use 'yaml-path-which-func'")
    (defalias 'find-grep 'helm-do-grep-ag)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LOCAL CONFIG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(doom-load-envvars-file (expand-file-name "myenv" doom-private-dir) 'noerror)
(load (expand-file-name (concat "custom-" (file-name-nondirectory load-file-name)) doom-private-dir) 'noerror)
