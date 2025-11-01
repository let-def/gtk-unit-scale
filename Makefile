archlinux-gtk3:
	if [ -d $@ ]; then cd $@ && git pull; else git clone https://gitlab.archlinux.org/archlinux/packaging/packages/gtk3.git --depth=1 --single-branch $@; fi
	cp -l PKGBUILD-gtk3 gtk3_unit_scale.patch $@/
	cd $@ && makepkg --syncdeps --install -p PKGBUILD-gtk3

archlinux-gtk4:
	if [ -d $@ ]; then cd $@ && git pull; else git clone https://gitlab.archlinux.org/archlinux/packaging/packages/gtk4.git --depth=1 --single-branch $@; fi
	cp -l PKGBUILD-gtk4 gtk4_unit_scale.patch $@/
	cd $@ && makepkg --syncdeps --install -p PKGBUILD-gtk4

.PHONY: archlinux-gtk3 archlinux-gtk4
