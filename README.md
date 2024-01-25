# Brex

One billion row challenge in Elixir

The solution presented here is actually a port of an elegant<sup>1</sup> and faaaast<sup>2</sup> solution<sup>3</sup> in Go.

Disclaimer/tldr: This port did not attain to the single-digit seconds latency of the original Go solution. But adopting the techniques from it at least cut the runtime latency from the initial implementation of ~50mins down to ~11mins.

The folowing branches are the 2 solutions I came up with:
- `main` (runtime: ~11mins) where only the parsing of the valid chunks is written as a Rust NIF; 
- `transform-rs` (runtime: ~50mins) where string chunking is done partly as a Rust NIF and partly in Elixir. The Elixir part was "necessary" because Rust or at least Rust NIFs do not allow invalidly shaped strings, ie. those that end in the middle of a codepoint, to be passed as `&str` or even as `Vec<u8>`. And because this chunking does more work it ends up being a lot slower than the pure Elixir implementation.

## Instructions
1. `mix compile`
2. `mix aggregate <input_file_path>`

## Footnotes
<sup>1</sup> No esoteric techniques (eg. SIMD, unsafe implementation of hashmap, branchless code) and very readable code for a mid to a (diligent) junior level Go developer. Although knowing the precise use of fundamental stuff to create such a performant and simple code requires, of course, senior level experience.

<sup>2</sup> At the time of writing, faster than the fastest Java solution. The baseline Java implementation runs at ~6mins on a 1.1GHz 8GB Intel Mac Air, whereas this Go implementation runs at ~6sec on the same machine.

<sup>3</sup> https://gist.github.com/corlinp/176a97c58099bca36bcd5679e68f9708
