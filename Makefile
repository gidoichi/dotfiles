.PHONY: all
all: diff

.PHONY: submodule
submodule:
	git submodule update --init --recursive

.PHONY: diff
diff: submodule \
	install.diff \
	dotconf/.zpreztorc.diff \
	.doom.d/init.el.diff \
	.doom.d/packages.el.diff \
	.doom.d/config.el.diff \

define diff
	(diff -uN --label $(1) --label $(2) $(1) $(2) || true)
endef

install.diff: dotbot/tools/git-submodule/install install
	$(call diff,dotbot/tools/git-submodule/install,install) > $@

dotconf/.zpreztorc.diff: dotconf/zprezto/runcoms/zpreztorc dotconf/zpreztorc
	$(call diff,dotconf/zprezto/runcoms/zpreztorc,dotconf/zpreztorc) > $@

.doom.d/init.el.diff: .emacs.d/static/init.example.el .doom.d/init.el
	$(call diff,.emacs.d/static/init.example.el,.doom.d/init.el) > $@

.doom.d/packages.el.diff: .emacs.d/static/packages.example.el .doom.d/packages.el
	$(call diff,.emacs.d/static/packages.example.el,.doom.d/packages.el) > $@

.doom.d/config.el.diff: .emacs.d/static/config.example.el .doom.d/config.el
	$(call diff,.emacs.d/static/config.example.el,.doom.d/config.el) > $@
