;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here and run 'doom sync'
;; on the command line, then restart Emacs for the changes to take effect -- or
;; use 'M-x doom/reload'.


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;; (package! some-package)

;; To install a package directly from a remote git repo, you must specify a
;; `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/radian-software/straight.el#the-recipe-format
;; (package! another-package
;;   :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;; (package! this-package
;;   :recipe (:host github :repo "username/repo"
;;            :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
;; (package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;; (package! builtin-package :recipe (:nonrecursive t))
;; (package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see radian-software/straight.el#279)
;; (package! builtin-package :recipe (:branch "develop"))

;; Use `:pin' to specify a particular commit to install.
;; (package! builtin-package :pin "1a2b3c4d5e")


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
;; (unpin! pinned-package)
;; ...or multiple packages
;; (unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
;; (unpin! t)


(package! centaur-tabs
  ;; workaround https://github.com/doomemacs/doomemacs/issues/7904
  :pin "d6009c295a4363930247ae9a4d1125aea4d3fd74"
  :recipe (:build (:not compile)))
(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el" "dist")))
(package! eaw
  :recipe (:host github :repo "hamano/locale-eaw" :files ("dist/*.el")))
(package! emacs-pager
  :recipe (:host github :repo "mbriggs/emacs-pager"))
(package! ghq)
(package! helm-ghq)
(package! helm-git-grep
  ;; use unofficial forked repository
  :recipe (:host github :repo "PythonNut/helm-git-grep")
  :pin "2af218934b6e98b37a1501613717c18b0c1f0d6c")
(package! helm-ls-git)
(package! init-loader)
(package! multi-term)
(package! multi-vterm)
(package! nhexl-mode)
(package! seq) ;; > Emergency (magit): Magit requires 'seq' >= 2.24,
(package! ssh-agency
  :ignore (not (eq system-type 'gnu/linux)))
(package! tty-format) ;; from user42
(package! undo-tree)
(package! wgrep)
(package! yaml-path
  :recipe (:host github :repo "gidoichi/yaml-path" :files ("emacs/yaml-path.el")))

(load
 (expand-file-name (concat "custom-" (file-name-nondirectory load-file-name)) doom-private-dir)
 'noerror)
