archlinux-gtk3:
	# Download or update package sources
	if [ -d $@ ]; then cd $@ && git pull; else git clone https://gitlab.archlinux.org/archlinux/packaging/packages/gtk3.git --depth=1 --single-branch $@; fi
	# Copy patch
	cp -l gtk3_unit_scale.patch $@/
	# Update PKGBUILD
	awk -f pkgbuild-patch.awk archlinux-gtk3/PKGBUILD gtk3_unit_scale.patch > archlinux-gtk3/PKGBUILD-unit-scale
	# Install build dependencies, build and install
	cd $@ && makepkg --syncdeps --install -p PKGBUILD-unit-scale

archlinux-gtk4:
	# Download or update package sources
	if [ -d $@ ]; then cd $@ && git pull; else git clone https://gitlab.archlinux.org/archlinux/packaging/packages/gtk4.git --depth=1 --single-branch $@; fi
	# Copy patch
	cp -l gtk4_unit_scale.patch $@/
	# Update PKGBUILD
	awk -f pkgbuild-patch.awk archlinux-gtk4/PKGBUILD gtk4_unit_scale.patch > archlinux-gtk4/PKGBUILD-unit-scale
	# Install build dependencies, build and install
	cd $@ && makepkg --syncdeps --install -p PKGBUILD-unit-scale

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

fedora-revert:
	# Revert packages to upstraem versions
	sudo dnf downgrade  gtk3 gtk4 --allowerasing

debian-gtk3:
	# Download package sources
	mkdir -p $@
	cd $@ && apt source gtk+3.0
	# Install build dependencies
	sudo apt-get build-dep -y gtk+3.0
	# Apply patch and build package
	test -n "$$(find $@ -mindepth 1 -maxdepth 1 -type d -name 'gtk+3.0-*' -print -quit)"
	cp gtk3_unit_scale.patch "$$(find $@ -mindepth 1 -maxdepth 1 -type d -name 'gtk+3.0-*' -print -quit)/"
	cd "$$(find $@ -mindepth 1 -maxdepth 1 -type d -name 'gtk+3.0-*' -print -quit)" && dch --local +unit-scale --distribution UNRELEASED "Apply GTK unit scale patch"
	cd "$$(find $@ -mindepth 1 -maxdepth 1 -type d -name 'gtk+3.0-*' -print -quit)" && patch -p1 < gtk3_unit_scale.patch && dpkg-buildpackage -us -uc -b
	# These packages have been built
	@find $@ -maxdepth 1 -type f -name 'libgtk-3-*.deb'

debian-gtk4:
	# Download package sources
	mkdir -p $@
	cd $@ && apt source gtk4
	# Install build dependencies
	sudo apt-get build-dep -y gtk4
	# Apply patch and build package
	test -n "$$(find $@ -mindepth 1 -maxdepth 1 -type d -name 'gtk4-*' -print -quit)"
	cp gtk4_unit_scale.patch "$$(find $@ -mindepth 1 -maxdepth 1 -type d -name 'gtk4-*' -print -quit)/"
	cd "$$(find $@ -mindepth 1 -maxdepth 1 -type d -name 'gtk4-*' -print -quit)" && dch --local +unit-scale --distribution UNRELEASED "Apply GTK unit scale patch"
	cd "$$(find $@ -mindepth 1 -maxdepth 1 -type d -name 'gtk4-*' -print -quit)" && patch -p1 < gtk4_unit_scale.patch && dpkg-buildpackage -us -uc -b
	# These packages have been built
	@find $@ -maxdepth 1 -type f -name 'libgtk-4-*.deb'

.PHONY: archlinux-gtk3 archlinux-gtk4 fedora-gtk3 fedora-gtk4 fedora-revert debian-gtk3 debian-gtk4
