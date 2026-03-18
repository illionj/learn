```md
# Minimal Tensor 实现需求（理解版）

## 🎯 目标
构建一个最小 Tensor 抽象，用于理解：

- 多维索引如何映射到一维内存
- shape / stride / offset 的作用
- view / permute / slice 的本质区别

---

## 📦 核心数据结构

必须包含 4 个属性：

- data：一维连续存储
- shape：各维大小
- stride：各维步长（权重）
- offset：起始偏移（用于切片）

---

## 🔧 必须实现的功能

### 1. 多维索引（核心能力）
支持通过多维索引访问元素

本质：
- 将多维索引映射到一维位置
- 使用 stride 和 offset 计算

---

### 2. view（reshape）
改变 Tensor 的“形状”

要求：
- 不修改底层数据
- 重新解释 shape
- 重新计算 stride
- 仅在连续内存（contiguous）时允许

---

### 3. permute（维度交换）
交换各个维度的顺序

要求：
- 重排 shape
- 重排 stride
- 不修改数据

---

### 4. slice（切片）
从原 Tensor 中取子区域

要求：
- 支持固定某一维（降维）
- 支持范围切片
- 更新 shape
- 更新 offset
- stride 保持或按规则变化
- 不拷贝数据（O(1)）

---

### 5. contiguous（建议实现）
处理非连续内存

要求：
- 判断当前是否连续
- 如不连续，生成新的连续数据副本

---

## 📐 必须理解的规则

- Tensor 本质 = 一维数据 + 多维映射规则
- stride 表示“每一维前进一步在内存中的跳跃”
- shape 表示“每一维的取值范围”
- offset 表示“当前视图的起点”

---

## ❌ 不需要实现

- 自动求导（autograd）
- GPU 支持
- 数据类型系统（dtype）
- broadcasting
- 高级索引

---

## ✅ 完成标准

能够解释以下问题：

- 多维索引如何定位到内存
- view 为什么不拷贝数据
- permute 为什么只改 stride
- slice 为什么是 O(1)
- contiguous 为什么会产生数据拷贝
```
