"""
--- Day 7: Handy Haversacks ---

You land at the regional airport in time for your next flight. In fact, it looks like 
you'll even have time to grab some food: all flights are currently delayed due 
to issues in luggage processing.

Due to recent aviation regulations, many rules (your puzzle input) are being 
enforced about bags and their contents; bags must be color-coded and must 
contain specific quantities of other color-coded bags. Apparently, nobody 
responsible for these regulations considered how long they would take to 
enforce!

For example, consider the following rules:

light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.

These rules specify the required contents for 9 bag types. In this example, 
every faded blue bag is empty, every vibrant plum bag contains 11 bags (5 
faded blue and 6 dotted black), and so on.

You have a shiny gold bag. If you wanted to carry it in at least one other bag, 
how many different bag colors would be valid for the outermost bag? (In other 
words: how many colors can, eventually, contain at least one shiny gold bag?)

In the above rules, the following options would be available to you:

    A bright white bag, which can hold your shiny gold bag directly.
    A muted yellow bag, which can hold your shiny gold bag directly, plus some 
    other bags.
    A dark orange bag, which can hold bright white and muted yellow bags, either 
    of which could then hold your shiny gold bag.
    A light red bag, which can hold bright white and muted yellow bags, either 
    of which could then hold your shiny gold bag.

So, in this example, the number of bag colors that can eventually contain at 
least one shiny gold bag is 4.

How many bag colors can eventually contain at least one shiny gold bag? (The
list of rules is quite long; make sure you get all of it.)
"""
using Test

function atleastoneshinygoldbag()::Int
    blob = strip(read("./Day7/input.txt", String))
    rules = split(blob, "\n")
    mappings = DefaultDict{String, Set{String}}(Set{String})
    for rule in rules
        inner, outers = parserule(convert(String, rule))
        # wrong way!
        # for o in outers
        #     push!(mappings[inner], o)
        # end
        for o in outers
            push!(mappings[o], inner)
        end
    end
    result = Set{String}()
    findgold!(mappings, result, "shiny gold")
    return length(result)
end

function findgold!(mappings::DefaultDict{String, Set{String}}, colours::Set{String}, key::String)
    if !haskey(mappings, key)
        return
    end
    for value in mappings[key]
        if value in colours
            continue
        end
        println(value)
        push!(colours, value)
        findgold!(mappings, colours, value)
    end
end
using DataStructures

function parserule(rule::String)::Tuple{String, Vector{String}}
    parts = split(rule, " contain ")
    outer = parts[:1]
    m = match(r"(\w+ \w+) bags", outer)
    outer_color = m[:1]
    inner_rules_string = parts[:2]
    # inner_rules = split(inners, ", ")
    # matches = collect([match(r"\d+ \w+ (\w+) bag", ir) for ir in inner_rules])
    matches = collect(eachmatch(r"\d+ (\w+ \w+) bag", inner_rules_string))
    inner_colours = unique(convert(String, m[:1]) for m in matches)
    return (outer_color, inner_colours)
end

"""
--- Part Two ---

It's getting pretty expensive to fly these days - not because of ticket prices, 
but because of the ridiculous number of bags you need to buy!

Consider again your shiny gold bag and the rules from the above example:

    faded blue bags contain 0 other bags.
    dotted black bags contain 0 other bags.
    vibrant plum bags contain 11 other bags: 5 faded blue bags and 6 dotted 
    black bags.
    dark olive bags contain 7 other bags: 3 faded blue bags and 4 dotted black 
    bags.

So, a single shiny gold bag must contain 1 dark olive bag (and the 7 bags 
within it) plus 2 vibrant plum bags (and the 11 bags within each of those): 
1 + 1*7 + 2 + 2*11 = 32 bags!

Of course, the actual rules have a small chance of going several levels deeper 
than this example; be sure to count all of the bags, even if the nesting 
becomes topologically impractical!

Here's another example:

shiny gold bags contain 2 dark red bags.
dark red bags contain 2 dark orange bags.
dark orange bags contain 2 dark yellow bags.
dark yellow bags contain 2 dark green bags.
dark green bags contain 2 dark blue bags.
dark blue bags contain 2 dark violet bags.
dark violet bags contain no other bags.

In this example, a single shiny gold bag must contain 126 other bags.

How many individual bags are required inside your single shiny gold bag?

"""


function countbags(filepath::String)::Int
    blob = strip(read(filepath, String))
    rules = split(blob, "\n")
    mappings = DefaultDict{String, Vector{Tuple{Int, String}}}(Vector{Tuple{Int, String}})
    for rule in rules
        inner, outers = parserule(convert(String, rule))
        for o in outers
            push!(mappings[inner], o)
        end
    end
    result = Set{String}()
    return countbags(mappings, result, "shiny gold")
end

function parserule(rule::String)::Tuple{String, Vector{Tuple{Int, String}}}
    parts = split(rule, " contain ")
    outer = parts[:1]
    outer_match = match(r"(\w+ \w+) bags", outer)
    outer_color = outer_match[:1]
    inner_rules_string = parts[:2]
    matches = collect(eachmatch(r"(\d+) (\w+ \w+) bag", inner_rules_string))
    inner_colours = [(parse(Int, m[:1]), convert(String, m[:2])) for m in matches]
    return (outer_color, inner_colours)
end

function countbags(mappings::DefaultDict{String, Vector{Tuple{Int, String}}}, colours::Set{String}, key::String)::Int
    if length(mappings[key]) == 0
        println("1 $key")
        return 0
    end
    total = 0
    println("$key - start")
    for (count, colour) in mappings[key]
        println("$count $colour")
        total += count
        total += count * sum(countbags(mappings, colours, colour))
    end
    println("$key - total - $total")
    println("$key - end")
    return total
end

@test countbags("./Day7/test-input-1.txt") == 32
@test countbags("./Day7/test-input-2.txt") == 126