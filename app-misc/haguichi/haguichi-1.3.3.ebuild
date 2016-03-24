# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit gnome2-utils versionator

MAJOR_V=$(get_version_component_range 1-2)

DESCRIPTION="Haguichi provides a graphical frontend for Hamachi on Linux."
HOMEPAGE="https://www.haguichi.net"
SRC_URI="https://launchpad.net/haguichi/${MAJOR_V}/${PV}/+download/${PN}-${PV}.tar.xz"
LICENSE="GPL-3+"
SLOT="1.3"
KEYWORDS="-* ~amd64 ~x86"
DEPEND="
	sys-devel/gettext
	>=dev-util/cmake-2.6
	>=dev-libs/vala-common-0.28
	>=dev-lang/vala-0.26
	>=dev-libs/glib-2.42
	>=x11-libs/gtk+-3.14
	>=x11-libs/libnotify-0.7.6"
RDEPEND="${DEPEND}
	net-misc/logmein-hamachi"

S="${WORKDIR}/${PN}-${PV}"

src_unpack() {
	unpack ${PN}-${PV}.tar.xz
}

src_prepare() {
	mkdir ${S}/build
}

src_compile() {
	cmake .. -DCMAKE_INSTALL_PREFIX=/usr > ${S}/build
	emake -C "${S}/build" || die "Compilation failed!"
}

src_install() {
	emake DESTDIR=${D} -C "${S}/build" install || die "'make install' failed!"
	#FIXME: there are errors
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
