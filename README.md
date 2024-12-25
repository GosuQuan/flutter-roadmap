# Flutter Todo & Pomodoro App

一个使用 Flutter 开发的待办事项和番茄钟应用。

## 功能特点

### 待办事项
- ✅ 添加新的待办事项
- ✅ 标记完成/未完成
- ✅ 滑动删除待办事项
- ✅ 点击查看待办事项详情
- ✅ 美观的卡片式设计
- ✅ 动画效果

### 番茄钟
- ⏰ 可调节的计时器（默认25分钟）
- ⏰ 直观的圆形计时显示
- ⏰ 开始/暂停/重置功能
- ⏰ 优雅的渐变色设计

## 技术栈

- Flutter 3.27.1
- Dart
- Material Design

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── models/
│   └── todo_item.dart          # 数据模型
├── screens/
│   ├── home_screen.dart        # 主页面
│   ├── todo_list_screen.dart   # 待办事项页面
│   ├── detail_screen.dart      # 详情页面
│   └── pomodoro_screen.dart    # 番茄钟页面
├── styles/
│   └── todo_styles.dart        # 样式定义
└── widgets/
    └── todo_item_widget.dart   # 可重用组件
```

## 安装和运行

1. 确保已安装 Flutter SDK
```bash
flutter doctor
```

2. 获取依赖
```bash
flutter pub get
```

3. 运行应用
```bash
flutter run
```

## 开发环境要求

- Flutter 3.27.1 或更高版本
- Dart SDK 3.0.0 或更高版本
- iOS 11.0 或更高版本（用于 iOS）
- Android 5.0 (API 21) 或更高版本（用于 Android）

## 设计理念

- 简洁直观的用户界面
- 流畅的动画效果
- 符合 Material Design 规范
- 注重用户体验

## 未来计划

- [ ] 数据持久化
- [ ] 主题定制
- [ ] 番茄钟完成提醒
- [ ] 统计功能
- [ ] 标签分类
- [ ] 云同步

## 贡献指南

欢迎提交 Pull Request 或创建 Issue。

## 许可证

MIT License
