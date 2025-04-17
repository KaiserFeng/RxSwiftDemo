//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2025/4/14.
//

/// 官网文档：https://reactivex.io/documentation/operators.html#transforming

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        testRecursiveLock()
//        testCreateObservable()
//        testTransformOperators()
        testConditionalOperators()
    }
    
    
    func testCreateObservable() {
        let ob = Observable<String>.create { observer in
            observer.onNext("Hello world")
            observer.onCompleted()
            return Disposables.create()
        }
        
        let _ = ob.subscribe(onNext: { next in
            print(next)
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("completed")
        }).disposed(by: disposeBag);
        
        let _ = ob.subscribe(onNext: { next in
            print(next)
        }).disposed(by: disposeBag);
    }
    
    /// 映射操作符
    func testTransformOperators() {
        testMapTransformOperators()
        testFlatMapTransformOperators()
        testFlatMapLatestTransformOperators()
        testFlatMapFirstTransformOperators()
        testScanTransformOperators()
    }
    
    /// 过滤操作符
    func testConditionalOperators() {
        testFilterConditionalOperators()
        
    }
    
    func testMapTransformOperators() {
        // ***** map: 转换闭包应用于可观察序列发出的元素，并返回转换后的元素的新可观察序列。
        print("*****map*****")
        /// 1、通过 map 操作符，ObservableSequence<Array<Int>> 序列 映射成一个新的 Map<Array<Int>> 序列
        /// 其中 ObservableSequence<Array<Int>> 序列 称为 源序列，Map<Array<Int>> 序列 称为 目标序列
        /// map操作，是将 ObservableSequence<Array<Int>> 源序列 和 map 的闭包 存储到 Map<Array<Int>> 目标序列中
        ///
        /// 2、Map<Array<Int>> 目标序列 通过 调用 ObservableType 协议的扩展方法 subscribe(onNext:onError:onCompleted:onDisposed:) 订阅目标序列
        /// 在 subscribe 方法中， 生成 AnonymousObserver 对象，存储 eventHandler 闭包，随时监听 event 事件回调。
        ///
        /// 3、调用 self.asObservable().subscribe(observer)开启一系列后续操作。
        /// subscribe(observer) 方法是 ObservableType 协议中定义的方法，Observable 遵守 ObservableType协议，在Observable 中实现协议方法。从设计里面上，Observable 是一个虚基类，subscribe(observer) 方法的实现需要继承它的子类来实现。
        /// ObservableSequence<Array<Int>> 、Map<Array<Int>> 序列 都是Producer的子类，而Producer是 Observable 的子类。源序列、目标序列均未实现 subscribe(observer) 方法。所以就会走父类 Producer
        /// 的 subscribe(observer) 方法。
        /// 在Producer 的 subscribe(observer) 方法中，调用了 run(observer, cancel:) 方法，run(observer, cancel:) 方法是 Producer 的抽象方法，必须在子类中实现。
        ///
        /// 4、在 Map<Array<Int>>  中实现了 run(observer, cancel:) 方法，返回 (sink: Disposable, subscription: Disposable) 元组。
        /// 其中 生成 MapSink 实例对象，用以存储 map 的闭包，链条最终的 观察者 对象 Observer（此处 Oberver 就是 AnonymousObserver 实例对象），以及 cancel （销毁者）对象。
        ///
        /// 5、源序列调用 subscribe(sink) 方法，返回一个 Disposable 对象，存储在 subscription 中。
        /// 将MapSink 作为观察者对象，再次调用 序列的扩展方法 subscribe(observer) 方法。
        /// 在 Producer 的 subscribe(observer) 方法中，调用了 run(observer, cancel:) 方法，返回 (sink: Disposable, subscription: Disposable) 元组。
        ///
        /// 6、在 源序列ObservableSequence<Array<Int>> 中实现了 run(observer, cancel:) 方法，返回 (sink: Disposable, subscription: Disposable) 元组。
        /// 其中 生成 ObservableSequenceSink 实例对象，用以存储 观察者对象 Observer（此处 Oberver 就是 MapSink 实例对象），以及 cancel （销毁者）对象。
        ///
        /// 7、进而调用 ObservableSequenceSink 的 run方法，进而循环遍历源序列中的元素。
        /// 在遍历元素的过程中，调用了 forwardOn(_ event: Event<SourceType>) 方法。forwardOn(_ event: Event<SourceType>) 方法是 Sink 的方法，通过 final 关键字修饰，也就是不能被重写，在 Sink 中实现了。
        /// 在 Sink 的 forwardOn(_ event: Event<SourceType>) 方法中，调用了 self.observer.on(_ event: Event<SourceType>) 方法。也就是 协议 ObserverType 中定义的方法。
        ///
        /// 8、ObservableSequenceSink 中存储的观察者是MapSink，其实现 了 ObserverType 协议中的 on(_ event: Event<SourceType>) 方法。
        /// MapSink 在 on(_ event: Event<SourceType>) 方法中，调用了 map 的闭包，将源序列中的元素传递给闭包，闭包返回的结果就是目标序列中的元素。
        ///
        /// 9、MapSink 在 on(_ event: Event<SourceType>) 方法中，再次通过 forwardOn(_ event: Event<SourceType>) 方法，也就是上述讲到的 Sink 的方法，
        /// MapSink中 存储的观察者是AnonymousObserver对象，AnonymousObserver 对象实现 OberverType 协议的 on(_ event: Event<SourceType>) 方法。
        ///
        /// 10、AnonymousObserver 对象在 on(_ event: Event<SourceType>) 方法中，调用了eventHandler闭包，闭包中的参数就是目标序列中的元素。
        /// 所以最终打印出来的就是目标序列中的元素。
        ///
        /// 延伸：
        /// 无论中间经过多少次的转换，最终还是会调用到 AnonymousObserver 对象的 eventHandler 闭包。这就是对函数式编程的支持。
        /// 加一个 filter后
        /// 调用链关系如下：1. ObservableSequence<Array<Int>> -> 2. Filter -> 3. Map -> 4. AnonymousObserver
        /// 遍历 ObservableSequence<Array<Int>> 中的元素，先经过 filter 过滤，再经过 Map 映射，最后 AnonymousObserver 通过 eventHandler 传递到外面。
        /// 1、序列通过 subscribe(oberver) 方法订阅，子类实现 Producer 的 run(observer, cancel:) 方法，返回一个 (sink: Disposable, subscription: Disposable) 元组。
        /// 2、在 run(observer, cancel:) 方法中，调用 Sink 的 forwardOn(_ event: Event<SourceType>) 方法, forwardOn(_ event: Event<SourceType>) 方法 调用 观察者的 on(_ event: Event<SourceType>) 方法。
        /// 3、子类实现 run(observer, cancel:) 方法，再次重复 2 步骤，直到最后的 AnonymousObserver 。
        /// 4、AnonymousObserver 调用 eventHandler 闭包，闭包中的参数就是目标序列中的元素。
        /// 代码编写逻辑从上到下；执行顺序从下到上后再从上到下。各个环节的调用关系是相互独立的，可增可减。函数式编程思想。
        /// 生成一个 ObservableSequence<Array<Int>> 序列
        let ob = Observable.of(1, 2, 3, 4, 5)
        let _ = ob.filter({ num in
            num > 2
        }).map { num in
            num + 2
        }.subscribe(onNext: { next in
            print(next)
        }).disposed(by: disposeBag)
    }
    
    func testFlatMapTransformOperators() {
        print("*****flatMap*****")
        /// flatMap: 将一个可观察序列中的元素转换为另一个可观察序列，并将所有这些可观察序列合并为一个新的可观察序列。
        /// flatMap 是一个高阶函数，接收一个闭包作为参数，闭包接收一个元素并返回一个可观察序列。
        /// flatMap 会将所有这些可观察序列合并为一个新的可观察序列。
        /// flatMap 是一个异步操作符，它会将所有的可观察序列合并为一个新的可观察序列。
        let boy = LGPlayer(score: 90)
        let girl = LGPlayer(score: 80)
        let player = BehaviorSubject(value: boy)
        
        player.flatMap { player in
            player.score
        }.subscribe(onNext: { score in
            print(score)
        }).disposed(by: disposeBag)
        
        boy.score.onNext(60)
        player.onNext(girl)
        boy.score.onNext(50)
        boy.score.onNext(40)
        girl.score.onNext(10)
        girl.score.onNext(0)
    }
    
    func testFlatMapLatestTransformOperators() {
        print("*****flatMapLatest*****")
        let boyLatest = LGPlayer(score: 90)
        let girlLatest = LGPlayer(score: 80)
        let playerLatest = BehaviorSubject(value: boyLatest)
        
        /// BehaviorSubject序列 是源序列，FlatMapLatest序列是 目标序列，
        /// FlatMapLatest 生成 MapSwitchSink-> SwitchSink 对象，存储了闭包和 观察者对象。
        // 第一阶段：初始化
        // boyLatest 初始值为 90
        // ✅ 输出 90（初始值）
        playerLatest.flatMapLatest { player in
            player.score
        }.subscribe(onNext: { score in
            print(score)
        }).disposed(by: disposeBag)
        
        // 第二阶段：boy的新值
        // ✅ 输出 60
        boyLatest.score.onNext(60)
        boyLatest.score.onNext(61)
        // 第三阶段：切换到girl
        playerLatest.onNext(girlLatest) // 切换到girl 新序列，取消boy 旧序列的订阅
        boyLatest.score.onNext(50) // 被忽略
        boyLatest.score.onNext(40) // 被忽略
        girlLatest.score.onNext(10)  // ✅ 输出 10
        girlLatest.score.onNext(5)  // ✅ 输出 5
    }
    
    func testFlatMapFirstTransformOperators() {
        print("*****flatMapFirst*****")
        let boyFirst = LGPlayer(score: 90)
        let girlFirst = LGPlayer(score: 80)
        let playerFirst = BehaviorSubject(value: boyFirst)
        
        /// flatMapFirst 的关键特点是它只处理第一个活跃序列,即使后续有新的序列(girlFirst)加入也会被忽略,直到当前活跃序列完成。这对于防止重复操作很有用
        playerFirst.flatMapFirst { player in
            player.score.asObservable()
        }.subscribe(onNext: { score in
            print(score)
        }).disposed(by: disposeBag)
        
        /// ObserverType.onNext ----> BehaviorSubject.on ----> MergeSinkIter.on ----> Sink.forwardOn ----> ObserverBase.on ----> AnonomousObserver.on ----> eventHandler闭包
        boyFirst.score.onNext(60)      // ✅ 输出 60
        boyFirst.score.onNext(61)      // ✅ 输出 61
        playerFirst.onNext(girlFirst)  // 忽略切换,因为有一个活跃序列 boyFirst，当boyFirst完成时，才会切换到girlFirst
        boyFirst.score.onNext(50)      // ✅ 输出 50
        boyFirst.score.onNext(40)      // ✅ 输出 40
        girlFirst.score.onNext(10)     // 被忽略
        girlFirst.score.onNext(5)      // 被忽略
    }
    
    func testScanTransformOperators() {
        print("*****scan*****")
        /// scan: 将一个初始值和一个可观察序列中的元素组合在一起，返回一个新的可观察序列。
        /// scan 是一个高阶函数，接收两个参数，一个初始值和一个闭包。闭包接收两个参数，一个是初始值，一个是可观察序列中的元素，通过计算返回一个新的值。
        ///
        /// 1、scan 的初始值是 0，闭包接收两个参数，一个是初始值，一个是可观察序列中的元素，返回一个新的值。
        /// 2、scan 会将初始值和可观察序列中的元素组合在一起，返回一个新的可观察序列。
        
        let scanOb = Observable.of(10, 100, 1000, 10000)
        scanOb.scan(2) { value, newValue in
            value + newValue
        }.subscribe(onNext: { next in
            print(next)      // 2+10=12, 12+100=112, 112+1000=1112, 1112+10000=11112
        })
        .disposed(by: disposeBag)
    }
    
    func testFilterConditionalOperators() {
        print("*****filter*****")
        
        /// filter 是一个高阶函数，接收一个闭包作为参数，闭包接收一个元素并返回一个布尔值。
        /// filter 会将所有满足条件的元素组合在一起，返回一个新的可观察序列。
        Observable.of(1, 2, 3, 4, 5)
            .filter { item in
                item > 2
            }.subscribe(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
        
        print("*****distinctUntilChanged*****")
        /// distinctUntilChanged: 过滤掉连续重复的元素，只保留第一个元素。
        /// distinctUntilChanged 是一个高阶函数，接收一个闭包作为参数，闭包接收两个元素并返回一个布尔值。
        /// distinctUntilChanged 会将所有连续重复的元素过滤掉，只保留第一个元素。
        Observable.of(1, 2, 1, 2, 3, 3, 4, 5, 6, 2)
            .distinctUntilChanged()
            .subscribe { value in
                print(value)
            }.disposed(by: disposeBag)

        print("*****elementAt*****")
        /// elementAt: 过滤掉所有元素，只保留指定索引的元素。
        /// elementAt 是一个高阶函数，接收一个索引作为参数，返回一个新的可观察序列。
        Observable.of(1, 2, 3, 4, 5)
            .element(at: 3)
            .subscribe(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
        
        print("*****single*****")
        /// single: 过滤掉所有元素，只保留唯一的元素。返回满足条件的第一个元素，否则返回error。发出多个元素时，返回error。
        /// single 是一个高阶函数，接收一个闭包作为参数，闭包接收两个元素并返回一个布尔值。
        Observable.of("SG","KF", "FZ")
            .single()
            .subscribe(onNext: {value in
                print(value)
            }).disposed(by: disposeBag)
        
        Observable.of("SG","KF", "FZ")
            .single({ value in
                value == "MC" // 过滤条件
            })
            .subscribe(onNext: { value in
                print(value)
            }, onError: { error in
                print(error)
            }).disposed(by: disposeBag)
        
        print("*****take*****")
        /// take: 过滤掉所有元素，只保留前 n 个元素。
        /// take 是一个高阶函数，接收一个元素作为参数，将前 n 个元素保留，其他元素过滤掉。
        Observable.of(1, 2, 3, 4, 5)
            .take(2)
            .subscribe(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
        
        print("*****takeLast*****")
        /// takeLast: 过滤掉所有元素，只保留最后的元素。
        /// takeLast 是一个高阶函数，接收一个元素作为参数
        /// 将所有元素入队，超过指定元素数时，出队一个元素。直到最后。
        Observable.of(1, 2, 3, 4, 5)
            .takeLast(3)
            .subscribe(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
        
#warning("当 谓词首次返回 false 时，立即完成序列")
        print("*****takeWhile*****")
        /// takeWhile: 过滤元素，保留满足条件的元素。当 谓词首次返回 false 时，立即完成序列
        /// takeWhile 是一个高阶函数，接收一个闭包作为参数，闭包接收一个元素并返回一个布尔值。

        Observable.of(1, 2, 3, 4, 5)
            .take(while: { value in
                value > 3
            }).subscribe(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
        
        print("*****takeUntil*****")
        /// takeUntil: 当另外一个序列发出元素时，源序列停止发送元素。
        /// takeUntil 是一个高阶函数，接收一个序列作为参数，当另外一个序列发出元素时，源序列停止发送元素。
        /// 当 另外一个序列发送元素时，会让源序列 发送一个 onCompleted 事件，源序列停止发送元素。
        /// 实际应用场景：当我点击一个按钮的时候，就终止某些操作。
        let sourceSequence = PublishSubject<String>()
        let referenceSequence = PublishSubject<String>()
        
        sourceSequence.take(until: referenceSequence)
            .subscribe(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
        
        sourceSequence.onNext("KF")
        sourceSequence.onNext("MC")
        sourceSequence.onNext("FZ")

        referenceSequence.onNext("CL") // 条件一出来,下面就走不了
        
        sourceSequence.onNext("SG")
        sourceSequence.onNext("LV")
        
        print("*****takeUntil*****")
        Observable.of("SG","KF", "FZ")
            .take(until: { value in
                value == "KF" // 过滤条件
            }).subscribe(onNext: { value in
                print(value)
            }, onError: { error in
                print(error)
            }).disposed(by: disposeBag)
        
        print("*****skip*****")
        /// skip: 过滤掉前 n 个元素。
        /// skip 是一个高阶函数，接收一个元素作为参数，将前 n 个元素过滤掉，其他元素保留。
        /// 这个要重点,应用非常频繁 不用解释 textfiled 都会有默认序列产生
        Observable.of(1, 2, 3, 4, 5)
            .skip(2)
            .subscribe(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
        
        print("*****skipWhile*****")
#warning("当 谓词首次返回 false 时，后续元素全部输出到新的序列中")
        Observable.of(4, 3, 5, 2, 6)
            .skip(while: {value in
                value > 3
            }).subscribe(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
        
        print("*****skipUntil*****")
        let sourceSeq = PublishSubject<String>()
        let referenceSeq = PublishSubject<String>()
        
        sourceSeq
            .skip(until: referenceSeq)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        // 没有条件命令 下面走不了
        sourceSeq.onNext("KF")
        sourceSeq.onNext("FZ")
        sourceSeq.onNext("MC")
        
        referenceSeq.onNext("CL") // 条件一出来,下面就可以走了,内部将 bool 值置为 true。
        
        sourceSeq.onNext("LV")
        sourceSeq.onNext("SG")
    }
    
    func testRecursiveLock() {
        let safeManager = SafeManager()
        safeManager.methodA()
        
        DispatchQueue.global().async {
            safeManager.modify()
        }
        
        DispatchQueue.global().async {
            safeManager.modify()
        }
    }
}

struct LGPlayer {
    let score: BehaviorSubject<Int>
    
    init(score: Int) {
        self.score = BehaviorSubject<Int>(value: score)
    }
}

class SafeManager {
    private let lock = NSRecursiveLock()
    private var data = 0
    
    func methodA() {
        lock.lock()
        defer { lock.unlock() }
        print("methodA 1")
        methodB()
        print("methodA 2")
    }
    
    func methodB() {
        lock.lock()
        defer { lock.unlock() }
        print("methodB")
    }
    
    func modify() {
        lock.lock()
        defer { lock.unlock() }
        innerModify()   // 同一线程可重入
        data += 1       // 数据修改被锁保护
        print("data = \(data), thread = \(Thread.current)")
    }
    
    private func innerModify() {
        lock.lock()
        defer { lock.unlock() }
        data += 2       // 数据修改被锁保护
        print("data = \(data), thread = \(Thread.current)")
    }
}

