import Foundation


func satisfy<u>(pred: u -> Bool) -> Parser<u, u> {

}

func many<u, a>(parser: Parser<u, a>) -> Parser<u, a[]> {

}

func many1<u, a>(parser: Parser<u, a>) -> Parser<u, a[]> {

}

func opt<u, a>(parser: Parser<u, a>) -> Parser<u, a?> {

}

func one<u: Equatable>(x: u) -> Parser<u, u> {
    return satisfy { $0 == x }
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
