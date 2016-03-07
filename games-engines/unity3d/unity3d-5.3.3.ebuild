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

S="${WORKDIR}/unity-editor-${PV_F}"
FILES="${S}/Files"

src_unpack() {
	yes | fakeroot sh "${DISTDIR}/${PN}.sh" > /dev/null || die "Failed unpacking archive!"
}

src_prepare() {
	ln -s /usr/bin/python2 ${S}/Editor/python # Fix WebGL building
	mkdir -p ${FILES}
	cp -R ${FILESDIR}/* ${FILES}/
	sed -i "/^Version=/c\Version=5.3.3" "${FILES}/unity-editor.desktop"
	sed -i "/^Version=/c\Version=5.3.3" "${FILES}/unity-monodevelop.desktop"
}

src_compile() {
	true; # Workaround for some portage issues
}

src_install() {
	insinto /opt/Unity
	doins -r ${S}/*

	fperms 4755 ${D}/opt/Unity/Editor/chrome-sandbox

	insopts "-Dm644"
	insinto /usr/share/applications
	doins "${FILES}/unity-editor.desktop"
	doins "${FILES}/unity-monodevelop.desktop"

	insinto /usr/share/icons/hicolor/256x256/apps
	doins "${S}/unity-editor-icon.png"
	insinto /usr/share/icons/hicolor/48x48/apps
	doins "${FILES}/unity-monodevelop.png"
	
	insopts "-Dm755"
	insinto /usr/bin
	doins "${FILES}/unity-editor"
	doins "${FILES}/monodevelop-unity"

	insopts "-Dm644"
	insinto /usr/share/licenses/${PN}
	doins "${FILES}/EULA"
}
