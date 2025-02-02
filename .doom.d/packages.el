;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here and run 'doom sync'
;; on the command line, then restart Emacs for the changes to take effect -- or


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
  :recipe (:build (:not compile))
  :pin "d6009c295a4363930247ae9a4d1125aea4d3fd74")
(package! centaur-tabs
  :disable (not (doom-module-active-p :ui 'tabs))
  :pin "63eb35cf42062ed19e9fc8cc5e971038c884f50f")
(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el")
  :pin "867a3debf907cbd7c5b0eb8837354a1efc7c2db9")
(package! eaw
  :recipe (:host github :repo "hamano/locale-eaw" :files ("dist/*.el"))
  :pin "6f8d5ddb29da3bde73e3d617ece5ba9fd16c335c")
(package! edit-indirect
  :pin "82a28d8a85277cfe453af464603ea330eae41c05")
(package! emacs-pager
  :recipe (:host github :repo "mbriggs/emacs-pager")
  :pin "7e1ee467b0f905fbdd3d208b480acaadab8410b9")
(package! ghq
  :pin "e9d7346c693af6b9473fa8ca3abc729692f582b1")
(package! helm-ghq
  :pin "7b47ac91e42762f2ecbbceeaadc05b86c9fe5f14")
(package! helm-ls-git
  :pin "d6d061704f375f809a2ee7644149a28e8770b35f")
(package! init-loader
  :pin "c4842b1f6695ce77daf94fd085456aeb37ed37e1")
(package! language-detection ;; used in edit-indirect
  :pin "54a6ecf55304fba7d215ef38a4ec96daff2f35a4")
(package! multi-term
  :pin "017c77c550115936860e2ea71b88e585371475d5")
(package! multi-vterm
  :pin "36746d85870dac5aaee6b9af4aa1c3c0ef21a905")
(package! nhexl-mode
  :pin "0b27339bdb3e5255353de457ad99724b0d83dcaf")
(package! seq ;; > Emergency (magit): Magit requires 'seq' >= 2.24,
  :pin "da86da9bf111f68fb81efd466d76d53af5aebc00")
(package! ssh-agency
  :ignore (not (eq system-type 'gnu/linux))
  :pin "a5377e4317365a3d5442e06d5c255d4a7c7618db")
(package! tty-format ;; from user42
  :pin "557d5137766f011f72a9324902ee23e650fa4c80")
(package! undo-tree
  :pin "d8f72bbe7d3c3a2808986febd3bb1a46d4da7f51")
(package! wgrep
  :recipe (:files ("*.el"))
  :pin "49f09ab9b706d2312cab1199e1eeb1bcd3f27f6f")
(package! xclip
  :disable (not (doom-module-active-p :os 'tty))
  :pin "9ab22517f3f2044e1c8c19be263da9803fbca26a")
(package! yaml-path
  :recipe (:host github :repo "gidoichi/yaml-path" :files ("emacs/yaml-path.el"))
  :pin "43bbde773efd2f66faee238b68a0e00a67e001a1")

(load
 (expand-file-name (concat "custom-" (file-name-nondirectory load-file-name)) doom-private-dir)
 'noerror)
