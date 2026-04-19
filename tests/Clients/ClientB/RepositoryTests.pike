//! ClientB Repository Tests — contract tests + client-specific tests.
//!
//! Demonstrates that multiple clients can independently satisfy
//! the same contract, with their own custom tests.

import PUnit;
inherit PUnit.TestCase;

constant test_tags = ([
  "test_insert_and_find": ({"client_b", "repository"}),
  "test_find_missing_returns_zero": ({"client_b", "repository"}),
  "test_delete_removes_entry": ({"client_b", "repository"}),
  "test_client_b_bulk_insert": ({"client_b"}),
]);

// Inline mock repository
class MockRepository {
  protected mapping data = ([]);
  void insert(string key, mixed value) { data[key] = value; }
  mixed find(string key) { return data[key]; }
  void delete(string key) { m_delete(data, key); }
}

// Contract tests
void test_insert_and_find() {
  object repo = MockRepository();
  repo->insert("key", ({"value"}));
  assert_equal(({"value"}), repo->find("key"));
}

void test_find_missing_returns_zero() {
  object repo = MockRepository();
  assert_true(zero_type(repo->find("nonexistent")));
}

void test_delete_removes_entry() {
  object repo = MockRepository();
  repo->insert("key", ({"value"}));
  repo->delete("key");
  assert_true(zero_type(repo->find("key")));
}

// ClientB-specific tests
void test_client_b_bulk_insert() {
  object repo = MockRepository();
  repo->insert("key1", ({"val1"}));
  repo->insert("key2", ({"val2"}));
  repo->insert("key3", ({"val3"}));
  assert_equal(({"val1"}), repo->find("key1"));
  assert_equal(({"val2"}), repo->find("key2"));
  assert_equal(({"val3"}), repo->find("key3"));
}
