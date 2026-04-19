//! Core Repository Tests — demonstrates tag filtering and fixture reuse.
//!
//! Self-contained with inline mock DB to avoid cross-file relative
//! module path issues under compile_string. In a real project with
//! proper module paths configured, you would inherit a shared fixture.

import PUnit;
inherit PUnit.TestCase;

protected mapping db;

constant test_tags = ([
  "test_insert_and_find": ({"core", "repository"}),
  "test_delete_removes_entry": ({"core", "repository"}),
  "test_find_missing": ({"core", "repository"}),
  "test_update_entry": ({"core"}),
]);

void setup() {
  db = ([]);
}

void teardown() {
  db = 0;
}

void db_insert(string key, mixed value) {
  db[key] = value;
}

mixed db_find(string key) {
  return db[key];
}

void db_delete(string key) {
  m_delete(db, key);
}

void test_insert_and_find() {
  db_insert("key1", ({"value1"}));
  assert_equal(({"value1"}), db_find("key1"));
}

void test_delete_removes_entry() {
  db_insert("key1", ({"value1"}));
  db_delete("key1");
  assert_true(zero_type(db_find("key1")));
}

void test_find_missing() {
  assert_true(zero_type(db_find("nonexistent")));
}

void test_update_entry() {
  db_insert("key1", ({"old"}));
  db_insert("key1", ({"new"}));
  assert_equal(({"new"}), db_find("key1"));
}
