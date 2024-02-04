fn count_index(of needle: a, in haystack: List(a), having seen: Int) {
  case haystack {
    [] -> Error("Needle was not found in haystack")
    [head, ..] if head == needle -> Ok(seen)
    [_, ..tail] -> count_index(of: needle, in: tail, having: seen + 1)
  }
}

pub fn index(of needle: a, in haystack: List(a)) {
  count_index(0, of: needle, in: haystack)
}

pub fn test() {
  let assert Ok(0) = index(of: "a", in: ["a", "b", "c"])
  let assert Ok(1) = index(of: "b", in: ["a", "b", "c"])
  let assert Ok(2) = index(of: "c", in: ["a", "b", "c"])
  let assert Error(_) = index(of: "d", in: ["a", "b", "c"])
}
