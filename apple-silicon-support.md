# Apple Silicon Support for Auto Multiple Choice (AMC)

## Critical Information for macOS Users

**⚠️ IMPORTANT:** On macOS, you CANNOT run AMC directly. You MUST use the `amc-launcher` script that gets installed automatically. This is due to GTK3 environment requirements specific to macOS.

**Quick Start:**
1. Follow the installation steps below
2. Run AMC using: `amc-launcher` (NOT `auto-multiple-choice`)

## Why This Fork Exists

This fork was created to enable Auto Multiple Choice (AMC) to run natively on Apple Silicon Macs. The original AMC project, while excellent software for creating and managing multiple choice questionnaires, was not compatible with the ARM64 architecture of Apple Silicon processors.

After extensive debugging and modification, this fork includes all necessary changes to make AMC work properly on macOS with Apple Silicon processors, including the required GTK environment setup.

## Compatibility

This fork has been tested and confirmed working on:
- **Apple Silicon M4** (MacBook Pro)

While only tested on M4, these modifications should work on all Apple Silicon variants (M1, M2, M3, M4) as they share the same ARM64 architecture.

## Key Modifications

The following changes were made to ensure compatibility:
- Modified core AMC Perl modules for macOS compatibility
- Created custom Makefile configuration for Apple Silicon with Homebrew paths
- Fixed GUI components for proper rendering on macOS
- Updated state management to work with macOS file systems
- Added installation script specifically for Apple Silicon Macs

## Prerequisites

Before installing, ensure you have the following installed via Homebrew:

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install XQuartz (required for GUI applications)
brew install --cask xquartz

# Install required dependencies
brew install perl
brew install opencv
brew install poppler
brew install cairo
brew install pango
brew install netpbm
brew install imagemagick
brew install docbook-xsl
brew install docbook

# Install Perl modules
cpan install Gtk3
cpan install Glib::Object::Introspection
cpan install Cairo::GObject
cpan install XML::LibXML
cpan install Image::Magick
cpan install Email::MIME
cpan install Email::Sender
```

**Important:** After installing XQuartz, you must **logout and login again** (or restart your Mac) for the X11 system to be properly initialized.

## Installation

1. Clone this repository:
```bash
git clone https://github.com/RomainClaret/auto-multiple-choice-apple-silicon.git
cd auto-multiple-choice-apple-silicon
```

2. Checkout the Apple Silicon branch:
```bash
git checkout apple-silicon-m4-support
```

3. Run the installation script:
```bash
./install-amc.sh
```

By default, this installs AMC to `~/.local`. To install elsewhere, set the PREFIX environment variable:
```bash
PREFIX=/usr/local ./install-amc.sh
```

The installation script automatically:
- Installs the main `auto-multiple-choice` binary
- Installs the `amc-launcher` script (required for macOS)
- Sets up all Perl modules and LaTeX components

4. Add the following to your shell configuration file (`~/.zshrc` or `~/.bash_profile`):
```bash
export PATH="$HOME/.local/bin:$PATH"
export PERL5LIB="$HOME/.local/libexec/lib/perl5:$PERL5LIB"
export TEXMFHOME="$HOME/.local/share/texmf-local"
```

**Note:** These shell exports are for convenience but are **not sufficient** for AMC to work. You MUST use `amc-launcher` because GTK applications on macOS require additional environment variables that are automatically set by the launcher.

5. Update your LaTeX distribution to find the AMC style file:
```bash
texhash "$HOME/.local/share/texmf-local"
```

6. Reload your shell configuration:
```bash
source ~/.zshrc
```

7. **Test your installation:**
```bash
amc-launcher
```

You should see the AMC GUI launch. If not, check the troubleshooting section below.

## Known Issues and Solutions

### GTK Environment Configuration Issue

AMC uses GTK3 for its graphical interface, which requires specific environment variables on macOS that are not set by default. When these variables are missing, AMC fails to initialize the GUI and falls back to command-line mode, often resulting in LaTeX compilation errors.

**Common error symptoms:**
```
Can't locate AMC/Basic.pm in @INC (you may need to install the AMC::Basic module)
```
or
```
Options : latex_engine
This is pdfTeX, Version 3.141592653-2.6-1.40.27 (TeX Live 2025)
```

**Root cause:** Missing GTK environment variables:
- `GSETTINGS_SCHEMA_DIR` - GTK settings schema location
- `XDG_DATA_DIRS` - GTK resource directories  
- `PERL5LIB` - Perl module search paths
- `DISPLAY` - X11 display connection (if XQuartz not properly configured)

### Solution: Use the Installed Launcher Script

The installation process automatically creates and installs a launcher script that sets up the required GTK environment:

```bash
amc-launcher
```

This launcher script:
- Sets all required environment variables (GSETTINGS_SCHEMA_DIR, XDG_DATA_DIRS, etc.)
- Ensures GTK3 can find its schemas and resources
- Launches AMC with the proper environment

**Why is this necessary?** GTK3 applications on macOS require specific environment variables to locate schemas and resources. Without these, GTK fails to initialize and AMC falls back to command-line mode, resulting in LaTeX compilation errors instead of the GUI.

## Usage

After installation, run AMC using the installed launcher:

```bash
amc-launcher
```

**Do not run `auto-multiple-choice` directly** - it will fail with GTK environment errors on macOS.

The launcher ensures all GTK environment variables are set correctly for the GUI to work properly.

## Troubleshooting

### GUI Doesn't Appear

If AMC runs but no GUI window appears:

1. **Check if XQuartz is running:**
   ```bash
   ps aux | grep -i xquartz
   ```

2. **Manually start XQuartz:**
   ```bash
   open -a XQuartz
   ```

3. **Verify DISPLAY is set:**
   ```bash
   echo $DISPLAY
   ```
   Should show `:0` or similar. If empty, run:
   ```bash
   export DISPLAY=:0
   ```

### Still Getting LaTeX Compilation Errors

If you see "Options : latex_engine" or LaTeX compilation starting instead of GUI:

1. **Ensure you're using `amc-launcher`** (not `auto-multiple-choice` directly)
2. **Check that amc-launcher is installed:** `which amc-launcher`
3. **Verify the launcher is executable:** `ls -la $(which amc-launcher)`

### Permission Denied Errors

If you get permission errors:

1. **Make launcher executable:**
   ```bash
   chmod +x ~/.local/bin/amc-launcher
   ```

2. **Check file permissions:**
   ```bash
   ls -la ~/.local/bin/amc-launcher
   ls -la ~/.local/bin/auto-multiple-choice
   ```

## Keeping Up to Date

This fork maintains compatibility with the upstream GitLab repository. To update with the latest changes from upstream:

```bash
# Fetch latest from upstream
git fetch origin master

# Merge upstream changes into Apple Silicon branch
git checkout apple-silicon-m4-support
git merge origin/master

# Resolve any conflicts if necessary
# Then push to GitHub
git push github apple-silicon-m4-support
```

## Contributing

If you test this on other Apple Silicon models (M1, M2, M3) or encounter any issues, please open an issue or submit a pull request. Your feedback helps make AMC accessible to all Mac users.

## License

This fork maintains the same GPL v2 license as the original Auto Multiple Choice project. See the COPYING file for details.

## Acknowledgments

Thanks to the original AMC developers for creating this excellent software. This fork simply makes their work accessible to Apple Silicon Mac users.