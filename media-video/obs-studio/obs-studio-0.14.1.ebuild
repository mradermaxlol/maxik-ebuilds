# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# Most of the ebuild taken from https://github.com/saintdev/obs-studio-overlay
# Thanks!

EAPI=6

inherit cmake-utils

DESCRIPTION="Free, open source software for live streaming and recording."
HOMEPAGE="https://obsproject.com"
SRC_URI="https://github.com/jp9000/obs-studio/archive/${PV}.zip -> obs-${PV}.zip"
LICENSE="GPL-2"
SLOT="0"
IUSE="fdk imagemagick jack +pulseaudio +qt5 truetype v4l"
KEYWORDS="-* ~amd64 ~x86"
RESTRICT="mirror"
DEPEND=">=dev-libs/jansson-2.5
	media-libs/x264
	media-video/ffmpeg
	x11-libs/libXinerama
	x11-libs/libXcomposite
	x11-libs/libXrandr
	fdk? ( media-libs/fdk-aac )
	imagemagick? ( media-gfx/imagemagick )
	jack? ( virtual/jack )
	pulseaudio? ( media-sound/pulseaudio )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtdeclarative:5
		dev-qt/qtgui:5
		dev-qt/qtmultimedia:5
		dev-qt/qtnetwork:5
		dev-qt/qtquickcontrols:5
		dev-qt/qtsql:5
		dev-qt/qttest:5
		dev-qt/qtwidgets:5
		dev-qt/qtx11extras:5
	)
	truetype? (
		media-libs/fontconfig
		media-libs/freetype
	)
	v4l? ( media-libs/libv4l )"
RDEPEND="${DEPEND}"

src_prepare() {
	CMAKE_REMOVE_MODULES_LIST=(FindFreetype) # From saintdev's overlay, dunno what is it for
	cmake-utils_src_prepare
}

src_configure() {
	local libdir=$(get_libdir)
	local mycmakeargs=(
		-DDISABLE_LIBFDK="$(usex fdk no yes)"
		-DLIBOBS_PREFER_IMAGEMAGICK="$(usex imagemagick)"
		-DDISABLE_JACK="$(usex jack no yes)"
		-DDISABLE_PULSEAUDIO="$(usex pulseaudio no yes)"
		-DENABLE_UI="$(usex qt5)"
		-DDISABLE_UI="$(usex qt5 no yes)"
		-DDISABLE_FREETYPE="$(usex truetype no yes)"
		-DDISABLE_V4L2="$(usex v4l no yes)"
		-DUNIX_STRUCTURE=1
		-DOBS_MULTIARCH_SUFFIX=${libdir#lib}
	)
	cmake-utils_src_configure
}

pkg_postinst() {
	if ! use pulseaudio && ! use jack; then
		ewarn "It is suggested you enable either JACK or PulseAudio,"
		ewarn "or you will not have audio capture capability."
	fi
}
