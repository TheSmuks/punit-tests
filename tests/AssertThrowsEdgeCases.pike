program GenericError = Error.Generic;
program PermissionError = Error.Permission;
import PUnit;

inherit PUnit.TestCase;

void test_exact_type_match() {
    assert_throws(GenericError, lambda() { error("test"); });
}

void test_inheritance_match() {
    assert_throws(GenericError, lambda() { throw(PUnit.Error.AssertionError("inherited")); });
}

void test_mismatched_type_fails() {
    assert_throws(PUnit.Error.AssertionError, lambda() {
        assert_throws(PermissionError, lambda() {
            throw(({ GenericError("wrong type"), backtrace() }));
        });
    });
}

void test_no_throw_fails() {
    assert_throws(PUnit.Error.AssertionError, lambda() {
        assert_throws(GenericError, lambda() { });
    });
}
