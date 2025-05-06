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
    
    private let error = NSError(domain: "com.kaiser.rxswift", code: 10086)
    private var disposeBag = DisposeBag()
    
    private let textLabel: UILabel! = {
        let label = UILabel()
        label.text = "Hello world"
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        label.backgroundColor = .white
        return label
    }()
    
    private let inputTF: UITextField! = {
        let textField = UITextField()
        textField.placeholder = "请输入"
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.font = .systemFont(ofSize: 20)
        textField.backgroundColor = .white
        return textField
    }()
    
    private let btn: UIButton! = {
        let button = UIButton(type: .system)
        button.setTitle("点击", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        testRecursiveLock()
        testCreateObservable()
//        testTransformOperators()
//        testConditionalOperators()
//        testCombinationOperators()
//        testMathematicalAggregateOperators()
//        testConnectableOperators()
//        testErrorHandlingOperators()
//        testDebuggingOperators()
//        testDriverOperators()
    }
    
    
    func testCreateObservable() {
        print("********empty********")
        /// empty: 创建一个空的可观察序列。
        let emptyOB = Observable<Int>.empty()
        emptyOB.subscribe(onNext: { print($0) }, onError: { print("Error: \($0)")}, onCompleted: { print("complete")}).disposed(by: disposeBag)
        
        print("********just********")
        /// just: 创建一个只发出一个元素的可观察序列。
        /// just 是一个高阶函数，接收一个元素作为参数，将元素添加到序列中。
        /// just 是一个同步操作符，它会立即发出元素。
        let array = ["Kaiser", "MC"]
        let justOB = Observable<[String]>.just(array)
        justOB.subscribe(onNext: { print($0) }).disposed(by: disposeBag)
        
        print("********of********")
        Observable<Int>.of(1, 2, 3).subscribe(onNext: { print($0) }).disposed(by: disposeBag)
        Observable<[String]>.of(["a", "b", "c"], ["d"]).subscribe(onNext: { print($0) }).disposed(by: disposeBag)
        Observable<[String:String]>.of(["k1": "v1", "k2": "v2"]).subscribe(onNext: { print($0) }).disposed(by: disposeBag)
        
        print("********from********")
        Observable<Int>.from([1, 2, 3, 4, 5]).subscribe(onNext: { print("订阅：",$0) }).disposed(by: disposeBag)
        
        print("********defer********")
        /// 在观察者订阅之前不要创建Observable，并为每个观察者创建一个新的Observable
        let isOdd = true
        Observable.deferred({ () -> Observable<Int> in
            if isOdd {
                return Observable.of(1, 3, 5)
            }
            return Observable.of(2, 4, 6)
        })
        .subscribe(onNext: {print($0) })
        .disposed(by: disposeBag)
        
        print("********rang********")
        /// range: 创建一个发出指定范围内整数的可观察序列。
        Observable.range(start: 2, count: 5).subscribe(onNext: { print($0) }).disposed(by: disposeBag)
        
        print("********generate********")
        Observable.generate(initialState: 0, condition: { $0 < 10 }, iterate: { $0 + 2}).subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
        
        print("********timer********")
//        Observable<Int>.timer(.seconds(1), period: .seconds(5), scheduler: MainScheduler.instance).subscribe(onNext: {
//            print($0)
//        }).disposed(by: disposeBag)
//        
//        Observable<Int>.timer(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: {
//            print($0)
//        }).disposed(by: disposeBag)
        
        print("********interval********")
//        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: {
//            print($0)
//        }).disposed(by: disposeBag)
        
        print("********repeatElement********")
//        Observable<Int>.repeatElement(5).subscribe(onNext: {
//            print($0)
//        }).disposed(by: disposeBag)
        
        print("********never********")
        Observable<String>.never().subscribe(onNext: { print($0) }, onError: { print($0) }, onCompleted: { print("never completed") }).disposed(by: disposeBag)
        
        print("*********create***********")
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
    
    /// 组合操作符
    func testCombinationOperators() {
        print("*****startWith*****")
        /// startWith: 在序列的开头添加一个元素。
        /// startWith 是一个高阶函数，接收一个元素作为参数，将元素添加到序列的开头。
        /// 效果 CabBA123
        Observable.of("1", "2", "3")
            .startWith("A")
            .startWith("B")
            .startWith("C", "a", "b")
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        print("*****merge*****")
        /// merge: 将多个可观察序列合并为一个新的可观察序列。
        /// merge 是一个高阶函数，接收多个可观察序列作为参数，将多个可观察序列合并为一个新的可观察序列。
        let subject1 = PublishSubject<String>()
        let subject2 = PublishSubject<String>()
        Observable.of(subject1, subject2)
            .merge()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext("K")    // 输出 K
        subject1.onNext("a")    // 输出 a
        subject2.onNext("i")    // 输出 i
        subject2.onNext("s")    // 输出 s
        subject1.onNext("e")    // 输出 e
        subject2.onNext("r")    // 输出 r
        
        print("*****zip*****")
        /// zip: 将多个可观察序列合并为一个新的可观察序列。
        /// zip 是一个高阶函数，接收多个可观察序列作为参数，将多个可观察序列合并为一个新的可观察序列。
        /// .onNext() 就是入队操作，当 两个序列都入队了元素时，才会出队一对数据，根据 FIFO匹配出队的元素。
        /// 等待所有源序列都产生元素后才组合输出
        /// 按索引位置一一对应进行组合
        /// 只有两个序列同时有值的时候才会响应,否则存值
        let stringSubject = PublishSubject<String>()
        let intSubject = PublishSubject<Int>()
        
        Observable.zip(stringSubject, intSubject) { stringElement, intElement in
            "\(stringElement) \(intElement)"
        }.subscribe(onNext: { value in
            print(value)
        }).disposed(by: disposeBag)
        
        stringSubject.onNext("K")
        stringSubject.onNext("M")
        stringSubject.onNext("F") // 到这里存储了 K M F 但是不会响应,除非另一个响应
        
        intSubject.onNext(1) // 勾出一个 输出 K 1
        intSubject.onNext(2) // 勾出另一个 输出 M 2
        stringSubject.onNext("i") // 存一个
        intSubject.onNext(3) // 勾出一个 输出 F 3
        intSubject.onNext(4) // 勾出一个 输出 i 4
        
        stringSubject.onNext("C") // 存一个
        intSubject.onNext(5) // 勾出一个  输出 C 5
        
        print("*****combineLatest*****")
        /// combineLatest: 将多个可观察序列合并为一个新的可观察序列。
        /// combineLatest 是一个高阶函数，接收多个可观察序列作为参数，将多个可观察序列合并为一个新的可观察序列。
        /// 相对于zip来说，combineLatest 会覆盖旧元素，只保留新元素，当源序列都有值的时候，才会响应。
        /// 应用非常频繁: 比如账户和密码同时满足->才能登陆. 不关系账户密码怎么变化的只要查看最后有值就可以 loginEnable
        let stringSub = PublishSubject<String>()
        let intSub = PublishSubject<Int>()
        
        Observable.combineLatest(stringSub, intSub) { strElement, intElement in
            "\(strElement) \(intElement)"
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
        
        stringSub.onNext("K")   // 保存 K
        stringSub.onNext("M")   // 覆盖 K，保存 M
        intSub.onNext(1) // stringSub 有值，输出 M 1
        intSub.onNext(2) // 覆盖 1， 保存 2，stringSub 有值，输出 M 2
        stringSub.onNext("F") // 覆盖 M，保存 F，intSub 有值，输出 F 2
        
        print("*****switchLatest*****")
        /// switchLatest: 将一个可观察序列中的元素转换为另一个可观察序列，并将所有这些可观察序列合并为一个新的可观察序列。
        /// switchLatest 是一个高阶函数，接收一个闭包作为参数，闭包接收一个元素并返回一个可观察序列。
        let switchLatestSub1 = BehaviorSubject(value: "K")
        let switchLatestSub2 = BehaviorSubject(value: "1")
        let switchLatestSub = BehaviorSubject(value: switchLatestSub1)
        
        switchLatestSub.switchLatest().subscribe(onNext: { print($0) }).disposed(by: disposeBag)
        
        switchLatestSub1.onNext("F")  // ✅输出 F
        switchLatestSub1.onNext("M")  // ✅输出 M
        switchLatestSub2.onNext("2")  // 不会输出
        switchLatestSub2.onNext("3") // 2-3都会不会监听,但是默认保存由 2覆盖1 3覆盖2
        switchLatestSub.onNext(switchLatestSub2) // 切换到 switchLatestSub2 输出 3
        switchLatestSub1.onNext("*")  // 不会输出
        switchLatestSub1.onNext("C") // 原理同上面 下面如果再次切换到 switchLatestSub1会打印出 C
        switchLatestSub2.onNext("4")  // 输出 4
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
    
    func testMathematicalAggregateOperators() {
        print("*****toArray*****")
        /// toArray: 将可观察序列转换为数组。输出一个数组，数组中包含所有元素。
        Observable.range(start: 1, count: 30)
            .toArray()
            .subscribe(onSuccess: { item in
                print(item)
            }).disposed(by: disposeBag)
        
        print("*****reduce*****")
        /// reduce: 将可观察序列转换为一个元素。输出一个元素，元素是通过闭包计算出来的。
        /// reduce 是一个高阶函数，接收一个初始值和一个闭包作为参数，闭包接收两个参数，一个是初始值，一个是可观察序列中的元素，通过计算返回一个新的值。
        /// reduce 会将初始值和可观察序列中的元素组合在一起，返回一个新的可观察序列。
        Observable.of(10, 100, 1000)
            .reduce(1, accumulator: { $0 + $1})
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        print("*****concat*****")
        let subject1 = BehaviorSubject(value: "K")
        let subject2 = BehaviorSubject(value: "1")
        
        let subjectsSubject = BehaviorSubject(value: subject1)
        // 第一阶段：输出 K
        subjectsSubject.concat()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext("A")    // ✅ 输出 A
        subject1.onNext("B")    // ✅ 输出 B
        
        subjectsSubject.onNext(subject2)    // 将subject2 入队列等待subject1 完成后才会订阅
        
        subject2.onNext("2")    // 不输出
        subject2.onNext("3")    // 不输出
        
        subject1.onCompleted() // subject2 必须要等subject1 完成了才能订阅到! 用来控制顺序 网络数据的异步
        
        subject2.onNext("4")    // ✅ 输出 4
    }
    
    func testConnectableOperators() {
//        testWithoutConnect()
//        testPublishConnectableOperators()
//        testReplayConnectOperators()
        testMulticastConnectOperators()
    }
    
    func testMulticastConnectOperators() {
        print("*****multicast*****")
        let netOB = Observable<Any>.create { (observer) -> Disposable in
                sleep(2)// 模拟网络延迟
                print("我开始请求网络了")
                observer.onNext("请求到的网络数据")
                observer.onNext("请求到的本地")
                observer.onCompleted()
                return Disposables.create {
                    print("销毁回调了")
                }
            }.publish()
        
        netOB.subscribe(onNext: { (anything) in
                print("订阅1:",anything)
            })
            .disposed(by: disposeBag)

        // 我们有时候不止一次网络订阅,因为有时候我们的数据可能用在不同的额地方
        // 所以在订阅一次 会出现什么问题?
        netOB.subscribe(onNext: { (anything) in
                print("订阅2:",anything)
            })
            .disposed(by: disposeBag)
        
        _ = netOB.connect()
        
        /*
         我开始请求网络了
         订阅1: 请求到的网络数据
         订阅2: 请求到的网络数据
         订阅1: 请求到的本地
         订阅2: 请求到的本地
         销毁回调了
         */
    }
    
    func testReplayConnectOperators() {
        print("*****replay*****")
        /// replay: 将可观察序列转换为一个 ConnectableObservableSequence。
        /// replay 是一个高阶函数，接收一个参数，参数是一个整数，表示缓存的元素个数。
        /// 首先拥有和publish一样的能力，共享 Observable sequence， 其次使用replay还需要我们传入一个参数（buffer size）来缓存已发送的事件，当有新的订阅者订阅了，会把缓存的事件发送给新的订阅者
        /// 使用 队列缓存，队列中存储了 buffer size 个元素，超过 buffer size 个元素时，出队一个元素。缓存最新的事件
        let interval = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).replay(5)
        
        interval.subscribe(onNext: { print("订阅: 1, 事件: \($0)") })
            .disposed(by: disposeBag)
        
        print("connect before")
        delay(2) {
            _ = interval.connect()
            print("connect end")
        }
        delay(4) {
            interval.subscribe(onNext: {
                print("订阅: 2, 事件: \($0)")
            }).disposed(by: self.disposeBag)
        }
        delay(8) {
            interval.subscribe(onNext: { print("订阅: 3, 事件: \($0)") })
                .disposed(by: self.disposeBag)
        }
        delay(20, closure: {
            self.disposeBag = DisposeBag()
        })
        
        /*
         订阅: 1, 事件: 0
         订阅: 2, 事件: 0
         订阅: 1, 事件: 1
         订阅: 2, 事件: 1
         订阅: 1, 事件: 2
         订阅: 2, 事件: 2
         订阅: 1, 事件: 3
         订阅: 2, 事件: 3
         订阅: 1, 事件: 4
         订阅: 2, 事件: 4
         订阅: 3, 事件: 0   // 订阅: 3 从0开始，取决于 replay(5) 的参数
         订阅: 3, 事件: 1
         订阅: 3, 事件: 2
         订阅: 3, 事件: 3
         订阅: 3, 事件: 4
         订阅: 1, 事件: 5   // 后续就开始同步了
         订阅: 2, 事件: 5
         订阅: 3, 事件: 5
         订阅: 1, 事件: 6
         订阅: 2, 事件: 6
         订阅: 3, 事件: 6
         订阅: 1, 事件: 7
         订阅: 2, 事件: 7
         订阅: 3, 事件: 7
         订阅: 1, 事件: 8
         订阅: 2, 事件: 8
         订阅: 3, 事件: 8
         */
    }
    
    func testPublishConnectableOperators() {
        print("*****testPublishConnect*****")
        /// publish: 将可观察序列转换为一个 ConnectableObservableSequence。
        /// 共享一个Observable的事件序列，避免创建多个Observable sequence。
        /// 注意:需要调用connect之后才会开始发送事件
        let interval = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).publish()
        
        interval.subscribe(onNext: { print("订阅: 1, 事件: \($0)") })
            .disposed(by: disposeBag)
        
        print("connect before")
        delay(2) {
            _ = interval.connect()
            print("connect end")
        }
        delay(4) {
            interval.subscribe(onNext: {
                print("订阅: 2, 事件: \($0)")
            }).disposed(by: self.disposeBag)
        }
        delay(6) {
            interval.subscribe(onNext: { print("订阅: 3, 事件: \($0)") })
                .disposed(by: self.disposeBag)
        }
        delay(10, closure: {
            self.disposeBag = DisposeBag()
        })
        
        /**
            订阅: 1, 事件: 0
            订阅: 1, 事件: 1
            订阅: 2, 事件: 1
            订阅: 1, 事件: 2
            订阅: 2, 事件: 2
            订阅: 1, 事件: 3
            订阅: 2, 事件: 3
            订阅: 3, 事件: 3
         
            订阅: 2 从1开始
            订阅: 3 从3开始
        */
        // 但是后面来的订阅者，却无法得到之前已发生的事件
    }
    
    func testWithoutConnect() {
        print("*****testWithoutConnect*****")
        let inteval = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        
        inteval.subscribe(onNext: { print("订阅1 ： \($0)") }).disposed(by: disposeBag)
        
        delay(3) { [weak self] in
            guard let self = self else { return }
            inteval.subscribe(onNext: { print("订阅2 : \($0)")}).disposed(by: self.disposeBag)
        }
        
        delay(10) { [weak self] in
            guard let self = self else { return }
            self.disposeBag = DisposeBag()
        }
        
        // 发现有一个问题:在延时3s之后订阅的Subscription: 2的计数并没有和Subscription: 1一致，而是又从0开始了，如果想共享，怎么办?
    }
    
    func delay(_ delay: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: {
            closure()
        })
    }
    
    func testErrorHandlingOperators() {
        print("*****catchErrorJustReturn*****")
        /// catchErrorJustReturn: 处理错误事件，返回一个新的可观察序列。
        let sequenceThatFails = PublishSubject<String>()
        
        sequenceThatFails
            .catchAndReturn("error.rxswift")
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        sequenceThatFails.onNext("K")
        sequenceThatFails.onNext("F")   // 正常序列发送成功的
        sequenceThatFails.onError(self.error)   //发送失败的序列,一旦订阅到位 返回我们之前设定的错误的预案
        
        print("*****catch*****")
        /// catch: 处理错误事件，返回一个新的可观察序列。
        /// catch 是一个高阶函数，接收一个闭包作为参数，闭包接收一个错误对象并返回一个新的可观察序列。
        let errorSubject = PublishSubject<String>()
        let recoverySequence = PublishSubject<String>()
        
        errorSubject
            .catch {
                print("Error:", $0)
                return recoverySequence  // 获取到了错误序列-我们在中间的闭包操作处理完毕,返回给用户需要的序列(showAlert)
            }
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        
        errorSubject.onNext("C")
        errorSubject.onNext("L") // 正常序列发送成功的
        errorSubject.onError(error) // 发送失败的序列
        
        recoverySequence.onNext("MC")
        
        print("*****retry*****")
        var count = 1
        let retryObservable = Observable<String>.create { observer in
            observer.onNext("A")
            observer.onNext("B")
            if count < 5 {
                observer.onError(self.error)
                print("发生错误了")
                count += 1
            }
            observer.onNext("C")
            observer.onNext("D")
            observer.onCompleted()
            return Disposables.create()
        }
        
        retryObservable
            .retry()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        /*
         A
         B
         发生错误了
         A
         B
         C
         D
         */
    }
    
    func testDebuggingOperators() {
        testDebug()
//        testResourcesTotal()
    }
    
    func testDebug() {
        print("*****debug*****")
        var count = 1
        let sequenceThatErrors = Observable<String>.create { observer in
            observer.onNext("K")
            observer.onNext("a")
            observer.onNext("i")
            
            if count < 5 {
                observer.onError(self.error)
                print("错误序列来了")
                count += 1
            }
            
            observer.onNext("s")
            observer.onNext("e")
            observer.onNext("r")
            observer.onCompleted()
            
            return Disposables.create()
        }
        
        sequenceThatErrors
            .retry(3)
            .debug()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        print("*****debug map*****")
        let ob = Observable.of(1, 2, 3, 4, 5)
        let _ = ob.filter({ num in
            num > 2
        }).map { num in
            num + 2
        }.debug().subscribe(onNext: { next in
            print(next)
        }).disposed(by: disposeBag)
    }
    
    func testResourcesTotal() {
        print("*****RxSwift.Resources.total*****")

//        print(RxSwift.Resources.total)
//
//        let subject = BehaviorSubject(value: "Kaiser")
//
//        let subscription1 = subject.subscribe(onNext: { print($0) })
//
//        print(RxSwift.Resources.total)
//
//        let subscription2 = subject.subscribe(onNext: { print($0) })
//
//        print(RxSwift.Resources.total)
//
//        subscription1.dispose()
//
//        print(RxSwift.Resources.total)
//
//        subscription2.dispose()
//
//        print(RxSwift.Resources.total)
    }
    
    func testDriverOperators() {
        print("*****Driver*****")
        /// Driver: 是一个特殊的可观察序列，具有以下特点：
        /// 1. 只能在主线程上工作
        /// 2. 不会发生错误事件
        /// 3. 可以共享序列
        /// 4. 可以使用驱动器的操作符
        ///
        /// Driver 主要用于 UI 相关的响应式编程场景，通过其特性保证了 UI 操作的安全性和可维护性。它是 RxSwift 中处理 UI 事件流的最佳选择。
        view.addSubview(textLabel)
        view.addSubview(inputTF)
        view.addSubview(btn)
        textLabel.frame = CGRect(x: 0, y: 100, width: 200, height: 50)
        inputTF.frame = CGRect(x: 0, y: 200, width: 200, height: 50)
        btn.frame = CGRect(x: 0, y: 300, width: 200, height: 50)
        
        let result = inputTF.rx.text.orEmpty
            .asDriver()
            .flatMap { value in
                return self.dealWithData(input: value).asDriver(onErrorJustReturn: "error kaiser")
        }
        
        let _ = result.map({
            print($0)
            return "长度：\(($0 as! String).count)"
        }).drive(textLabel.rx.text)
        let _ = result.map( { "\($0 as! String)" } ).drive(btn.rx.title())
    }
    
    func dealWithData(input: String) -> Observable<Any> {
        print("请求网络了 \(Thread.current)")
        return Observable<Any>.create { observer in
            if input == "1234" {
                observer.onError(NSError.init(domain: "com.kaiser.rx", code: 10086, userInfo: nil))
            }
            DispatchQueue.global().async {
                print("发送之前 看看线程 \(Thread.current)")
                observer.onNext("输入了 \(input)")
                observer.onCompleted()
            }
            return Disposables.create()
        }
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

