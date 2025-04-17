#  递归锁

Let me explain the working principle and practical usage of `NSRecursiveLock`:

`NSRecursiveLock` is a reentrant mutual exclusion lock that allows the same thread to acquire the lock multiple times.

Key Features:
1. Recursive nature - same thread can lock multiple times（同一线程可以多次加锁）
2. Must be unlocked same number of times it was locked （解锁次数要与加锁次数一致）
3. Thread-safe for resource access

Implementation Example:
```swift
class ThreadSafeCache {
    private let lock = NSRecursiveLock()
    private var cache: [String: Any] = [:]
    
    func set(_ value: Any, for key: String) {
        lock.lock()
        defer { lock.unlock() }
        cache[key] = value
    }
    
    func get(_ key: String) -> Any? {
        lock.lock()
        defer { lock.unlock() }
        return cache[key]
    }
    
    func process(_ key: String) {
        lock.lock()
        defer { lock.unlock() }
        
        // Can safely call other locked methods
        if let value = get(key) {
            set(value, for: key)
        }
    }
}
```

The debug version (`TRACE_RESOURCES`) adds resource tracking capabilities to monitor lock usage and detect potential memory leaks.

Use `NSRecursiveLock` when you need thread-safe access to shared resources with potential recursive calls within the same thread.

### 应用场景

NSRecursiveLock 主要在以下场景中使用：

1. 嵌套调用场景
```swift
class DataManager {
    private let lock = NSRecursiveLock()
    
    func processData() {
        lock.lock()
        defer { lock.unlock() }
        
        // 可能递归调用自身
        validateAndProcess()
    }
    
    private func validateAndProcess() {
        lock.lock()
        defer { lock.unlock() }
        // 处理数据
    }
}
```

2. 复杂对象图遍历
```swift
class TreeNode {
    private let lock = NSRecursiveLock()
    var children: [TreeNode] = []
    
    func traverse() {
        lock.lock()
        defer { lock.unlock() }
        
        // 处理当前节点
        children.forEach { child in
            child.traverse() // 递归遍历
        }
    }
}
```

3. 互相调用的方法
```swift
class ServiceManager {
    private let lock = NSRecursiveLock()
    
    func methodA() {
        lock.lock()
        defer { lock.unlock() }
        // 某些条件下调用 methodB
        methodB()
    }
    
    func methodB() {
        lock.lock()
        defer { lock.unlock() }
        // 处理逻辑
    }
}
```

主要应用场景：
- 递归算法实现
- 复杂对象遍历
- 相互依赖的方法调用
- 多层级数据处理
- 需要重入的线程安全操作

如果不使用递归锁，这些场景可能会造成死锁。NSRecursiveLock 通过允许同一线程多次获取锁来避免这个问题。

### 相互依赖的方法调用，当使用普通锁（NSLock）时容易产生死锁

当不使用递归锁而使用普通锁（如 `NSLock`）时，互相调用容易产生死锁。让我举例说明：

```swift
class ServiceManager {
    private let lock = NSLock() // 使用普通锁而非递归锁
    
    func methodA() {
        lock.lock()
        defer { lock.unlock() }
        print("methodA 1")
        methodB() // 试图再次获取已被锁住的锁，导致死锁
        print("methodA 2") // 永远不会执行到这里
    }
    
    func methodB() {
        lock.lock() // 死锁发生在这里
        defer { lock.unlock() }
        print("methodB")
    }
}
```

死锁发生的原因：
1. `methodA` 获取锁
2. `methodA` 调用 `methodB`
3. `methodB` 尝试获取已被 `methodA` 持有的锁
4. 由于普通锁不支持重入，线程被永久阻塞

使用 `NSRecursiveLock` 可以解决这个问题，就像你当前代码中的实现：
```swift
private let lock = NSRecursiveLock() // 递归锁允许同一线程多次获取锁
```

这样同一线程可以安全地多次获取锁，避免了死锁问题。

### 同一线程多次获取锁安全，不同线程获取锁互斥

递归锁不能保证不同线程之间的数据安全。让我解释一下：

1. 递归锁的特性：
- 允许**同一个线程**多次获取锁
- 不同线程之间仍然是互斥的

2. 线程安全示例：
```swift
class SafeManager {
    private let lock = NSRecursiveLock()
    private var data = 0
    
    func modify() {
        lock.lock()
        defer { lock.unlock() }
        
        // 同一线程可以多次获取锁
        innerModify() // 安全，因为是同一线程
        data += 1
    }
    
    private func innerModify() {
        lock.lock()
        defer { lock.unlock() }
        data += 2
    }
}
```

3. 线程不安全示例：
```swift
let manager = SafeManager()

// 线程1
DispatchQueue.global().async {
    manager.modify() // 获取锁后修改数据
}

// 线程2
DispatchQueue.global().async {
    manager.modify() // 必须等线程1释放锁后才能获取锁
}
```

关键点：
- 递归锁保证了**不同线程之间的互斥访问**
- 当线程1持有锁时，线程2必须等待
- 数据安全依赖于锁的互斥特性，而不是递归特性
- 递归特性只解决了同一线程内的重入问题

所以递归锁通过互斥机制保证了线程安全，其递归特性主要用于解决同一线程多次加锁的场景。

### 递归锁在多线程下是否是安全的呢？

从你的代码示例来看，递归锁在多线程环境下是安全的。让我详细解释：

1. 线程同步机制：
```swift
// 在 SafeManager 中使用 NSRecursiveLock 确保线程安全
private let lock = NSRecursiveLock()
private var data = 0
```

2. 线程互斥访问示例：
```swift
func modify() {
    lock.lock()
    defer { lock.unlock() }
    innerModify()      // 同一线程可重入
    data += 1         // 数据修改被锁保护
    print("data = \(data), thread = \(Thread.current)")
}

private func innerModify() {
    lock.lock()
    defer { lock.unlock() }
    data += 2         // 数据修改被锁保护
    print("data = \(data), thread = \(Thread.current)")
}
```

3. 多线程调用示例：
```swift
// 你的测试代码中
DispatchQueue.global().async {
    safeManager.modify()  // 线程1
}

DispatchQueue.global().async {
    safeManager.modify()  // 线程2
}
```

递归锁确保线程安全因为：
- 当线程1获得锁时，线程2必须等待
- 每次数据访问都被锁保护
- 同一线程可以重入，但不同线程之间互斥
- 所有数据修改操作都在锁的保护范围内

所以结论是：递归锁在多线程环境下是完全安全的，它既保证了同一线程的重入性，也保证了不同线程间的互斥访问。

### 不当使用递归锁场景

让我举例说明递归锁使用不当可能导致的线程不安全情况：

1. 保护不完整的数据访问：
```swift
class UnsafeManager {
    private let lock = NSRecursiveLock()
    private var data = [String: Int]()
    
    func write(_ value: Int, for key: String) {
        lock.lock()
        data[key] = value
        lock.unlock() // 没有使用 defer
        
        // 如果这里发生异常，锁不会被释放
        doSomething() 
    }
    
    func read(_ key: String) -> Int? {
        // 完全没有加锁保护
        return data[key]
    }
}
```

2. 锁的作用域不当：
```swift
class PartialSafeManager {
    private let lock = NSRecursiveLock()
    private var data = 0
    
    func process() {
        lock.lock()
        let temp = data // 复制数据
        lock.unlock()
        
        // 锁的保护范围外修改数据
        heavyComputation(temp)
        
        lock.lock()
        data = temp // 写回数据，可能已经脏数据
        lock.unlock()
    }
}
```

3. 错误的锁配对：
```swift
class MismatchedLockManager {
    private let lock = NSRecursiveLock()
    private var data = 0
    
    func modify() {
        lock.lock()
        innerModify()
        // 忘记解锁
    }
    
    private func innerModify() {
        // 解锁次数不匹配
        lock.unlock()
        data += 1
    }
}
```

正确的实现应该：
- 使用 `defer` 确保锁的释放
- 所有数据访问都在锁的保护下
- 保持锁的加锁解锁次数匹配
- 合理划分锁的作用域

### 正确使用递归锁

Here are the key best practices for using NSRecursiveLock:

1.Always pair lock/unlock using `defer`(始终使用“defer”配对锁定/解锁`)
2.Protect all data access(保护所有数据访问)
3.Keep lock scope minimal(保持锁范围最小)
4.Use proper property access patterns(使用适当的属性访问模式)

1. Always pair lock/unlock using `defer`:
```swift
class SafeManager {
    private let lock = NSRecursiveLock()
    private var data = 0
    
    func modify() {
        lock.lock()
        defer { lock.unlock() }
        // Safe operations here
    }
}
```

2. Protect all data access:
```swift
class ThreadSafeCache {
    private let lock = NSRecursiveLock()
    private var cache = [String: Any]()
    
    func get(_ key: String) -> Any? {
        lock.lock()
        defer { lock.unlock() }
        return cache[key]
    }
    
    func set(_ value: Any, for key: String) {
        lock.lock()
        defer { lock.unlock() }
        cache[key] = value
    }
}
```

3. Keep lock scope minimal:
```swift
class OptimizedManager {
    private let lock = NSRecursiveLock()
    private var data = 0
    
    func process() {
        // Only lock critical sections
        let localData: Int
        lock.lock()
        localData = data
        lock.unlock()
        
        // Heavy work outside lock
        let result = heavyComputation(localData)
        
        lock.lock()
        defer { lock.unlock() }
        data = result
    }
}
```

4. Use proper property access patterns:
```swift
class PropertyManager {
    private let lock = NSRecursiveLock()
    private var _data = 0
    
    var data: Int {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _data
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _data = newValue
        }
    }
}
```

These practices help ensure thread safety and avoid common pitfalls.

