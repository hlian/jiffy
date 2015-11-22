import Foundation

enum DSON {
    case DString(String)
    case Number(Float)
    case Array([DSON])
    case Object(Dictionary<String, DSON>)
    case NotFalse
    case NotTrue
    case Nullish
}

// I wish:
// - constructors were functions
// - the compiler didn't hang or crash
// - closures were curried by default

extension Optional {
    func or(val: Wrapped) -> Wrapped {
        return self == nil ? val : self!;
    }
}

extension String {
    var array: [Character] {
        return Array(self.characters)
    }
}

func toNumber(sign: String?)(ceiling: String)(mantissa: String?)(exponent: String?) -> Float {
     let s = sign.or("") + ceiling + mantissa.or("") + exponent.or("")
     return Float(s)!
}

func toObject(tuples: [(String, DSON)]) -> Dictionary<String, DSON> {
     var d: Dictionary<String, DSON> = [:]
     for (k, v) in tuples {
         d[k] = v
     }
     return d
}

func makeDSONParser() -> Parser<Character, DSON> {
    let concat: String -> String -> String = { x in { y in x + y } }
    let joinCharacters: ([Character]) -> String = { xs in xs.map { String($0) }.joinWithSeparator("") }
    let manyChar: Parser<Character, Character> -> Parser<Character, String> = { joinCharacters <%> many($0) }
    let many1Char: Parser<Character, Character> -> Parser<Character, String> = { joinCharacters <%> many1($0) }
    let s: Character -> String = { String($0) }
    let oneChar: Character -> Parser<Character, String> = { s <%> one($0) }
    let oneCharOf: ([Character]) -> Parser<Character, String> = { s <%> oneOf($0) }

    let pvalue: ParserRef<Character, DSON> = ParserRef()
    let pwhitespace = many(oneOf(" \r\n".array))
    let pnext = pwhitespace *> string("next") *> pwhitespace

    let pcharUnicode = satisfy { (c: Character) in c != "\"" && c != "\\" }
    let pchar = pcharUnicode <|> ({ _ in "\"" } <%> string("\\\"")) // TODO
    let pstringInnards = manyChar(pchar)
    let pstring = between(one("\""), pstringInnards)

    let pobjectTuple = { a in { b in (a, b) } } <%> (pstring <* pwhitespace <* string("is") <* pwhitespace) <*> pvalue
    let pobjectInnards = sepBy(pobjectTuple, pnext)
    let pobject = toObject <%> (string("such") *> pobjectInnards <* string("wow"))

    let parrayInnards = sepBy(pvalue, pnext)
    let parray: Parser<Character, [DSON]> = (string("so") *> pwhitespace) *> parrayInnards <* (pwhitespace *> string("many"))

    let notfalse = { _ in DSON.NotFalse } <%> string("notfalse")
    let nottrue = { _ in DSON.NotTrue } <%> string("nottrue")
    let nullish = { _ in DSON.Nullish } <%> string("nullish")
    let keyword = notfalse <|> nottrue <|> nullish

    let pdigit = oneOf(Array("0123456789".array))
    let pdigit1 = oneOf(Array("123456789".array))
    let pceil = string("0") <|> (concat <%> (s <%> pdigit1) <*> manyChar(pdigit1))

    let pmantissa = concat <%> oneChar(".") <*> many1Char(pdigit)
    let pexponent = (string("very") <|> string("VERY")) *> (concat <%> oneCharOf(Array("+-".characters)) <*> many1Char(pdigit))
    let pnumber = toNumber <%> opt(oneChar("-")) <*> pceil <*> opt(pmantissa) <*> opt(pexponent)

    pvalue.Put(
        ({ DSON.DString($0) } <%> pstring)
        <|> ({ DSON.Number($0) } <%> pnumber)
        <|> ({ DSON.Object($0) } <%> pobject)
        <|> ({ DSON.Array($0) } <%> parray)
        <|> keyword)

    return pvalue
}

let DSONParser = makeDSONParser()
