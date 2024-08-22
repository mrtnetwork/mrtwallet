class AtomicMap<Key: Hashable, Value> {
    private var internalMap: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "com.mrtwallet.mrt.atomicMapQueue", attributes: .concurrent)

    // Method to get a value for a key
    func value(forKey key: Key) -> Value? {
        var result: Value?
        queue.sync {
            result = internalMap[key]
        }
        return result
    }

    // Method to set a value for a key
    func setValue(_ value: Value?, forKey key: Key) {
        queue.async(flags: .barrier) {
            self.internalMap[key] = value
        }
    }

    // Method to remove a value for a key
    func removeValue(forKey key: Key) {
        queue.async(flags: .barrier) {
            self.internalMap.removeValue(forKey: key)
        }
    }

    // Method to get all keys
    func allKeys() -> [Key] {
        var result: [Key] = []
        queue.sync {
            result = Array(internalMap.keys)
        }
        return result
    }
}
