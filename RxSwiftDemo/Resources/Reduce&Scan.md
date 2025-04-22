#  Reduce&Scan

### 两者的区别
让我解释一下 `reduce` 和 `scan` 这两个操作符的主要区别:

## 1. 输出时机不同

`reduce`:
```swift
Observable.of(10, 100, 1000)
    .reduce(2, accumulator: { $0 + $1 })
    .subscribe(onNext: { print($0) })
// 只输出最终结果: 1112 (2 + 10 + 100 + 1000)
```

`scan`:
```swift
Observable.of(10, 100, 1000)
    .scan(2, accumulator: { $0 + $1 })
    .subscribe(onNext: { print($0) })
// 输出每步计算结果:
// 12 (2 + 10)
// 112 (12 + 100)
// 1112 (112 + 1000)
```

## 2. 主要区别

1. `reduce`:
- 只发出最终的累积结果
- 需要等待序列完成才会发出值
- 类似 Swift 数组的 reduce 方法
- 适用于只需要最终结果的场景

2. `scan`:
- 发出每一步的累积结果
- 实时发出中间计算状态
- 保留了计算过程中的所有状态
- 适用于需要追踪累积过程的场景

## 3. 使用场景

`reduce` 适合:
```swift
// 计算最终总和
let total = Observable.of(1, 2, 3, 4, 5)
    .reduce(0, accumulator: +)
```

`scan` 适合:
```swift
// 显示实时计数
let counter = Observable.of(1, 1, 1)
    .scan(0, accumulator: +)
// 输出: 1, 2, 3
```

### 各自的应用场景
让我解释 `reduce` 和 `scan` 的常用业务场景：

## reduce 常用场景

1. **计算最终总和/汇总**:
```swift
// 购物车商品总价计算
let prices = Observable.of(12.99, 2.99, 9.99)
prices.reduce(0, accumulator: +)
    .subscribe(onNext: { total in 
        print("Total: $\(total)")
    })
```

2. **数组合并/拼接**:
```swift
// 多个请求结果合并
let results = Observable.of(["A"], ["B", "C"], ["D"])
results.reduce([], accumulator: { $0 + $1 })
    .subscribe(onNext: { 
        print("Combined results: \(combined)")
    })
```

## scan 常用场景

1. **实时计数/累加**:
```swift
// 点击次数实时统计
button.rx.tap
    .scan(0) { count, _ in count + 1 }
    .subscribe(onNext: { count in
        countLabel.text = "Clicked: \(count) times"
    })
```

2. **状态追踪**:
```swift
// 用户操作历史记录
let actions = Observable.of("login", "view_page", "add_cart")
actions.scan([]) { history, action in
    history + [action]
}.subscribe(onNext: { history in
    print("User actions: \(history)")
})
```

3. **滑动平均**:
```swift
// 股票价格移动平均
let prices = Observable.of(10, 15, 8, 12, 9)
prices.scan((count: 0, sum: 0)) { state, price in
    (count: state.count + 1,
     sum: state.sum + price)
}.map { state in 
    Double(state.sum) / Double(state.count)
}
```

## 主要区别和选择依据

- 使用 `reduce` 当:
  - 只关心最终结果
  - 需要等待所有数据处理完成
  - 计算总和、最终状态等

- 使用 `scan` 当:
  - 需要追踪中间状态
  - 需要实时更新UI
  - 需要维护状态历史
  - 需要显示进度或变化过程

