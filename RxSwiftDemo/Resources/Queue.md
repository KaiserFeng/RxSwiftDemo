#  Queue

### 如何实现FIFO队列

Queue 通过巧妙的数组管理实现了先进先出(FIFO)机制。让我分析关键点:

1. 基本数据结构:
```swift
private var storage: ContiguousArray<T?>  // 存储队列元素的数组
private var innerCount = 0                 // 当前队列元素数量 
private var pushNextIndex = 0             // 下一个入队位置
```

2. 入队操作(enqueue):
```swift
mutating func enqueue(_ element: T) {
    // 如果容量满了,则扩容
    if count == storage.count {
        resizeTo(Swift.max(storage.count, 1) * resizeFactor)
    }
    
    storage[pushNextIndex] = element  // 在 pushNextIndex 位置存储元素
    pushNextIndex += 1                // pushNextIndex 向后移动
    innerCount += 1                   // 元素数量加1
    
    // 如果 pushNextIndex 超出数组边界,则回到数组开头(循环使用)
    if pushNextIndex >= storage.count {
        pushNextIndex -= storage.count
    }
}
```

3. 出队操作(dequeue):
```swift
private var dequeueIndex: Int {
    // 计算出队位置 = 入队位置 - 元素数量
    let index = pushNextIndex - count
    // 如果是负数,则需要回到数组末尾
    return index < 0 ? index + storage.count : index
}

mutating func dequeue() -> T? {
    if count == 0 { return nil }
    
    let element = dequeueElementOnly() // 获取并移除元素
    
    // 如果元素数量少,则考虑缩小容量
    let downsizeLimit = storage.count / (resizeFactor * resizeFactor)
    if count < downsizeLimit && downsizeLimit >= initialCapacity {
        resizeTo(storage.count / resizeFactor)
    }
    
    return element
}
```

实现FIFO的关键:
1. 通过 pushNextIndex 标记下一个入队位置,元素依次向后添加
2. 通过 dequeueIndex 计算出队位置,确保先进入的元素先出队 
3. 当下标超出数组边界时,通过取模运算回到数组开头,实现循环使用
4. 动态调整数组容量,在需要时扩容或缩容

这种设计让入队和出队操作的平均时间复杂度都是 O(1),是一个高效的队列实现。

