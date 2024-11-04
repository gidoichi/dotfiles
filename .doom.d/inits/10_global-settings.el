;;; -*- lexical-binding: t; -*-

(setq confirm-kill-emacs nil)
(setq max-specpdl-size 5000)
(map! :g
        "S-<insert>" 'clipboard-yank)

(when (and (on-mac) window-system)
  (define-key global-map [menu-bar buffer] nil)
  (define-key global-map [menu-bar edit] nil)
  (define-key global-map [menu-bar help-menu] nil)
  (define-key global-map [menu-bar options] nil))

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
  (advice-add #'browse-url-can-use-xdg-open
              :after-until #'on-wsl)
  )

(use-package! centaur-tabs
  :hook
  (special-mode . centaur-tabs-mode)
  :config
  (map! :g
        "<C-left>" 'centaur-tabs-backward-tab
        "<C-right>" 'centaur-tabs-forward-tab)
  (unless window-system
    (setq centaur-tabs-set-close-button nil)
    (setq centaur-tabs-show-new-tab-button nil))
  (advice-add #'centaur-tabs-buffer-groups
              :before-until (lambda (&rest _)
                              "Assign user defined group."
                              (if (derived-mode-p 'vterm-mode)
                                  (list "Vterm"))))
  )

(use-package! copilot
  :hook (prog-mode . copilot-mode-hooks)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word))
  :config
  (setq copilot-indent-offset-warning-disable t)
  (defun copilot-mode-hooks ()
    (when (file-exists-p copilot-install-dir)
      (copilot-mode))))

(use-package! eaw-fullwidth
  :if (not window-system))

(use-package! edit-indirect
  :config

  ;; This function is based on the forked version of edit-indirect.el:
  ;; https://github.com/a13/edit-indirect/blob/0c3ce3d3a16ec669123a208a4966f5a3bd6f1ab7/edit-indirect.el#L231-L243
  ;; However, the original does not include a mapping between language and major mode.
  (defun edit-indirect-language-detection-guess-mode (parent-buffer beg end)
    "Guess the major mode from the PARENT-BUFFER substring from BEG to END using `language-detection.el'."
    (if (fboundp #'language-detection-string)
        (let* ((indirect-substring (with-current-buffer parent-buffer
                                   (buffer-substring-no-properties beg end)))
               (mode (with-temp-buffer
                       (insert indirect-substring)
                       (language-detection-buffer-auto-detect-mode))))
          (if (fboundp mode)
              (funcall mode)
            (message "Mode %s detected, but isn't available." mode)
            (normal-mode)))
      (message "`language-detection' package is not installed.")
      (normal-mode)))

  (setq edit-indirect-guess-mode-function #'edit-indirect-language-detection-guess-mode))

(use-package! flycheck
  :config
  (if (not (zerop (call-process-shell-command (mapconcat #'shell-quote-argument '("type" "textlint") " "))))
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

(use-package! ghq
  :config
  (defalias 'ghq-get (symbol-function 'ghq)))

(use-package! helm
  :config
  (map! :g
        "C-x b" 'helm-buffers-list
        "M-y" 'helm-show-kill-ring)
  (setq helm-grep-file-path-style 'relative)
  (if (not (zerop (call-process-shell-command (mapconcat #'shell-quote-argument '("type" "ag") " "))))
      (display-warning (if load-file-name (intern load-file-name)
                         'my-init)
                       "cannot find 'ag' command to use 'helm-do-grep-ag'"
                       :warning "*Messages*")
    (fset 'find-grep 'helm-do-grep-ag)
    (fmakunbound 'grep-find)))

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
  (advice-add #'helm-ghq--source
              :around (lambda (_ repo)
                        "Refactored version of the original helm-ghq--source."
                        (let ((name (file-name-nondirectory (directory-file-name repo))))
                          (helm-build-in-buffer-source name
                            :init #'helm-ghq--ls-files
                            :display-to-real (lambda (selected)
                                               (expand-file-name selected repo))
                            :action helm-ghq--action))))
  )

(use-package! helm-grep
  :config
  (defun git-grep ()
    "Search all files in the repository."
    (interactive)
    (helm-grep-do-git-grep 'all))
  )

(use-package! helm-ls-git
  :config
  (fset 'git-ls-files 'helm-ls-git))

(use-package! hide-mode-line
  :config
  ;; want to just disable hide-mode-line-mode at vterm-mode
  ;; workaround https://github.com/doomemacs/doomemacs/issues/6209
  (advice-add #'hide-mode-line-mode :around #'ignore)
  )

(use-package! language-detection
  :config
  ;; This function is introduced in the README:
  ;; https://github.com/andreasjansson/language-detection.el/blob/54a6ecf55304fba7d215ef38a4ec96daff2f35a4/README.md#L143-L191
  (defun language-detection-buffer-auto-detect-mode ()
    (let* ((map '((ada ada-mode)
                  (awk awk-mode)
                  (c c-mode)
                  (cpp c++-mode)
                  (clojure clojure-mode lisp-mode)
                  (csharp csharp-mode java-mode)
                  (css css-mode)
                  (dart dart-mode)
                  (delphi delphi-mode)
                  (emacslisp emacs-lisp-mode)
                  (erlang erlang-mode)
                  (fortran fortran-mode)
                  (fsharp fsharp-mode)
                  (go go-mode)
                  (groovy groovy-mode)
                  (haskell haskell-mode)
                  (html html-mode)
                  (java java-mode)
                  (javascript javascript-mode)
                  (json json-mode javascript-mode)
                  (latex latex-mode)
                  (lisp lisp-mode)
                  (lua lua-mode)
                  (matlab matlab-mode octave-mode)
                  (objc objc-mode c-mode)
                  (perl perl-mode)
                  (php php-mode)
                  (prolog prolog-mode)
                  (python python-mode)
                  (r r-mode)
                  (ruby ruby-mode)
                  (rust rust-mode)
                  (scala scala-mode)
                  (shell shell-script-mode)
                  (smalltalk smalltalk-mode)
                  (sql sql-mode)
                  (swift swift-mode)
                  (visualbasic visual-basic-mode)
                  (xml sgml-mode)))
           (language (language-detection-string
                      (buffer-substring-no-properties (point-min) (point-max))))
           (modes (cdr (assoc language map)))
           (mode (cl-loop for mode in modes
                          when (fboundp mode)
                          return mode)))
      (message (format "%s" language))
      (when (fboundp mode)
        mode)))
  )

(use-package! multi-vterm
  :init
  (map! :g "C-x m" 'multi-vterm)
  :hook
  ;; multi-vterm "requires" vterm and vterm tries to compile vterm-module when loading.
  ;; To avoid compile at emacs startup, a hook is needed to defer loading package until use.
  (multi-vterm-mode . multi-vterm)
  )

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

(use-package! projectile
  :config
  ;; disable doom setting to exclude git submodules
  ;; https://github.com/doomemacs/doomemacs/blob/8b9168de6e6a9cabf13d1c92558e2ef71aa37a72/lisp/doom-projects.el#L164-L177
  (advice-remove #'projectile-get-ext-command #'doom--only-use-generic-command-a)
  (setq projectile-git-use-fd nil)

  (when (and (on-mac) window-system)
    (define-key projectile-mode-map [menu-bar projectile] nil)))

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

(use-package! xclip
  :config

  ;; HACK: https://github.com/emacs-straight/xclip/blob/9ab22517f3f2044e1c8c19be263da9803fbca26a/xclip.el#L116
  ;; xclip finds some exectable files with an extention but uses them without it.
  ;; Fix this logic to ensure they are used with the extention.
  (setq xclip-program
        (if (eq xclip-method 'powershell)
            (concat (symbol-name xclip-method) ".exe")
          (symbol-name xclip-method)))

  ;; HACK: https://github.com/emacs-straight/xclip/blob/9ab22517f3f2044e1c8c19be263da9803fbca26a/xclip.el#L192-L196
  ;; A newline is inserted at the end of the pipeline output.
  ;; Retrieve the raw clipboard content without additional newline.
  ;; FIXME: This workaround is too slow for processing.
  (advice-add
   #'xclip-get-selection
   :before-until (lambda (type)
                   "Get raw text."
                   (when (eq xclip-method 'powershell)
                     (with-output-to-string
                       (when (memq type '(clipboard CLIPBOARD))
                         (let ((coding-system-for-read 'dos)) ;Convert CR->LF.
                           (call-process "powershell.exe" nil `(,standard-output nil) nil
                                         "-command" "$a = Get-Clipboard -Raw ; Write-Host $a -NoNewline")))))))
  )

(use-package! yasnippet
  :config
  (when (and (on-mac) window-system)
    (define-key yas-minor-mode-map [menu-bar yasnippet] nil)))
