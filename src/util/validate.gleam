import gleam/option.{type Option, None, Some, or}

pub fn check(error: String, valid: Bool) -> Option(String) {
  case valid {
    False -> Some(error)
    True -> None
  }
}

pub fn and(
  previous: Option(String),
  error: String,
  validator: fn() -> Bool,
) -> Option(String) {
  or(
    previous,
    case validator() {
      False -> Some(error)
      True -> None
    },
  )
}

pub fn then(maybe_error: Option(String), action: fn() -> x) -> Result(x, String) {
  case maybe_error {
    Some(description) -> Error(description)
    None -> Ok(action())
  }
}
