#!/bin/bash

# Installation script for AMC on macOS Apple Silicon

# Set installation prefix
PREFIX=${PREFIX:-$HOME/.local}

# Export configuration
export AMCCONF=apple-silicon

# Create necessary directories
mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib/AMC/perl"
mkdir -p "$PREFIX/lib/AMC/exec"
mkdir -p "$PREFIX/share/auto-multiple-choice/icons"
mkdir -p "$PREFIX/share/auto-multiple-choice/models"
mkdir -p "$PREFIX/share/texmf-local/tex/latex/AMC"
mkdir -p "$PREFIX/libexec/lib/perl5/AMC"

# Rebuild the C++ binaries against the currently-installed OpenCV.
#
# The binaries link OpenCV dylibs by their major.minor soname (e.g.
# libopencv_core.412.dylib for 4.12). Homebrew deletes the old soname on every
# `brew upgrade opencv`, which breaks any binary built against the previous
# version. Rebuilding here re-links them against whatever `pkg-config opencv4`
# currently resolves to, so the install always matches the live OpenCV.
#
# Do NOT replace this with symlinks from the new soname to the old name: OpenCV
# does not guarantee ABI stability across minor versions, and a mismatched load
# can silently misread marks in a grading tool.
echo "Rebuilding binaries against current OpenCV..."
rm -f AMC-detect AMC-buildpdf AMC-pdfformfields
make AMC-detect AMC-buildpdf AMC-pdfformfields

# Verify AMC-detect linked against an OpenCV that is actually present.
missing=$(otool -L AMC-detect 2>/dev/null | grep -oE '/opt/homebrew/[^ ]*libopencv_core[^ ]*\.dylib' | head -1)
if [ -n "$missing" ] && [ ! -e "$missing" ]; then
    echo "ERROR: AMC-detect links a missing OpenCV ($missing). Aborting install." >&2
    exit 1
fi

echo "Installing binaries..."
cp AMC-detect AMC-buildpdf AMC-pdfformfields "$PREFIX/lib/AMC/exec/"

# Process and copy Perl scripts
echo "Installing Perl scripts..."
for script in AMC-*.pl.in; do
    base=$(basename "$script" .in)
    sed 's|@/PERLPATH/@|/opt/homebrew/opt/perl/bin/perl|' "$script" > "$base"
    chmod +x "$base"
done
cp AMC-*.pl "$PREFIX/lib/AMC/perl/"

# Process and copy main script
echo "Installing main script..."
sed -e 's|@/PERLPATH/@|/opt/homebrew/opt/perl/bin/perl|g' \
    -e 's|@/MODSDIR/@|'"$PREFIX/lib/AMC"'|g' \
    auto-multiple-choice.in > auto-multiple-choice
chmod +x auto-multiple-choice
cp auto-multiple-choice "$PREFIX/bin/"

# Install launcher script
echo "Installing launcher script..."
sed -e 's|PREFIX=${PREFIX:-$HOME/.local}|PREFIX='"$PREFIX"'|g' \
    amc-launcher > amc-launcher-processed
chmod +x amc-launcher-processed
cp amc-launcher-processed "$PREFIX/bin/amc-launcher"
rm -f amc-launcher-processed

# Process and copy Perl modules
echo "Installing Perl modules..."
# Process Basic.pm.in first
sed -e 's|@/MODSDIR/@|'"$PREFIX/lib/AMC"'|g' \
    -e 's|@/BINDIR/@|'"$PREFIX/bin"'|g' \
    -e 's|@/PERLDIR/@|'"$PREFIX/libexec/lib/perl5"'|g' \
    -e 's|@/MODELSDIR/@|'"$PREFIX/share/auto-multiple-choice/models"'|g' \
    -e 's|@/DOCDIR/@|'"$PREFIX/share/doc/auto-multiple-choice"'|g' \
    -e 's|@/ICONSDIR/@|'"$PREFIX/share/auto-multiple-choice/icons"'|g' \
    -e 's|@/LOCALEDIR/@|'"$PREFIX/share/locale"'|g' \
    -e 's|@/PACKAGE_V_DEB/@|1.5.2|g' \
    -e 's|@/PACKAGE_V_VC/@|1.5.2|g' \
    -e 's|@/SYSTEM_TYPE/@|brew|g' \
    AMC-perl/AMC/Basic.pm.in > AMC-perl/AMC/Basic.pm

# Process Main.pm.in
sed -e 's|@/BINDIR/@|'"$PREFIX/bin"'|g' \
    -e 's|@/PACKAGE_V_STY/@|2025/06/01 v1.7.0+git20250601114404 r:8433b718|g' \
    -e 's|@/PACKAGE_V_STY_TEX/@|2025/06/01 v1.7.0+git20250601114404 r:8433b718|g' \
    AMC-perl/AMC/Gui/Main.pm.in > AMC-perl/AMC/Gui/Main.pm

# Process glade files
for glade in AMC-perl/AMC/Gui/*.glade.in; do
    base=$(basename "$glade" .in)
    sed -e 's|@/DOCDIR/@|'"$PREFIX/share/doc/auto-multiple-choice"'|g' \
        "$glade" > "AMC-perl/AMC/Gui/$base"
done

cp -r AMC-perl/AMC/* "$PREFIX/libexec/lib/perl5/AMC/"

# Copy icons
echo "Installing icons..."
cp icons/*.svg "$PREFIX/share/auto-multiple-choice/icons/" 2>/dev/null || true

# Generate and copy style file
echo "Installing LaTeX style..."
# First, process the dtx.in file
sed -e 's|@/PACKAGE_V_STY_TEX/@|2025/06/01 v1.7.0+git20250601114404 r:8433b718|g' \
    doc/sty/automultiplechoice.dtx.in > doc/sty/automultiplechoice.dtx

# Generate the sty file from dtx if not already present
if [ ! -f doc/sty/automultiplechoice.sty ]; then
    echo "Generating automultiplechoice.sty from dtx..."
    (cd doc/sty && latex automultiplechoice.dtx) || echo "Warning: Could not generate sty from dtx"
fi

# Copy the sty file if it exists
if [ -f doc/sty/automultiplechoice.sty ]; then
    cp doc/sty/automultiplechoice.sty "$PREFIX/share/texmf-local/tex/latex/AMC/"
else
    echo "Warning: automultiplechoice.sty not found!"
fi

# Copy locale files
echo "Installing locale files..."
for lang in ar ca de es fr ja pt_BR pt_PT ta; do
    if [ -f "I18N/lang/${lang}.mo" ]; then
        mkdir -p "$PREFIX/share/locale/${lang}/LC_MESSAGES"
        cp "I18N/lang/${lang}.mo" "$PREFIX/share/locale/${lang}/LC_MESSAGES/auto-multiple-choice.mo"
    fi
done

# Update PATH in shell config
echo ""
echo "Installation complete!"
echo ""
echo "To use AMC, add the following to your shell configuration:"
echo "  export PATH=\"$PREFIX/bin:\$PATH\""
echo "  export PERL5LIB=\"$PREFIX/libexec/lib/perl5:\$PERL5LIB\""
echo ""
echo "For LaTeX to find the AMC style file, run:"
echo "  export TEXMFHOME=\"$PREFIX/share/texmf-local\""
echo "  texhash \"$PREFIX/share/texmf-local\""
echo ""
echo "IMPORTANT: On macOS, use the launcher script instead of auto-multiple-choice directly:"
echo "  amc-launcher"
echo ""
echo "The launcher sets up the required GTK environment for the GUI to work properly."