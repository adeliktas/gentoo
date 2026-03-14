# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 qmake-utils

DESCRIPTION="System daemon for reading info about Radeon GPU clocks and volts"
HOMEPAGE="https://github.com/blackPantherOS/radeon-profile-daemon"
EGIT_REPO_URI="https://github.com/blackPantherOS/radeon-profile-daemon.git"

LICENSE="GPL-2"
SLOT="0"
S="${WORKDIR}/${P}/radeon-profile-daemon"

RDEPEND="
	dev-qt/qtbase:6[network]
"

DEPEND="
	${RDEPEND}
"

src_prepare() {
	default
	sed -i 's/-std=c++11/-std=c++17/' radeon-profile-daemon.pro || die
}

src_configure() {
	eqmake6
}

src_install() {
	dobin target/radeon-profile-daemon
	newinitd "${FILESDIR}/radeon-profile-daemon.initd" radeon-profile-daemon
}

pkg_postinst() {
	elog "To start the daemon with OpenRC, run:"
	elog "rc-update add radeon-profile-daemon default"
	elog "rc-service radeon-profile-daemon start"
}
