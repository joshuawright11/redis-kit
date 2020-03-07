import AsyncKit
import RediStack

extension RedisConnection: ConnectionPoolItem {
    /// See `ConnectionPoolItem.isClosed`
    public var isClosed: Bool { return !self.isConnected }
}

extension EventLoopConnectionPool where Source == RedisConnectionSource {
    public func client() -> RedisClient {
        _PoolRedisClient(pool: self)
    }
}

private struct _PoolRedisClient {
    let pool: EventLoopConnectionPool<RedisConnectionSource>
}

extension _PoolRedisClient: RedisClient {
    var isConnected: Bool {
        true
    }
    
    var logger: Logger {
        self.pool.logger
    }

    var eventLoop: EventLoop {
        self.pool.eventLoop
    }

    func setLogging(to logger: Logger) {
        // cannot set logger
    }
    
    func send(command: String, with arguments: [RESPValue]) -> EventLoopFuture<RESPValue> {
        self.pool.withConnection {
            $0.setLogging(to: self.logger)
            return $0.send(command: command, with: arguments)
        }
    }
}
