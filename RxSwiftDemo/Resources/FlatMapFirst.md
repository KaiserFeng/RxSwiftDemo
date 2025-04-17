#  FlatMapFirst

### 工作原理
我来解析 `flatMapFirst` 的工作流程和实际应用场景：

`flatMapFirst` 操作符主要用于投影和转换序列，但与普通 `flatMap` 不同的是它只处理当前没有活跃序列时的元素。

工作流程:

1. 当源序列发出元素时,检查是否有活跃的内部序列正在处理
2. 如果没有活跃序列(`activeCount == 0`),则:
   - 使用 selector 将元素转换为新的 Observable 序列
   - 订阅该序列并开始发送元素
3. 如果有活跃序列,则忽略当前元素
4. 当活跃序列完成时,将 `activeCount` 减 1,可以处理新的元素

示例代码:

```swift
let buttonTaps = button.rx.tap.asObservable()

buttonTaps.flatMapFirst { _ in
    // 只有当前次网络请求完成后,才会处理下一次点击
    return networkService.fetchData() 
}
.subscribe(onNext: { result in
    print("Got result: \(result)")
})
```

主要应用场景:

- 防止重复提交表单
- 处理重复点击事件
- 控制并发网络请求
- 需要串行处理的场景

`flatMapFirst` 在需要控制并发、避免重复操作的场景下非常有用。它确保在上一个操作完成前,不会开始新的操作。

### 代码解读

让我解读代码中 `flatMapFirst` 相关的实现和流程：

这部分代码演示了 `flatMapFirst` 处理序列转换的过程：

```swift
let boyFirst = LGPlayer(score: 90)
let girlFirst = LGPlayer(score: 80)
let playerFirst = BehaviorSubject(value: boyFirst)

playerFirst.flatMapFirst { player in
    player.score.asObservable()
}.subscribe(onNext: { score in
    print(score)
}).disposed(by: disposeBag)
```

执行流程:

1. 创建初始序列:
- `boyFirst` - 得分为90的玩家
- `girlFirst` - 得分为80的玩家 
- `playerFirst` - 以 `boyFirst` 为初始值的 `BehaviorSubject`

2. `flatMapFirst` 转换:
- 将 `player` 转换为其 `score` 的 Observable
- 只处理第一个活跃序列的事件
- 忽略后续序列直到当前序列完成

3. 事件触发顺序:
```swift
boyFirst.score.onNext(60)    // 输出 60
boyFirst.score.onNext(61)    // 输出 61
playerFirst.onNext(girlFirst) // 忽略切换
boyFirst.score.onNext(50)    // 继续输出 50 
boyFirst.score.onNext(40)    // 继续输出 40
girlFirst.score.onNext(10)   // 被忽略
girlFirst.score.onNext(5)    // 被忽略
```

`flatMapFirst` 的关键特点是它只处理第一个活跃序列,即使后续有新的序列(girlFirst)加入也会被忽略,直到当前活跃序列完成。这对于防止重复操作很有用。

