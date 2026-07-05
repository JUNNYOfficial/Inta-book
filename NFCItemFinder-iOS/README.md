# NFC 物品查找 App（iOS）

基于 SwiftUI + CoreNFC 的轻量级家庭/小型机构物品管理应用，对应《NFC 家庭与小型机构快速查找方案》白皮书。

## 功能特性

- **物品管理**：添加、编辑、删除、搜索物品
- **NFC 写入**：将物品信息写入 NFC 标签（NTAG213/215/216）
- **NFC 读取**：碰一下标签即可查看物品详情和位置
- **借出管理**：登记借出/归还，查看历史记录
- **过期提醒**：药品、食品、证件有效期提醒
- **数据导出**：JSON 备份与导入，换机不丢数据
- **完全离线**：所有数据存储在本地，无需服务器

## 项目结构

```
NFCItemFinder-iOS/
├── NFCItemFinderApp.swift    # 应用入口
├── Models/
│   ├── Item.swift            # 数据模型（物品、借出记录、NFC 载荷）
│   └── ItemStore.swift       # 本地 JSON 数据持久化
├── Services/
│   └── NFCManager.swift      # CoreNFC 读写管理
└── Views/
    ├── ContentView.swift     # 主 Tab 容器
    ├── ItemListView.swift    # 物品列表与搜索
    ├── ItemDetailView.swift  # 物品详情/编辑/NFC 写入/借出
    ├── AddItemView.swift     # 添加新物品
    ├── ScanView.swift        # NFC 扫码查找
    ├── WriteTagView.swift    # NFC 写入界面
    ├── LendView.swift        # 借出登记
    ├── AlertsView.swift      # 过期/借出提醒
    └── SettingsView.swift    # 导出/导入/统计
```

## 运行环境

- iOS 15.0+
- Xcode 14.0+
- iPhone 7 或更新机型（支持 NFC 读取）
- iOS 13+ 支持 NFC 标签写入

## Xcode 配置步骤

### 1. 创建 Xcode 项目

1. 打开 Xcode，选择 **File > New > Project**
2. 选择 **iOS > App**，点击 Next
3. 填写项目信息：
   - **Name**: `NFCItemFinder`
   - **Interface**: `SwiftUI`
   - **Language**: `Swift`
   - **Minimum Deployments**: `iOS 15.0`
4. 点击 Create

### 2. 添加源码

将本目录下的所有 Swift 文件拖拽到 Xcode 项目中对应的分组：

- `NFCItemFinderApp.swift` 替换项目自动生成的同名文件
- `Models/`、`Services/`、`Views/` 下的文件分别放入对应分组

### 3. 开启 NFC 能力

1. 选中项目，进入 **Signing & Capabilities**
2. 点击 **+ Capability**
3. 搜索并添加 **Near Field Communication Tag Reading**

### 4. 配置 Info.plist

在项目导航栏中打开 `Info.plist`，添加以下键值：

| Key | Type | Value |
|-----|------|-------|
| `NFCReaderUsageDescription` | String | `此应用需要读取 NFC 标签以识别物品位置和状态` |

如果使用 Xcode 15+ 的可视化 Info 编辑器，添加 **Privacy - NFC Scan Usage Description**。

### 5. 修改 Bundle Identifier

将 Bundle Identifier 修改为你自己的反向域名格式，例如：

```
com.yourname.NFCItemFinder
```

### 6. 运行到真机

**注意：NFC 功能必须在真机上测试，iOS 模拟器不支持 NFC。**

1. 用数据线连接 iPhone
2. 在 Xcode 顶部选择你的设备
3. 点击运行按钮
4. 首次运行需要在 iPhone 上信任开发者证书：**设置 > 通用 > VPN 与设备管理**

## 使用流程

### 首次使用

1. 打开 App，进入「物品」标签页
2. 点击右上角 **+** 添加第一件物品
3. 填写名称、分类、位置等信息
4. 点击「保存并写入 NFC 标签」
5. 将手机靠近 NFC 标签完成写入

### 日常查找

1. 进入「扫码」标签页
2. 点击「开始扫描」
3. 将手机靠近物品上的 NFC 标签
4. App 自动跳转到物品详情页，显示位置和状态

### 借出登记

1. 在物品详情页点击「登记借出」
2. 输入借用人姓名和预计归还日期
3. 归还时回到详情页点击「登记归还」

### 数据备份

1. 进入「设置」标签页
2. 点击「导出 JSON 备份」
3. 通过系统分享面板保存到文件、微信、邮件等
4. 换机后可通过「从文件导入」恢复

## NFC 标签数据格式

写入标签的数据为 NDEF MIME 类型记录，类型为 `application/json`，内容示例：

```json
{
  "itemID": "UUID-字符串",
  "name": "三体",
  "category": "书籍",
  "location": "客厅书架第3层",
  "updated": "2026-07-05"
}
```

## 标签选型建议

| 标签类型 | 容量 | 适用场景 | 参考价格 |
|---------|------|---------|---------|
| NTAG213 | 144 字节 | 纯文本位置信息 | 0.1 元 |
| NTAG215 | 504 字节 | 结构化 JSON + 备注 | 0.2 元 |
| NTAG216 | 888 字节 | 大量备注 + 历史记录 | 0.3 元 |
| 抗金属标签 | - | 贴金属工具/柜子 | 0.5 元 |

**推荐**：家庭藏书和普通物品使用 **NTAG215**。

## 已知限制

- 必须使用真机测试 NFC 读写
- 单次扫描只能读取一个标签，符合本方案"精确指向"的定位
- 标签需贴近手机 NFC 感应区（通常位于手机顶部背面）
- 写入前请确认标签为空白或可覆盖的 NDEF 格式

## 后续可扩展

- 增加二维码备用方案（无 NFC 手机可用）
- 接入 iCloud 同步
- AR 书架高亮显示
- 语音搜索（"我的护照在哪？"）
