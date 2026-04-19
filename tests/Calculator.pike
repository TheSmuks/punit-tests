//! Calculator — A trivial class under test, used by the example tests.

class Calculator {
  protected int|float value = 0;

  void create(void|int|float initial) {
    if (!undefinedp(initial))
      value = initial;
  }

  int|float add(int|float x) {
    value += x;
    return value;
  }

  int|float subtract(int|float x) {
    value -= x;
    return value;
  }

  int|float multiply(int|float x) {
    value *= x;
    return value;
  }

  int|float divide(int|float x) {
    if (x == 0)
      error("Division by zero\n");
    value /= x;
    return value;
  }

  int|float get_value() {
    return value;
  }

  void reset() {
    value = 0;
  }
}
