



/*
    在 Stripe 其实并没有使用到 Promise 这个框架, 而是在自己内部, 模拟了一下 Promise 的实现.
    简单的几个类.
 */

class Future<Value> {
    typealias Result = Swift.Result<Value, Error>
    
    /*
     只能在内部, 进行数据的改变.
     在这里的设计里面, 只有外界显示地调用, resolve, reject 函数, 才能对 Result 进行改变.
     这是一个正确的设计思路,
     */
    fileprivate var result: Result? {
        // Observe whenever a result is assigned, and report it:
        /*
         这里, 应该是不会存在循环引用的.
         每次 result 的赋值, 会引起 result.map(report) 的触发.
         虽然传递过去的 report 是一个包含了 Self 的闭包, 但是这个闭包会立马被调用, 不会有闭包的存储的机制.
         没有存储, 也就不会有循环引用 .
         */
        didSet { result.map(report) }
    }
    
    private var callbacks = [(Result) -> Void]()
    
    /*
     如果, 有结果了, 里面进行调用.
     如果, 没有结果, 那么就先存起来, 等有结果了之后进行调用.
     */
    func observe(using callback: @escaping (Result) -> Void) {
        // If a result has already been set, call the callback directly:
        if let result = result {
            return callback(result)
        }
        callbacks.append(callback)
    }
    
    // 当, result 被赋值了之后, 立马进行 callback 里面的存储的回调的调用.
    // 然后就清空了存储的闭包. 所以, 其实只是会被调用一次.
    private func report(result: Result) {
        callbacks.forEach { $0(result) }
        callbacks = []
    }
    
    /*
     没有实际的被用起来啊.
     */
    func chained<T>( using closure: @escaping (Value) throws -> Future<T>) -> Future<T> {
        
        // We'll start by constructing a "wrapper" promise that will be
        // returned from this method:
        let promise = Promise<T>()
        
        // 这里的设计思路, 应该是抄的 PromiseKit 里面的代码. 
        // Observe the current future:
        observe { result in
            switch result {
            case .success(let value):
                do {
                    // Attempt to construct a new future using the value
                    // returned from the first one:
                    let future = try closure(value)
                    
                    // Observe the "nested" future, and once it
                    // completes, resolve/reject the "wrapper" future:
                    future.observe { result in
                        switch result {
                        case .success(let value):
                            promise.resolve(with: value)
                        case .failure(let error):
                            promise.reject(with: error)
                        }
                    }
                } catch {
                    promise.reject(with: error)
                }
            case .failure(let error):
                promise.reject(with: error)
            }
        }
        
        return promise
    }
}

class Promise<Value>: Future<Value> {
    init(value: Value? = nil) {
        super.init()
        
        // If the value was already known at the time the promise
        // was constructed, we can report it directly:
        result = value.map(Result.success)
    }
    
    func resolve(with value: Value) {
        result = .success(value)
    }
    
    func reject(with error: Error) {
        result = .failure(error)
    }
}
