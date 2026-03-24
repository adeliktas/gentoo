# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Greenbone Security Assistant - Web frontend"
HOMEPAGE="https://www.greenbone.net https://github.com/greenbone/gsa"
EGIT_REPO_URI="https://github.com/greenbone/gsa.git"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS=""

BDEPEND="
	>=net-libs/nodejs-20.0.0[ssl]
	>=sys-apps/yarn-1.22
"

src_prepare() {
	default

	# Fix for SVGR permission issue[](https://bugs.gentoo.org/909731)
	echo "runtimeConfig: false" > .svgrrc.yml || die

	# Fetch and install JavaScript dependencies (network access required the first time)
	yarn install --frozen-lockfile || die
}

src_compile() {
	NODE_ENV=production yarn build || die
}

src_install() {
	insinto /usr/share/gvm/gsad/web
	doins -r build/*
}
