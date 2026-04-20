//! Discovery tests — verify test class compilation and discovery patterns.

import PUnit;

void test_compile_simple_class() {
  // Verify that a simple test class compiles and has test methods
  string code = ""
    "import PUnit;\n"
    "void test_example() { assert_true(1); }\n";
  program pgm = compile_string(code, "DynamicTest.pike");
  assert_not_null(pgm);
  object instance = pgm();
  assert_true(functionp(instance->test_example));
}

void test_class_with_skip_all() {
  // Classes with skip_all = 1 should still compile but be skippable
  string code = ""
    "import PUnit;\n"
    "constant skip_all = 1;\n"
    "void test_example() { assert_true(1); }\n";
  program pgm = compile_string(code, "SkipAllTest.pike");
  object instance = pgm();
  assert_equal(instance->skip_all, 1);
}

void test_class_with_parameterized() {
  // Verify parameterized test_data works
  string code = ""
    "import PUnit;\n"
    "constant test_data = ([ \n"
    "  \"test_add\": ({ ([\"a\": 1, \"b\": 2, \"expected\": 3]) })\n"
    "]);\n"
    "void test_add(mapping row) { assert_equal(row->expected, row->a + row->b); }\n";
  program pgm = compile_string(code, "ParamTest.pike");
  object instance = pgm();
  assert_true(mappingp(instance->test_data));
  assert_true(functionp(instance->test_add));
}

void test_class_with_tags() {
  // Verify tag declarations compile
  string code = ""
    "import PUnit;\n"
    "constant test_tags = ([ \"test_x\": ({\"unit\"}) ]);\n"
    "void test_x() { assert_true(1); }\n";
  program pgm = compile_string(code, "TaggedTest.pike");
  object instance = pgm();
  assert_true(mappingp(instance->test_tags));
  assert_equal(instance->test_tags["test_x"][0], "unit");
}

void test_multiple_classes_pattern() {
  // Pike allows multiple classes in a file via compile_string
  // Verify we can compile a class and inspect its methods
  string code = ""
    "import PUnit;\n"
    "void test_alpha() { assert_true(1); }\n"
    "void test_beta() { assert_true(1); }\n";
  program pgm = compile_string(code, "MultiTest.pike");
  object instance = pgm();
  array(string) methods = sort(indices(instance));
  assert_true(has_value(methods, "test_alpha"));
  assert_true(has_value(methods, "test_beta"));
}

void test_class_with_lifecycle() {
  // Verify setup/teardown are callable
  string code = ""
    "import PUnit;\n"
    "inherit PUnit.TestCase;\n"
    "int counter = 0;\n"
    "void setup() { counter = 42; }\n"
    "void teardown() { counter = 0; }\n"
    "void test_counter() { assert_equal(42, counter); }\n";
  program pgm = compile_string(code, "LifecycleTest.pike");
  object instance = pgm();
  instance->setup();
  assert_equal(instance->counter, 42);
  instance->teardown();
  assert_equal(instance->counter, 0);
}
