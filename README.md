# ?

Jiffy is a parser-combinator library written in Swift, heavily inspired by [FParsec](http://www.quanttec.com/fparsec/), which in turn originates from [Parsec](http://legacy.cs.uu.nl/daan/parsec.html). 

Included is a work-in-progress parser for the [Doge Serialized Object Notation](http://dogeon.org/), the premier textual data representation of our time.

# Parser combinators?

Are fantastic, and you can read all about them here: ["Dive into parser combinators"](http://blog.fogcreek.com/fparsec/). Whoever wrote that must be a pretty OK dude. Gist: you can quickly and easily write composable, readable parsers for complicated grammars. Here, for example, is a parser for floating-point numbers:

    let pdigit = oneOf(Array("0123456789"))
    let pdigit1 = oneOf(Array("123456789"))
    let pceil = string("0") <|> (concat <%> (s <%> pdigit1) <*> manyChar(pdigit1))
    let pmantissa = concat <%> oneChar(".") <*> many1Char(pdigit)
    let pexponent = (string("very") <|> string("VERY")) *> (concat <%> oneCharOf(Array("+-")) <*> many1Char(pdigit))
    let pnumber = toNumber <%> opt(oneChar("-")) <*> pceil <*> opt(pmantissa) <*> opt(pexponent)
    
(If IEEE were to replace the `e` keyword with the DOGE `very` -- and I think we can all agree they should.)

# Swift?

[Swift](http://haskell.org/) is a new language with a compiler that crashes and hangs a lot.
Generics and typeclasses I mean protocols are ideal for something like parser combinators, don't you think? Having custom operators doesn't hurt either.

If you're coming from Haskell or F#, there's one slight change you should be aware of: `<$>` isn't a valid operator name in Swift, so I went with `<%>` instead. Mnemonic: they're right next to each other!

Yours,
Hao.
