#  Retry

让我解析 `retry` 操作符的工作原理和应用场景:

### 工作原理

1. **核心实现**
```swift
// Retry 基本实现 
extension ObservableType {
    public func retry() -> Observable<Element> {
        // 使用无限序列包装源序列
        CatchSequence(sources: InfiniteSequence(repeatedValue: self.asObservable()))
    }
    
    public func retry(_ maxAttemptCount: Int) -> Observable<Element> {
        // 使用有限次数序列包装源序列
        CatchSequence(sources: Swift.repeatElement(self.asObservable(), count: maxAttemptCount))
    }
}
```

2. **重试机制**
```swift
// 错误处理流程
class CatchSequenceSink {
    func on(_ event: Event<Element>) {
        switch event {
        case .error:
            // 发生错误时，尝试使用下一个序列
            self.nextSequence()
        case .next:
            // 正常发送数据
            self.forwardOn(event)
        case .completed: 
            // 完成时结束重试
            self.forwardOn(.completed)
        }
    }
}
```

### 应用场景

1. **网络请求重试**
```swift
func requestData() -> Observable<Data> {
    return networkRequest()
        .retry(3)  // 最多重试3次
        .catch { error in
            return handleError(error)
        }
}
```

2. **条件重试**
```swift
// 根据错误类型决定是否重试
func retryWithCondition() -> Observable<Data> {
    return someRequest()
        .retry { (error) -> Observable<Int> in
            if error is TimeoutError && retryCount < maxRetries {
                return Observable.timer(.seconds(1), scheduler: MainScheduler.instance)
            }
            return Observable.error(error)
        }
}
```

3. **带延时的重试**
```swift
// 延时重试，避免立即重试可能的临时性错误
func retryWithDelay() -> Observable<Data> {
    return apiRequest()
        .retryWhen { errors in
            return errors.enumerated().flatMap { (index, error) -> Observable<Int> in
                let delay = Double(index + 1) * 2.0
                return Observable<Int>.timer(.seconds(Int(delay)), scheduler: MainScheduler.instance)
            }
        }
}
```

4. **特定错误重试**
```swift
// 只对特定错误进行重试
func retrySpecificError() -> Observable<Response> {
    return apiCall()
        .retry { error -> Observable<Void> in
            guard let networkError = error as? NetworkError else {
                return .error(error)
            }
            switch networkError {
            case .timeout, .serverOverload:
                return .timer(.seconds(1), scheduler: MainScheduler.instance)
                    .take(3)
            default:
                return .error(error)
            }
        }
}
```

关键特点:
- 支持无限重试和有限次数重试
- 可以结合 delay 实现延时重试
- 可以根据错误类型选择性重试
- 适合处理网络请求等临时性错误

应用方式:
- 网络请求失败重试
- 资源加载失败重试
- 定时任务失败重试
- 设备连接失败重试

## 关键点

让我分析 `retry` 操作符的实现原理：

1. **入口定义**
```swift
public func retry() -> Observable<Element> {
    // 创建一个无限序列,不断重复源序列
    CatchSequence(sources: InfiniteSequence(repeatedValue: self.asObservable()))
}
```

2. **核心实现类 CatchSequenceSink**
```swift 
final private class CatchSequenceSink<Sequence, Observer>: TailRecursiveSink<Sequence, Observer> {
    // 记录最后一次错误
    private var lastError: Swift.Error?
    
    // 处理事件
    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            self.forwardOn(event)
        case .error(let error):
            // 保存错误,调度下一次重试
            self.lastError = error
            self.schedule(.moveNext)
        case .completed:
            self.forwardOn(event)
            self.dispose()
        }
    }
}
```

3. **重试流程**

```swift
// 1. 初始化序列
let retryObservable = Observable.create { ... }

// 2. 创建无限重试序列 
retryObservable.retry()

// 3. 当发生错误时:
case .error:
    lastError = error
    schedule(.moveNext) // 调度下一次重试

// 4. moveNext 触发新的订阅
override func moveNext() -> Bool {
    // 获取下一个序列源
    if let next = self.generators.next() {
        self.observers.subscribe(next)
        return true  // 继续执行
    }
    return false    // 结束重试
}
```

4. **关键点**

- 使用 `InfiniteSequence` 创建无限重试源
- 通过 `TailRecursiveSink` 实现尾递归优化
- `lastError` 记录错误状态
- `schedule(.moveNext)` 触发下一次重试
- 直到成功完成或被取消才停止重试

5. **工作流程图**

```
[源序列] -> [错误] -> [保存错误] -> [调度moveNext] -> [订阅新序列] -> [源序列] ...
                                     ↑___________________________|
```

例如上述示例代码:
```swift
var count = 1
let retryObservable = Observable<String>.create { observer in 
    observer.onNext("A")
    observer.onNext("B")
    
    // 前4次发送错误
    if count < 5 {
        observer.onError(error)
        count += 1
    }
    
    // 第5次成功完成
    observer.onNext("C") 
    observer.onNext("D")
    observer.onCompleted()
    return Disposables.create()
}

// 输出:
// A B Error -> 重试
// A B Error -> 重试
// A B Error -> 重试
// A B Error -> 重试
// A B C D   -> 完成
```

这就是 retry 操作符通过尾递归实现序列重试的核心原理。

