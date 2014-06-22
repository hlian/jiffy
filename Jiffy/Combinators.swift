import Foundation


func satisfy<u>(pred: u -> Bool) -> Parser<u, u> {
    let f: Stream<u> -> Reply<u> = { (var stream) in
        if (pred(stream.Peek())) {
            return Reply.Error("not satisfied")
        } else {
            let c = stream.Peek()
            stream.Skip()
            return Reply.Lovely(c)
        }
    }
    return Thunk(thunk: f)
}

func many<u, a>(parser: Parser<u, a>) -> Parser<u, a[]> {
    let f: Stream<u> -> Reply<a[]> = { (var stream) in
        var results: a[] = []
        loop: while (true) {
            let r = parser.Run(stream)
            switch (r) {
            case .Lovely(let result):
                results.append(result)
            case .Error(let error):
                break loop
            }
        }
        return Reply.Lovely(results)
    }
    return Thunk(thunk: f)
}

func many1<u, a>(parser: Parser<u, a>) -> Parser<u, a[]> {
    let f: Stream<u> -> Reply<a[]> = { (var stream) in
        let r = many(parser).Run(stream)
        switch (r) {
        case .Lovely(let result):
            if result.count > 1 {
                return Reply.Lovely(result)
            } else {
                return Reply.Error("not enough")
            }
        case .Error(let error):
            return Reply.Error(error)
        }
    }
    return Thunk(thunk: f)
}

func opt<u, a>(parser: Parser<u, a>) -> Parser<u, a?> {
    let f: Stream<u> -> Reply<a?> = { (var stream) in
        let i = stream.Snapshot()
        let r = parser.Run(stream)
        switch (r) {
        case .Lovely(let result):
            return Reply.Lovely(result)
        case .Error(let error):
            stream.Rewind(i)
            return Reply.Lovely(nil)
        }
    }
    return Thunk(thunk: f)
}

func one<u: Equatable>(x: u) -> Parser<u, u> {
    let f: u -> Bool = { $0 == x }
    return satisfy(f)
}

func oneOf<u: Equatable>(xs: u[]) -> Parser<u, u> {
    return satisfy { (y: u) in
        let filtered: u[] = xs.filter { $0 == y }
        return filtered.count > 0
    }
}

func string(xs: String) -> Parser<Character, String> {
}

func sepBy<u, a, t>(parser: Parser<u, a>, separator: Parser<u, t>) -> Parser<u, a[]> {

}

func between<u, a, t>(parens: Parser<u, t>, parser: Parser<u, a>) -> Parser<u, a> {

}
