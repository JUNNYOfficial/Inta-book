# INTA-Book — 智能识别书架系统

基于 NFC/RFID 技术的家庭与小型机构物品管理解决方案。

## 项目概述

INTA-Book 是一个完整的智能书架识别系统，包含 iOS 移动应用、设计素材和技术文档，旨在通过 NFC 标签实现快速查找物品位置。

## 目录结构

```
inta-book/
├── NFCItemFinder-iOS/     # iOS 移动应用
│   ├── NFCItemFinderApp.swift    # 应用入口
│   ├── Models/                   # 数据模型
│   ├── Services/                 # 服务层（NFC 管理）
│   ├── Views/                    # SwiftUI 视图
│   ├── project.yml               # xcodegen 配置
│   └── NFCItemFinder.xcodeproj/  # Xcode 项目
├── 书架设计素材包/         # UI 设计资源
│   ├── 色卡/                     # 配色方案
│   └── 设计元素/                 # 图标、模板等
├── 单排书架RFID架级识别系统_白皮书.pdf    # 技术白皮书
└── NFC 家庭与小型机构快速查找方案.md      # 方案文档
```

## 核心功能

### 📱 iOS 应用
- **物品管理**：添加、编辑、删除、搜索物品
- **NFC 写入**：将物品信息写入 NFC 标签（NTAG213/215/216）
- **NFC 读取**：碰一下标签即可查看物品详情和位置
- **借出管理**：登记借出/归还，查看历史记录
- **过期提醒**：药品、食品、证件有效期提醒
- **数据导入**：JSON 格式数据恢复
- **完全离线**：所有数据存储在本地，无需服务器

### 🎨 设计素材
- 深蓝到纯白主色板配色方案
- 强调色板与渐变组合
- 书脊图标集、书架框架、分类标签、书籍卡片模板

## 技术栈

| 组件 | 技术 | 版本要求 |
|------|------|---------|
| 前端框架 | SwiftUI | iOS 15.0+ |
| NFC 框架 | CoreNFC | iPhone 7+ |
| 数据存储 | JSON + 文件系统 | - |
| 项目生成 | xcodegen | 2.0+ |
| 开发工具 | Xcode | 14.0+ |

## 快速开始

### 1. 环境要求
- macOS 12.0+
- Xcode 14.0+
- iPhone 7 或更新机型（支持 NFC）

### 2. 运行项目

```bash
# 进入 iOS 项目目录
cd NFCItemFinder-iOS

# 使用 xcodegen 生成项目（如已存在 .xcodeproj 可跳过）
xcodegen generate

# 用 Xcode 打开
open NFCItemFinder.xcodeproj
```

### 3. 配置签名
在 Xcode 中配置开发团队和 Bundle Identifier 后即可运行。

**注意**：NFC 功能必须在真机上测试，iOS 模拟器不支持 NFC。

## NFC 标签选型

| 标签类型 | 容量 | 适用场景 | 参考价格 |
|---------|------|---------|---------|
| NTAG213 | 144 字节 | 纯文本位置信息 | ¥0.1 |
| NTAG215 | 504 字节 | 结构化 JSON + 备注 | ¥0.2 |
| NTAG216 | 888 字节 | 大量备注 + 历史记录 | ¥0.3 |
| 抗金属标签 | - | 贴金属工具/柜子 | ¥0.5 |

**推荐**：家庭藏书和普通物品使用 **NTAG215**。

## 使用流程

1. **绑定标签**：添加物品 → 填写信息 → 写入 NFC 标签
2. **日常查找**：点击扫码 → 靠近标签 → 查看位置详情
3. **借出管理**：详情页登记借出/归还

## 标签数据格式

写入标签的数据为 NDEF MIME 类型记录：

```json
{
  "itemID": "UUID-字符串",
  "name": "三体",
  "category": "书籍",
  "location": "客厅书架第3层",
  "updated": "2026-07-06"
}
```

## 文档资料

- [技术白皮书](单排书架RFID架级识别系统_白皮书.pdf) — RFID 架级识别系统设计方案
- [方案文档](NFC%20家庭与小型机构快速查找方案%2039309393427b80fab75cea21f0c65189.md) — NFC 快速查找方案详细说明
- [应用说明](NFCItemFinder-iOS/README.md) — iOS 应用开发指南

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

---

**项目地址**：https://github.com/JUNNYOfficial/inta-book
