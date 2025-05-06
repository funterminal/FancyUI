# FancyUI - Advanced Terminal UI Toolkit

## Overview

FancyUI is a powerful Bash library designed to create visually appealing and functional terminal user interfaces. It provides a comprehensive set of tools for formatting text, creating structured layouts, and adding interactive elements to command-line applications.

## Key Features

### Text Formatting Capabilities
- Full support for standard text formatting (bold, underline, italic, strikethrough)
- Extensive color system with foreground and background options
- Advanced text transformations including gradients and styled headers

### Layout Components
- Flexible box containers with customizable dimensions
- Multi-column table layouts with automatic cell alignment
- Organized list displays with hierarchical styling
- Progress bars for visual task completion tracking

### Markdown Integration
- Built-in markdown parser with syntax highlighting
- Support for common markdown elements (headers, bold, italic, code blocks)
- Custom formatting extensions for specialized use cases

### Interactive Elements
- Animated spinners for process indication
- Dynamic progress indicators
- Customizable UI components for user interaction

## Installation

To install FancyUI, execute the following command in your terminal:

```bash
curl -sSL https://raw.githubusercontent.com/funterminal/FancyUI/refs/heads/main/fancyui.sh -o ~/fancyui.sh && echo "alias fancyui='bash ~/fancyui.sh'" >> ~/.bashrc && source ~/.bashrc
```

This will download the script and create a convenient alias for execution.

## Usage Examples

### Basic Text Formatting

```bash
fancyui echo "Sample Text" green white
```

### Markdown Processing

```bash
fancyui format "**Bold** and *italic* text with ~~strikethrough~~"
```

### Table Creation

```bash
fancyui table 3 "Header 1" "Header 2" "Header 3" "Row 1 Col 1" "Row 1 Col 2" "Row 1 Col 3"
```

### Box Layout

```bash
fancyui box 30 5 "Content inside a styled box"
```

### Progress Indicator

```bash
fancyui progress 100 35
```

### Gradient Text

```bash
fancyui gradient "Rainbow colored text effect"
```

### Header Creation

```bash
fancyui header "Section Title"
```

### Animated Spinner

```bash
fancyui spinner "Processing data..." &
# Do some work
kill $!; echo
```

## Integration Guide

### Bash Script Integration

To use FancyUI in your Bash scripts:

1. Source the script at the beginning of your file:
```bash
source ~/fancyui.sh
```

2. Call the functions directly:
```bash
create_fancy_header "Application Title"
```

### Other Language Integration

For non-Bash languages, execute FancyUI commands through shell calls:

#### Python Example
```python
import subprocess
result = subprocess.run(['fancyui', 'format', '**Python** integration'], capture_output=True, text=True)
print(result.stdout)
```

#### Node.js Example
```javascript
const { execSync } = require('child_process');
const output = execSync('fancyui gradient "Node.js integration"').toString();
console.log(output);
```

## Advanced Customization

### Color System Extension

The color system can be extended by adding to the `fg` and `bg` associative arrays:

```bash
fg[custom]="\033[38;5;208m"  # Orange color
bg[custom]="\033[48;5;18m"   # Dark blue background
```

### Custom Markdown Tags

The markdown processor can be modified to support additional syntax by editing the Perl regular expressions in the `format_markdown` function.

### Component Styling

All components support style customization by modifying the color and format codes in their respective functions.

## Performance Considerations

FancyUI is optimized for performance with:

- Minimal external dependencies (only requires Bash and standard Unix tools)
- Efficient text processing using built-in shell features
- Lightweight animations that don't consume excessive resources

## Compatibility

FancyUI is compatible with:

- Most modern Bash versions (4.0+)
- Common terminal emulators (xterm, gnome-terminal, iTerm2, etc.)
- Linux and macOS systems (Windows support via WSL or Cygwin)

## License

FancyUI is released under the MIT License. See the included LICENSE file for full details.

## Contribution Guidelines

Contributions to FancyUI are welcome. Please follow these guidelines:

1. Maintain consistent coding style
2. Include documentation for new features
3. Add tests for significant changes
4. Keep backward compatibility where possible

## Support

For support or feature requests, please open an issue on the official GitHub repository.
