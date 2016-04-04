# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit gnome2-utils cmake-utils

IUSE="X systemd +extras -screengrab"
DESCRIPTION="i3-compatible window manager for Wayland (WIP)"
HOMEPAGE="http://swaywm.org"
SRC_URI="https://github.com/SirCmpwn/sway/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
DEPEND="
	dev-libs/json-c
	dev-libs/libpcre
	dev-libs/wlc
	media-gfx/imagemagick[png,raw]
	x11-libs/libxkbcommon
	X? ( x11-base/xorg-server[wayland] )
	systemd? ( sys-apps/systemd )
	extras? ( x11-libs/pango x11-libs/cairo x11-libs/gdk-pixbuf[jpeg] )
	screengrab? ( media-gfx/imagemagick virtual/ffmpeg )"
RDEPEND="${DEPEND}
	dev-libs/wayland"

S="${WORKDIR}/${PN}-${PV}"

src_prepare() {
	eapply_user # Add support for user patches
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DCMAKE_INSTALL_SYSCONFDIR=/etc
	)
	cmake-utils_src_configure
}

src_install() {
	# Few lines from zetok-overlay
	cmake-utils_src_install
	use !systemd && fperms u+s '/usr/bin/sway'
}
