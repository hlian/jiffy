import Foundation


// The default precedence is 100.
operator infix <%> { associativity left }
operator infix >>= { associativity left precedence 80 }
operator infix <*> { associativity left }
operator infix <* { associativity left }
operator infix *> { associativity left }
operator infix <|> { associativity left precedence 90 }
operator infix <% { associativity left }
operator infix <**> { associativity left }

// Functor
func <%><u, a, t>(f: t -> a, parser: Parser<u, t>) -> Parser<u, a> {
    let f: Stream<u> -> Reply<a> = { (var stream) in
        switch (parser.Run(stream)) {
        case .Lovely(let result):
            return Reply.Lovely(f(result))
        case .Error(let error):
            return Reply.Error(error)
        }
    }
    return Thunk(thunk: f)
}

// Applicative
func pure<u, a>(x: a) -> Parser<u, a> {
    let f: Stream<u> -> Reply<a> = { (var stream) in
        return Reply.Lovely(x)
    }
    return Thunk(thunk: f)
}

func <*><u, a, t>(parserF: Parser<u, t -> a>, parser: Parser<u, t>) -> Parser<u, a> {
    let f: Stream<u> -> Reply<a> = { (var stream) in
        switch (parserF.Run(stream)) {
        case .Lovely(let g):
            switch (parser.Run(stream)) {
            case .Lovely(let result):
                return Reply.Lovely(g(result))
            case .Error(let error):
                return Reply.Error(error)
            }
        case .Error(let error):
            return Reply.Error(error)
        }
    }
    return Thunk(thunk: f)
}

func <**><u, a, t>(parser: Parser<u, t>, parserF: Parser<u, t -> a>) -> Parser<u, a> {
    return parserF <*> parser;
}

func <*<u, a, b>(left: Parser<u, a>, right: Parser<u, b>) -> Parser<u, a> {
    return { a in { b in a } } <%> left <*> right;
}

func *><u, a, b>(left: Parser<u, a>, right: Parser<u, b>) -> Parser<u, b> {
    return { a in { b in b } } <%> left <*> right;
}

// Alternative
func <|><u, a>(left: Parser<u, a>, right: Parser<u, a>) -> Parser<u, a> {
    let f: Stream<u> -> Reply<a> = { (var stream) in
        let snapshot = stream.Snapshot()
        switch (left.Run(stream)) {
        case .Lovely(let result):
            return Reply.Lovely(result)
        case .Error(let error):
            stream.Rewind(snapshot)
            return right.Run(stream)
        }
    }
    return Thunk(thunk: f)
}

// Monad
func >>=<u, a, t>(parser: Parser<u, t>, binder: t -> Parser<u, a>) -> Parser<u, a> {
    let f: Stream<u> -> Reply<a> = { (var stream) in
        switch (parser.Run(stream)) {
        case .Lovely(let result):
            return binder(result).Run(stream)
        case .Error(let error):
            return Reply.Error(error)
        }
    }
    return Thunk(thunk: f)
}

// Utility functions
func <%<u, a, t>(x: a, left: Parser<u, t>) -> Parser<u, a> {
    return { _ in x } <%> left
}