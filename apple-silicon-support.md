# Apple Silicon Support for Auto Multiple Choice (AMC)

## Why This Fork Exists

This fork was created to enable Auto Multiple Choice (AMC) to run natively on Apple Silicon Macs. The original AMC project, while excellent software for creating and managing multiple choice questionnaires, was not compatible with the ARM64 architecture of Apple Silicon processors.

After extensive debugging and modification, this fork includes all necessary changes to make AMC work properly on macOS with Apple Silicon processors.

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

4. Add the following to your shell configuration file (`~/.zshrc` or `~/.bash_profile`):
```bash
export PATH="$HOME/.local/bin:$PATH"
export PERL5LIB="$HOME/.local/libexec/lib/perl5:$PERL5LIB"
export TEXMFHOME="$HOME/.local/share/texmf-local"
```

5. Update your LaTeX distribution to find the AMC style file:
```bash
texhash "$HOME/.local/share/texmf-local"
```

6. Reload your shell configuration:
```bash
source ~/.zshrc
```

## Known Issues and Solutions

### PERL5LIB Module Loading Issue

Due to shell session management differences on macOS, the `PERL5LIB` environment variable may not always be properly loaded when running AMC directly. This can result in errors like:

```
Can't locate AMC/Basic.pm in @INC (you may need to install the AMC::Basic module)
```

### Recommended Solution: Use a Launcher Script

Instead of running `auto-multiple-choice` directly, create a launcher script that ensures the environment is properly configured:

1. Create the launcher script:
```bash
nano ~/amc-launcher.sh
```

2. Add this content:
```bash
#!/bin/bash
export PERL5LIB="/Users/$USER/.local/libexec/lib/perl5:$PERL5LIB"
/Users/$USER/.local/bin/auto-multiple-choice "$@"
```

3. Make it executable:
```bash
chmod +x ~/amc-launcher.sh
```

4. Use this launcher to run AMC:
```bash
~/amc-launcher.sh
```

This approach ensures AMC works reliably regardless of your shell session state.

## Usage

After installation, you can run AMC using the recommended launcher script:
```bash
~/amc-launcher.sh
```

**Alternative (may not work in all shell sessions):**
```bash
auto-multiple-choice
```

If you encounter module loading errors, always use the launcher script method above.

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