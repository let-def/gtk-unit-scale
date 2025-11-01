## GTK_UNIT_SCALE

This fork introduces a new environment variable `GTK_UNIT_SCALE` that allows you to scale all dimension units in GTK applications. This complements GTK's existing text scaling functionality by adjusting the physical dimensions of widgets while leaving text sizes unaffected (assuming proper CSS styling).

### Usage

Set the `GTK_UNIT_SCALE` environment variable to a floating-point value between 0.8 and 1.0 (1.0 has no effect). Values below 0.75 may cause visual glitches.

```bash
export GTK_UNIT_SCALE=0.9
... launch GTK apps ...
```

To apply the change system-wide, set the variable in `/etc/environment`:
```bash
GTK_UNIT_SCALE=0.9
```

### Benefits

- Increases information density for better usability
- Provides more compact widgets without affecting text size
- Offers an alternative to fractional scaling; at this point it is just downsampling which significantly decreases the rendering quality
- It should be useful on all screens, but it particularly shines on mid-DPI screens (like the Macbook Air below)
- It is theme independent; you can still enjoy the nice work of [Vince](https://github.com/vinceliuice) :)

### Testing

This patch has been successfully tested on:
- 15-inch MacBook Air (224 PPI) - can't live without it, a significant quality of life improvement
- 27-inch 4K display (163 PPI) - not necessary but a noticeable improvement

### Implementation

The patch is available for:
- [GTK 4](https://github.com/let-def/gtk/tree/gtk4-unit-scale)
- [GTK 3](https://github.com/let-def/gtk/tree/gtk3-unit-scale)

You probably want to apply both.

### Note

This patch is provided without guarantees and is maintained based on personal usage. It has worked well on recent Arch and Fedora systems. Consider this a temporary solution until a better (upstream?) solution becomes available.

## Installation

The [packaging](https://github.com/let-def/gtk/tree/packaging) branch provides a Makefile and templates for easily building packages.

The simplest way to build the packages:

``` sh
git clone --single-branch --branch=packaging https://github.com/let-def/gtk gtk-unit-scale-packaging
cd gtk-unit-scale-packaging

# For Archlinux
make archlinux-gtk3 archlinux-gtk4

# For Fedora
make fedora-gtk3
# Manually install the generated packages
make fedora-gtk4
# Manually install the generated packages
```

As for the actual changes, see:
- [Patch - GTK4](https://github.com/let-def/gtk/blob/packaging/gtk4_unit_scale.patch)
- [Patch - GTK3](https://github.com/let-def/gtk/blob/packaging/gtk3_unit_scale.patch)
- [Fedora - GTK4](https://github.com/let-def/gtk/blob/packaging/gtk4.spec)
- [Fedora - GTK3](https://github.com/let-def/gtk/blob/packaging/gtk3.spec)
- [Arch - GTK4](https://github.com/let-def/gtk/blob/packaging/PKGBUILD-gtk4)
- [Arch - GTK3](https://github.com/let-def/gtk/blob/packaging/PKGBUILD-gtk3)
