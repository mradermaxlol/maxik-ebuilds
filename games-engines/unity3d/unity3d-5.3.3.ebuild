# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

BUILDTAG=20160223
PV_F=${PV}f1 # Workaround for that ugly f-revision
IUSE="ffmpeg nodejs java gzip android"
DESCRIPTION="The world's most popular development platform for creating 2D and 3D multiplatform games and interactive experiences."
HOMEPAGE="https://unity3d.com/"
SRC_URI="http://download.unity3d.com/download_unity/linux/unity-editor-installer-${PV_F}+${BUILDTAG}.sh -> ${PN}.sh"

LICENSE="custom"
SLOT="5"
KEYWORDS="-* ~amd64 amd64" # Package is x86_64-only

RDEPEND="ffmpeg? ( media-video/ffmpeg )
	nodejs? ( net-libs/nodejs )
	java? ( virtual/jdk virtual/jre )
	android? ( dev-util/android-studio )
	gzip? ( app-arch/gzip )
	dev-util/desktop-file-utils
	x11-misc/xdg-utils
	sys-devel/gcc[multilib]
	virtual/opengl
	virtual/glu
	dev-libs/nss
	media-libs/libpng
	x11-libs/libXtst
	dev-libs/libpqxx
	dev-util/monodevelop
	net-libs/nodejs[npm]"
DEPEND="${RDEPEND}
	sys-apps/fakeroot"

src_unpack() {
	echo "Extracting archive... Please wait."
	yes | fakeroot sh "${DISTDIR}/${PN}.sh" > /dev/null || die "Failed unpacking archive!"
	echo "Done extracting archive!"
	rm "${DISTDIR}/${PN}.sh"
}

src_install() {
	ln -s /usr/bin/python2 ${WORKDIR}/unity-editor-${PV_F}/Editor/python # Fix WebGL building
	sed -i "/^Exec=/c\Exec=/usr/bin/unity-editor" "${WORKDIR}/unity-editor-${PV_F}/unity-editor.desktop"
	sed -i "/^Exec=/c\Exec=/usr/bin/monodevelop-unity" "${WORKDIR}/unity-editor-${PV_F}/unity-monodevelop.desktop"
}

pkg_postinst () {
	gnome2_icon_cache_update
}

pkg_postrm () {
	gnome2_icon_cache_update
}
