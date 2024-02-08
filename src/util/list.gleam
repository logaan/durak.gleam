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
