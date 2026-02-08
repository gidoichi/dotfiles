.PHONY: all
all: diff

.PHONY: submodule
submodule:
	git submodule update --init --recursive

.PHONY: diff
diff: submodule \
	install.diff \
	dotconf/.zpreztorc.diff \
	dotconf/doom.d/init.el.diff \
	dotconf/doom.d/packages.el.diff \
	dotconf/doom.d/config.el.diff \

define diff
	(diff -uN --label $(1) --label $(2) $(1) $(2) || true)
endef

install.diff: dotbot/tools/git-submodule/install install
	$(call diff,dotbot/tools/git-submodule/install,install) > $@

dotconf/.zpreztorc.diff: dotconf/zprezto/runcoms/zpreztorc dotconf/zpreztorc
	$(call diff,dotconf/zprezto/runcoms/zpreztorc,dotconf/zpreztorc) > $@

dotconf/doom.d/init.el.diff: dotconf/emacs.d/static/init.example.el dotconf/doom.d/init.el
	$(call diff,dotconf/emacs.d/static/init.example.el,dotconf/doom.d/init.el) > $@

dotconf/doom.d/packages.el.diff: dotconf/emacs.d/static/packages.example.el dotconf/doom.d/packages.el
	$(call diff,dotconf/emacs.d/static/packages.example.el,dotconf/doom.d/packages.el) > $@

dotconf/doom.d/config.el.diff: dotconf/emacs.d/static/config.example.el dotconf/doom.d/config.el
	$(call diff,dotconf/emacs.d/static/config.example.el,dotconf/doom.d/config.el) > $@
