# Brex

One billion row challenge in Elixir

The solution presented here is actually a port of an elegant and faaaast<sup>1</sup> solution<sup>2</sup> in Go.

Disclaimer/tldr: This port did not attain to the single-digit seconds latency of the original Go solution. But adopting the techniques from it at least cut the runtime latency from the initial implementation of ~50mins down to ~11mins.

The folowing branches are the 2 solutions I came up with:
- `main` (runtime: ~11mins) where only the parsing of the valid chunks is written as a Rust NIF; 
- `transform-rs` (runtime: ~50mins) where string chunking is done partly as a Rust NIF and partly in Elixir. The Elixir part was "necessary" because Rust or at least Rust NIFs do not allow invalidly shaped strings, ie. those that end in the middle of a codepoint, to be passed as `&str` or even as `Vec<u8>`. And because this chunking does more work it ends up being a lot slower than the pure Elixir implementation.

<sup>1</sup> At the time of writing, faster than the fastest Java solution. The baseline Java implementation runs at ~6mins on a 1.1GHz 8GB Intel Mac Air, whereas this Go implementation runs at ~6sec on the same machine.
<sup>2</sup> https://gist.github.com/corlinp/176a97c58099bca36bcd5679e68f9708
