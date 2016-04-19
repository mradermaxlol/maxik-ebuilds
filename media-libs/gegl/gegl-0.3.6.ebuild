# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 )

# Vala and introspection support is broken, bug #468208
VALA_MIN_API_VERSION=0.20
VALA_USE_DEPEND=vapigen

inherit versionator gnome2-utils eutils autotools python-any-r1 vala

DESCRIPTION="GEGL (Generic Graphics Library) is a graph based image processing framework."
HOMEPAGE="http://gegl.org"
SRC_URI="http://download.gimp.org/pub/${PN}/${PV:0:3}/${P}.tar.bz2"
LICENSE="|| ( GPL-3 LGPL-3 )"
SLOT="0.3"
IUSE="cairo cpu_flags_x86_mmx cpu_flags_x86_sse debug ffmpeg +introspection jpeg jpeg2k lcms lensfun openexr png raw sdl svg test tiff umfpack vala v4l webp"
REQUIRED_IUSE="
	svg? ( cairo )
	vala? ( introspection )"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~amd64-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
DEPEND="
	>=dev-libs/glib-2.36:2
	dev-libs/json-glib
	>=media-libs/babl-0.1.14
	sys-libs/zlib
	>=x11-libs/gdk-pixbuf-2.18:2
	x11-libs/pango

	cairo? ( x11-libs/cairo )
	ffmpeg? (
		>=media-video/ffmpeg-2.8:0=
	)
	introspection? ( >=dev-libs/gobject-introspection-1.32 )
	jpeg? ( virtual/jpeg:0= )
	jpeg2k? ( >=media-libs/jasper-1.900.1 )
	lcms? ( >=media-libs/lcms-2.2:2 )
	lensfun? ( >=media-libs/lensfun-0.2.5 )
	openexr? ( media-libs/openexr )
	png? ( media-libs/libpng:0= )
	raw? ( >=media-libs/libraw-0.15.4 )
	sdl? ( media-libs/libsdl )
	svg? ( >=gnome-base/librsvg-2.14:2 )
	tiff? ( >=media-libs/tiff-4:0 )
	umfpack? ( sci-libs/umfpack )
	v4l? ( >=media-libs/libv4l-1.0.1 )
	webp? ( media-libs/libwebp )
	>=dev-util/gtk-doc-am-1
	>=dev-util/intltool-0.40.1
	dev-lang/perl
	virtual/pkgconfig
	>=sys-devel/libtool-2.2
	test? ( introspection? (
		$(python_gen_any_dep '>=dev-python/pygobject-3.2[${PYTHON_USEDEP}]') ) )
	vala? ( $(vala_depend) )"
RDEPEND="${DEPEND}"

RESTRICT="test" # Because it may either fail or be incompatible

pkg_setup() {
	use test && use introspection && python-any-r1_pkg_setup
}

src_prepare() {
	# FIXME: the following should be proper patch sent to upstream
	# Fix OSX loadable module filename extension
	sed -i -e 's/\.dylib/.bundle/' configure.ac || die
	# Don't require Apple's OpenCL on versions of OSX that don't have it
	if [[ ${CHOST} == *-darwin* && ${CHOST#*-darwin} -le 9 ]] ; then
		sed -i -e 's/#ifdef __APPLE__/#if 0/' gegl/opencl/* || die
	fi

	sed -e '/clones.xml/d' \
		-e '/composite-transform.xml/d' \
		-i tests/compositions/Makefile.am || die

	eapply_user # Add support for user patches
	eautoreconf

	use vala && vala_src_prepare
}

src_configure() {
	econf \
		--disable-docs \
		--disable-profile \
		--disable-silent-rules \
		--disable-workshop \
		--program-suffix=-${SLOT} \
		--with-gdk-pixbuf \
		--with-pango \
		--without-libspiro \
		$(use_enable cpu_flags_x86_mmx mmx) \
		$(use_enable cpu_flags_x86_sse sse) \
		$(use_enable debug) \
		$(use_with cairo) \
		$(use_with cairo pangocairo) \
		--without-exiv2 \
		$(use_with ffmpeg libavformat) \
		--without-gexiv2 \
		--without-graphviz \
		$(use_with jpeg libjpeg) \
		$(use_with jpeg2k jasper) \
		$(use_with lcms) \
		$(use_with lensfun) \
		--without-lua \
		--without-mrg \
		$(use_with openexr) \
		$(use_with png libpng) \
		$(use_with raw libraw) \
		$(use_with sdl) \
		$(use_with svg librsvg) \
		$(use_with tiff libtiff) \
		$(use_with umfpack) \
		$(use_with v4l libv4l) \
		$(use_with v4l libv4l2) \
		$(use_enable introspection) \
		$(use_with vala) \
		$(use_with webp)
}

src_compile() {
	gnome2_environment_reset  # Sandbox issues (bug #396687)
	default
}

src_install() {
	default
	prune_libtool_files --all
}
