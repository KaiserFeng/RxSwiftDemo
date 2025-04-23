#  Catch

让我分析 `catch` 操作符的工作原理和应用场景:

### 工作原理

1. **Catch 实现结构**
```swift
// 核心实现类
final private class Catch<Element>: Producer<Element> {
    // 错误处理闭包类型
    typealias Handler = (Swift.Error) throws -> Observable<Element>
    
    // 源序列
    private let source: Observable<Element>
    // 错误处理器
    private let handler: Handler
}

// 主要转换方法
public func `catch`(_ handler: @escaping (Swift.Error) throws -> Observable<Element>) 
    -> Observable<Element> {
    Catch(source: self.asObservable(), handler: handler)
}
```

2. **错误处理流程**
```swift 
// CatchSink 中的错误处理
func on(_ event: Event<Element>) {
    switch event {
    case .error(let error):
        do {
            // 调用错误处理器生成新序列
            let catchSequence = try self.parent.handler(error)
            let observer = CatchSinkProxy(parent: self)
            // 订阅新序列
            self.subscription.disposable = catchSequence.subscribe(observer)
        }
        catch let e {
            self.forwardOn(.error(e))
            self.dispose()
        }
    // ...
    }
}
```

### 应用场景

1. **网络请求错误重试**
```swift
func fetchData() -> Observable<Data> {
    return networkRequest()
        .catch { error in
            // 网络错误时返回缓存数据
            return DatabaseManager.shared.getCachedData()
        }
}
```

2. **优雅降级处理**
```swift
func loadUserProfile() -> Observable<Profile> {
    return remoteProfile()
        .catch { error in
            // 远程加载失败时加载本地配置
            return .just(Profile.defaultProfile)
        }
}
```

3. **多重错误处理**
```swift
someObservable
    .catch { error in
        switch error {
        case NetworkError.timeout:
            return retryRequest() // 超时重试
        case NetworkError.serverError:
            return showErrorAlert() // 显示错误
        default:
            return Observable.empty() // 其他错误终止
        }
    }
```

4. **错误恢复链**
```swift
// 链式错误恢复策略
fetchFromServer()
    .catch { _ in fetchFromCache() }
    .catch { _ in fetchFromDisk() }
    .catch { _ in return .just(defaultValue) }
```

5. **条件重试**
```swift
// 根据错误类型决定是否重试
someRequest()
    .catch { error in
        if error is TimeoutError && retryCount < maxRetries {
            return someRequest()
        }
        return Observable.error(error)
    }
```

关键特点:
- 错误转换为新序列
- 支持链式错误处理
- 灵活的错误恢复策略
- 适合处理网络/IO错误

# Retry

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

