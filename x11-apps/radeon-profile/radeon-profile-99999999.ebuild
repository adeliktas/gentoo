# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 qmake-utils desktop

DESCRIPTION="App for display info about radeon card"
HOMEPAGE="https://github.com/blackPantherOS/radeon-profile-qt6"
EGIT_REPO_URI="https://github.com/blackPantherOS/radeon-profile-qt6.git"

LICENSE="GPL-2"
S="${WORKDIR}/${P}"
SLOT="0"

RDEPEND="
	dev-qt/qtbase:6[gui,network,widgets]
	dev-qt/qtcharts:6
	x11-libs/libxkbcommon[X]
	x11-libs/libXrandr
	x11-libs/libX11
"

DEPEND="
	${RDEPEND}
	dev-qt/qttools:6[linguist]
	media-libs/mesa[X(+)]
	x11-libs/libdrm
"

src_prepare() {
	default
	sed 's@TrayIcon;@@' -i extra/${PN}.desktop || die
}

src_configure() {
	"$(qt6_get_bindir)/lrelease" radeon-profile.pro || die
	eqmake6 CONFIG+=silent
}

src_install() {
	dobin target/radeon-profile
	insinto /usr/share/pixmaps
	doins extra/radeon-profile.png
	domenu extra/radeon-profile.desktop
	insinto /usr/share/radeon-profile
	doins translations/*.qm
}

pkg_postinst() {
	elog "In order to run ${PN} as non-root user, the"
	elog "  x11-apps/radeon-profile-daemon"
	elog "package needs to be installed and the daemon must run."
	elog "Optional dependencies: app-misc/mesa-demos (for glxinfo),"
	elog "x11-apps/xdriinfo, x11-apps/xrandr,"
	elog "x11-drivers/xf86-video-ati or x11-drivers/xf86-video-amdgpu."
}
