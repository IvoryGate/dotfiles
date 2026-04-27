# Dotfiles

我的 macOS 开发环境配置集，涵盖终端、Shell、编辑器、开发工具和效率提升工具。

## 快速开始

```bash
# 方式一：直接运行安装脚本
./install.sh

# 方式二：使用完整的恢复脚本（包含备份）
bash scripts/restore.sh
```

## 包含内容

### 终端与 Shell
| 工具 | 说明 |
|------|------|
| **Ghostty** | 高性能终端模拟器，自定义主题与 Shader 特效 |
| **Alacritty** | GPU 加速终端 |
| **fish** | 友好的交互式 Shell，集成 Starship 提示符 |
| **zsh** | Oh My Zsh 配置作为备选 |
| **tmux** | 终端多路复用器 |

### 窗口管理
| 工具 | 说明 |
|------|------|
| **AeroSpace** | macOS 平铺式窗口管理器 |
| **Karabiner** | 强大的键盘映射工具 |

### 编辑器
| 工具 | 说明 |
|------|------|
| **Neovim** | 现代 Vim 超集，AstroNvim 配置 |
| **Neovide** | Neovim 的 GUI 前端 |
| **Vim** | 经典配置 |

### 开发工具
| 工具 | 说明 |
|------|------|
| **Lazygit** | Git TUI 客户端 |
| **Yazi** | 快速终端文件管理器 |
| **Btop** | 系统资源监控 |
| **Fastfetch** / **Neofetch** | 系统信息展示 |
| **Opencode** | AI 编程助手 |

### 媒体工具
| 工具 | 说明 |
|------|------|
| **ffmpeg** | 音视频处理 |
| **ImageMagick** | 图像处理 |

## 配置选项

恢复脚本支持以下环境变量：

```bash
# 跳过 Homebrew 安装（仅恢复符号链接）
SKIP_BREW=1 bash scripts/restore.sh

# 跳过 fish 设为默认 Shell
SKIP_FISH_CHSH=1 bash scripts/restore.sh

# 自定义备份目录
DOTFILES_BACKUP_ROOT=/path/to/backup bash scripts/restore.sh
```

## 备份说明

运行恢复脚本时，原有配置文件会自动备份到 `~/.dotfiles-backup/<timestamp>/`。

## 导入配置

- **Raycast**: 设置 → 高级 → 导入 → 选择 `raycast/*.rayconfig`
- **Karabiner**: 启动后自动加载 `karabiner/config/`

## 更新 Homebrew 依赖

```bash
# 最小配置（与本仓库匹配）
brew bundle install --file=Brewfile

# 完整配置（包含更多工具）
brew bundle install --file=Brewfile.full

# 额外的 Mole 配置（需要最新命令行工具）
brew bundle install --file=Brewfile.mole
```