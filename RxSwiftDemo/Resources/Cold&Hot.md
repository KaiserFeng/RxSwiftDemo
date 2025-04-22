#  冷信号&热信号

## 冷信号

定义：被动型数据流，订阅时触发生产逻辑，每个订阅者独立接收完整事件序列。
特点：
- 惰性执行：无订阅不产生数据，订阅后才开始发送数据；
- 一对一关系：每次订阅创建独立数据流，事件从初始状态重新触发；
- 完整性保证：订阅者无论何时加入，都能得到完整的事件序列。

## 热信号

定义：主动性数据流，创建后即开始发送数据，与订阅者存在时间无关
特点：
- 即时推送：无论是否订阅，数据持续生成；
- 共享数据源：多个订阅者共享同一数据源，后续订阅者只接收订阅后的新事件；
- 一对多关系：事件推送独立于订阅者生命周期。

## 例子

让我通过源码来解释冷信号(Cold Observable)和热信号(Hot Observable)的区别：

## 冷信号(Cold Observable)

冷信号特点：
- 每个订阅者都获得完整独立的序列
- 数据从订阅时开始产生

```swift
// 冷信号的典型例子
let interval = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)

// 第一个订阅者
interval.subscribe(onNext: { value in 
    print("订阅者 1: \(value)")
})

// 第二个订阅者(3秒后)
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    interval.subscribe(onNext: { value in
        print("订阅者 2: \(value)")
    })
}

// 输出:
// 订阅者 1: 0
// 订阅者 1: 1
// 订阅者 1: 2
// 订阅者 2: 0  <- 新订阅者从头开始接收
// 订阅者 1: 3
// 订阅者 2: 1
```

## 热信号(Hot Observable)

热信号特点：
- 订阅者共享同一数据流
- 订阅者只能接收到订阅之后的数据

```swift 
// 通过 publish() 将冷信号转换为热信号
let hot = interval.publish()

// 第一个订阅者
hot.subscribe(onNext: { value in
    print("订阅者 1: \(value)")
})

// 开始发送数据
hot.connect()

// 第二个订阅者(3秒后)
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    hot.subscribe(onNext: { value in
        print("订阅者 2: \(value)")
    })
}

// 输出:
// 订阅者 1: 0
// 订阅者 1: 1
// 订阅者 1: 2
// 订阅者 1: 3  
// 订阅者 2: 3  <- 新订阅者只收到当前值
```

## 核心实现

从源码可以看到热信号的关键实现:

```swift
// ConnectableObservable 的核心实现
final private class ConnectableObservableAdapter<Subject: SubjectType> {
    private let source: Observable<Subject.Observer.Element>
    private let makeSubject: () -> Subject
    private var subject: Subject?
    private var connection: ConnectionType?
    
    // connect() 方法触发订阅
    override func connect() -> Disposable {
        return self.lock.performLocked {
            if let connection = self.connection {
                return connection
            }
            
            // 建立源序列到 subject 的订阅
            let connection = Connection(...)
            self.connection = connection
            let subscription = self.source.subscribe(connection)
            return connection
        }
    }
    
    // 订阅方法
    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable {
        // 所有订阅者共享同一个 subject
        self.lazySubject.subscribe(observer)
    }
}
```

关键点：
1. 冷信号每个订阅者独立
2. 热信号通过 Subject 实现共享
3. 需要 connect() 触发订阅
4. 热信号订阅者共享同一数据流

