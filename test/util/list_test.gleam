import gleeunit
import gleeunit/should
import util/list.{index}

pub fn main() {
  gleeunit.main()
}

pub fn index_test() {
  index(of: "a", in: ["a", "b", "c"])
  |> should.equal(Ok(0))

  index(of: "b", in: ["a", "b", "c"])
  |> should.equal(Ok(1))

  index(of: "c", in: ["a", "b", "c"])
  |> should.equal(Ok(2))

  index(of: "d", in: ["a", "b", "c"])
  |> should.equal(Error("Needle was not found in haystack"))
}
