.PHONY: all
all: diff

.PHONY: diff
diff: \
	.zpreztorc.diff \
	.doom.d/init.el.diff \
	.doom.d/packages.el.diff \
	.doom.d/config.el.diff \

define diff
	(diff -uN --label $(1) --label $(2) $(1) $(2) || true)
endef

.zprezto:
	git submodule update --init .zprezto

.zpreztorc.diff: .zprezto .zprezto/runcoms/zpreztorc .zpreztorc
	$(call diff,.zprezto/runcoms/zpreztorc,.zpreztorc) > $@

.emacs.d:
	git submodule update --init .emacs.d

.doom.d/init.el.diff: .emacs.d .emacs.d/static/init.example.el .doom.d/init.el
	$(call diff,.emacs.d/static/init.example.el,.doom.d/init.el) > $@

.doom.d/packages.el.diff: .emacs.d .emacs.d/static/packages.example.el .doom.d/packages.el
	$(call diff,.emacs.d/static/packages.example.el,.doom.d/packages.el) > $@

.doom.d/config.el.diff: .emacs.d .emacs.d/static/config.example.el .doom.d/config.el
	$(call diff,.emacs.d/static/config.example.el,.doom.d/config.el) > $@
