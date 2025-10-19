# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="An OCR (Optical Character Recognition) reader"
HOMEPAGE="https://www-e.uni-magdeburg.de/jschulen/ocr/ https://github.com/adeliktas/gocr"
SRC_URI="https://github.com/adeliktas/gocr/archive/refs/tags/gocr-0.54.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="doc scanner tk"

DEPEND="
	>=media-libs/netpbm-9.12
	doc? (
		>=media-gfx/fig2dev-3.2.9-r1
		app-text/ghostscript-gpl
	)
	tk? ( dev-lang/tk )
"
RDEPEND="${DEPEND}
	tk? (
		media-gfx/xli
		scanner? ( media-gfx/xsane )
	)
"

src_unpack() {
	default
	mv gocr-gocr-0.54 "${S}" || die "Failed to rename source directory"
}

src_prepare() {
	default
	./configure --prefix="${EPREFIX}/usr" --exec-prefix="${EPREFIX}/usr" || die "Configure failed"
}

src_compile() {
	local targets=( src man )
	use doc && targets+=( doc examples )

	emake "${targets[@]}" || die "Make failed"
}

src_install() {
	emake DESTDIR="${D}" prefix="${EPREFIX}/usr" exec_prefix="${EPREFIX}/usr" install || die "Install failed"
	einstalldocs
	dodoc HISTORY REMARK.txt REVIEW

	# remove the tk frontend if tk is not selected
	if ! use tk; then
		rm "${ED}"/usr/bin/gocr.tcl || die "Failed to remove gocr.tcl"
	fi

	# install documentation and examples
	if use doc; then
		dodoc doc/gocr.html doc/examples.txt doc/unicode.txt

		docinto examples
		dodoc examples/*.{fig,tex,pcx}
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
