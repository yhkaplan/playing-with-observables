
class Observable<Type> {

    var value: Type {
        didSet {
            removeNilObserverCallbacks()
            notifiyCallbacks(value: oldValue, options: .old)
            notifiyCallbacks(value: value, options: .new)
        }
    }

    private var callbacks: [Callback] = []

    init(_ value: Type) {
        self.value = value
    }

    func addObserver(
       _ observer: AnyObject,
       removeIfExists: Bool = true,
       options: [ObservableOptions] = [.new],
       closure: @escaping(Type, ObservableOptions) -> Void
    ) {
        if removeIfExists {
            removeObserver(observer)
        }

        let callback = Callback(
            observer: observer,
            options: options,
            closure: closure
        )
        callbacks.append(callback)

        if options.contains(.initial) {
            closure(value, .initial)
        }
    }

    func removeObserver(_ observer: AnyObject) {
        callbacks = callbacks.filter { $0.observer != observer }
    }

    private func removeNilObserverCallbacks() {
        callbacks = callbacks.filter { $0.observer != nil }
    }

    private func notifiyCallbacks(value: Type, option: ObservableOptions) {
        let callbacksToNotify = callbacks.filter { $0.options.contains(option) }
        callbacksToNotify.forEach { $0.closure(value, option) }
    }

    private class Callback {
        weak var observer: AnyObject?
        let options: [ObservableOptions]
        let closure: (Type, ObservableOptions) -> Void

        init(
            observer: AnyObject,
            options: [ObservableOptions],
            closure: @escaping (Type, ObservableOptions)
        ) -> Void {
            self.observer = observer
            self.options = options
            self.closure = closure
        }
    }

}

// TODO: read about OptionSet https://oleb.net/blog/2016/09/swift-option-sets/
struct ObservableOptions: OptionSet {
    static let initial = ObservableOptions(rawValue: 1 << 0)
    static let old = ObservableOptions(rawValue: 1 << 1)
    static let new = ObservableOptions(rawValue: 1 << 2)

    var rawValue: Int

    // TODO: can this be replaced w/ memberwise init?
    init(rawValue: Int) {
        self.rawValue = rawValue
    }

}
