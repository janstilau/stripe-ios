

/*
    在 Stripe 其实并没有使用到 Promise 这个框架, 而是在自己内部, 模拟了一下 Promise 的实现.
    简单的几个类.
 */
class Future<Value> {
    typealias Result = Swift.Result<Value, Error>
    
    // 只能是内部进行值的改变.
    fileprivate var result: Result? {
        // Observe whenever a result is assigned, and report it:
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
