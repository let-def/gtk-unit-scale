archlinux-gtk3:
	# Download or update package sources
	if [ -d $@ ]; then cd $@ && git pull; else git clone https://gitlab.archlinux.org/archlinux/packaging/packages/gtk3.git --depth=1 --single-branch $@; fi
	# Copying patched files
	cp -l PKGBUILD-gtk3 gtk3_unit_scale.patch $@/
	# Install build dependencies, build and install
	cd $@ && makepkg --syncdeps --install -p PKGBUILD-gtk3

archlinux-gtk4:
	# Download or update package sources
	if [ -d $@ ]; then cd $@ && git pull; else git clone https://gitlab.archlinux.org/archlinux/packaging/packages/gtk4.git --depth=1 --single-branch $@; fi
	# Copying patched files
	cp -l PKGBUILD-gtk4 gtk4_unit_scale.patch $@/
	# Install build dependencies, build and install
	cd $@ && makepkg --syncdeps --install -p PKGBUILD-gtk4

fedora-gtk3:
	# Download package sources
	dnf download --source gtk3
	# Install package sources
	rpm -ivh gtk3-*.src.rpm
	# Install build dependencies
	sudo dnf builddep gtk3
	# Copy patch
	cp gtk3_unit_scale.patch ~/rpmbuild/SOURCES/
	# Update spec
	sh spec-patch.sh ~/rpmbuild/SPECS/gtk3.spec gtk3_unit_scale.patch
	# Build package
	rpmbuild -bb ~/rpmbuild/SPECS/gtk3.spec
	# These packages have been built
	@find ~/rpmbuild/RPMS/ -name 'gtk3-*.unit_scale.*'

fedora-gtk4:
	# Download package sources
	dnf download --source gtk4
	# Install package sources
	rpm -ivh gtk4-*.src.rpm
	# Install build dependencies
	sudo dnf builddep gtk4
	# Copy patch
	cp gtk4_unit_scale.patch ~/rpmbuild/SOURCES/
	# Update spec
	sh spec-patch.sh ~/rpmbuild/SPECS/gtk4.spec gtk4_unit_scale.patch
	# Build package
	rpmbuild -bb ~/rpmbuild/SPECS/gtk4.spec
	# These packages have been built
	@find ~/rpmbuild/RPMS/ -name 'gtk4-*.unit_scale.*'

.PHONY: archlinux-gtk3 archlinux-gtk4 fedora-gtk3 fedora-gtk4
