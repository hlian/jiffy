import Foundation

protocol Stream {
    typealias u
    func Peek() -> u
    mutating func Skip()
}

protocol Reply {
    typealias a
    func Result() -> a
    func IsLovely() -> Bool
    func IsError() -> Bool
}

// a - token type
// u - result type
class Parser<u, a> {
}

class Thunk<u, a>: Parser<u, a> {
    init<stream: Stream, reply: Reply where stream.u == u, reply.a == a>(f: stream -> reply) {
    }
}

class ParserRef<u, a>: Parser<u, a> {
    func Put(parser: Parser<u, a>) {

    }
}

class Fmap<u, a>: Parser<u, a> {
    init<t>(f: t -> a, parser: Parser<u, t>) {

    }
}

class Pure<u, a>: Parser<u, a> {
    init(x: a) {
    }
}

class Bind<u, a>: Parser<u, a> {
    init<t>(parser: Parser<u, t>, f: t -> Parser<u, a>) {
    }
}

class Left<u, a>: Parser<u, a> {
    init<b>(left: Parser<u, a>, right: Parser<u, b>) {
    }
}

class Right<u, b>: Parser<u, b> {
    init<a>(left: Parser<u, a>, right: Parser<u, b>) {
    }
}

class Ap<u, a>: Parser<u, a> {
    init<t>(parserF: Parser<u, t -> a>, parser: Parser<u, t>) {
    }
}

class Empty<u, a>: Parser<u, a> {
    init() {
    }
}

class Alt<u, a>: Parser<u, a> {
    init(left: Parser<u, a>, right: Parser<u, a>) {
    }
}

operator infix <%> { associativity left }
operator infix >>= { associativity left precedence 80 }
operator infix <*> { associativity left }
operator infix <* { associativity left }
operator infix *> { associativity left }
operator infix <|> { associativity left precedence 90 }

func <%><u, a, t>(f: t -> a, parser: Parser<u, t>) -> Parser<u, a> {
    return Fmap(f: f, parser: parser)
}

func pure<u, a>(x: a) -> Parser<u, a> {
    return Pure(x: x)
}

func <*<u, a, b>(left: Parser<u, a>, right: Parser<u, b>) -> Parser<u, a> {
    return Left(left: left, right: right)
}

func *><u, a, b>(left: Parser<u, a>, right: Parser<u, b>) -> Parser<u, b> {
    return Right(left: left, right: right)
}

func >>=<u, a, t>(parser: Parser<u, t>, f: t -> Parser<u, a>) -> Parser<u, a> {
    return Bind(parser: parser, f: f)
}

func <*><u, a, t>(parserF: Parser<u, t -> a>, parser: Parser<u, t>) -> Parser<u, a> {
    return Ap(parserF: parserF, parser: parser)
}

func <|><u, a>(left: Parser<u, a>, right: Parser<u, a>) -> Parser<u, a> {
    return Alt(left: left, right: right)
}

// Utility functions
operator infix <% { associativity left }
operator infix <**> { associativity left }

func <%<u, a, t>(x: a, left: Parser<u, t>) -> Parser<u, a> {
    return { _ in x } <%> left
}

func <**><u, a, t>(parser: Parser<u, t>, parserF: Parser<u, t -> a>) -> Parser<u, a> {
    return Ap(parserF: parserF, parser: parser)
}

func liftA<u, a, t>(f: a -> t, parser: Parser<u, a>) -> Parser<u, t> {
    return pure(f) <*> parser
}

func liftA2<u, a, s, t>(f: a -> s -> t, parser: Parser<u, a>, parser2: Parser<u, s>) -> Parser<u, t> {
    return f <%> parser <*> parser2
}

func liftA3<u, a, r, s, t>(f: a -> r -> s -> t, parser: Parser<u, a>, parser2: Parser<u, r>, parser3: Parser<u, s>) -> Parser<u, t> {
    return f <%> parser <*> parser2 <*> parser3
}
