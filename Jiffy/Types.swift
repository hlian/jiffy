import Foundation

// a - token type
// u - result type
class Parser<u, a> {
    func Run(Stream<u>) -> Reply<a> {
        return Reply.Error("wrong class")
    }
}

class Stream<u> {
    let hay: u[]
    var i = 0
    typealias StreamSnapshot = Int

    init(hay: u[]) {
        self.hay = hay
    }

    func Peek() -> u  {
        let x = self.hay.startIndex
        return self.hay[x]
    }

    func Skip() {
        i += 1
    }

    func Snapshot() -> StreamSnapshot {
        return self.i
    }

    func Rewind(i: StreamSnapshot) {
        self.i = i
    }
}

enum Reply<a> {
    case Error(String)
    case Lovely(a)
}

class Thunk<u, a>: Parser<u, a> {
    let thunk: Stream<u> -> Reply<a>
    init(thunk: Stream<u> -> Reply<a>) {
        self.thunk = thunk
    }
}

class ParserRef<u, a>: Parser<u, a> {
    var parser: Parser<u, a>?
    init() {
        self.parser = nil
    }
    func Put(parser: Parser<u, a>) {
        self.parser = parser
    }
}