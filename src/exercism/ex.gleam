import gleam/result

// Sometimes experiments can fail due to a one-off mistake, so if an experiment fails Daphne wants to retry it again to see if it works the second time.

// Define the with_retry function that takes a result returning function as an argument.

// If the function returns an Ok value then with_retry should return that value.

// If the function returns an Error value then with_retry should call the function again and return the result of that call.

pub fn with_retry(experiment: fn() -> Result(t, e)) -> Result(t, e) {
  case experiment() {
    Ok(t) -> Ok(t)
    Error(_) -> with_retry(experiment)
  }
}

// Define the record_timing function that takes two arguments:

// A time logging function which takes no arguments and returns Nil.
// An experiment function which takes no arguments and returns a result.
// record_timing should call the time logging function, then call the experiment function, then call the time logging function again, and finally return the result of the experiment function.

// Daphne will use the function like this:
pub fn record_timing(
  time_logger: fn() -> Nil,
  experiment: fn() -> Result(t, e),
) -> Result(t, e) {
  time_logger()
  use <- with_retry
  time_logger()
}

pub fn run_experiment(
  name: String,
  setup: fn() -> Result(t, e),
  action: fn(t) -> Result(u, e),
  record: fn(t, u) -> Result(v, e),
) -> Result(#(String, v), e) {
  todo
}
