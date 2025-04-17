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
//        testCreateObservable()
        testTransformOperators()
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
        // ***** map: 转换闭包应用于可观察序列发出的元素，并返回转换后的元素的新可观察序列。
        print("*****map*****")
        /// 生成一个 ObservableSequence<Array<Int>> 序列
//        let ob = Observable.of(1, 2, 3, 4, 5)
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
//        let _ = ob.filter({ num in
//            num > 2
//        }).map { num in
//            num + 2
//        }.subscribe(onNext: { next in
//            print(next)
//        }).disposed(by: disposeBag)
        
        print("*****flatMap*****")
        /// flatMap: 将一个可观察序列中的元素转换为另一个可观察序列，并将所有这些可观察序列合并为一个新的可观察序列。
        /// flatMap 是一个高阶函数，接收一个闭包作为参数，闭包接收一个元素并返回一个可观察序列。
        /// flatMap 会将所有这些可观察序列合并为一个新的可观察序列。
        /// flatMap 是一个异步操作符，它会将所有的可观察序列合并为一个新的可观察序列。
//        let boy = LGPlayer(score: 90)
//        let girl = LGPlayer(score: 80)
//        let player = BehaviorSubject(value: boy)
//        
//        player.flatMap { player in
//            player.score
//        }.subscribe(onNext: { score in
//            print(score)
//        }).disposed(by: disposeBag)
//        
//        boy.score.onNext(60)
//        player.onNext(girl)
//        boy.score.onNext(50)
//        boy.score.onNext(40)
//        girl.score.onNext(10)
//        girl.score.onNext(0)
        
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
        boyLatest.score.onNext(62)
        boyLatest.score.onNext(63)
        boyLatest.score.onNext(64)
        boyLatest.score.onNext(65)
        boyLatest.score.onNext(66)
        // 第三阶段：切换到girl
        playerLatest.onNext(girlLatest) // 切换到girl，取消boy的订阅
        boyLatest.score.onNext(50) // 被忽略
        boyLatest.score.onNext(40) // 被忽略
        girlLatest.score.onNext(10)  // ✅ 输出 10
        girlLatest.score.onNext(5)  // ✅ 输出 5
        
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
}

struct LGPlayer {
    let score: BehaviorSubject<Int>
    
    init(score: Int) {
        self.score = BehaviorSubject<Int>(value: score)
    }
}

