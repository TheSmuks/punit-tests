//! ClientA Repository Tests — contract tests + client-specific tests.
//!
//! Demonstrates the contract test pattern: the abstract contract
//! methods are replicated and run against a concrete implementation.
//! In a project with module paths, you would inherit RepositoryContract
//! and override create_repository().

import PUnit;
inherit PUnit.TestCase;

constant test_tags = ([
  "test_insert_and_find": ({"client_a", "repository"}),
  "test_find_missing_returns_zero": ({"client_a", "repository"}),
  "test_delete_removes_entry": ({"client_a", "repository"}),
  "test_client_a_custom_feature": ({"client_a"}),
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

// ClientA-specific tests
void test_client_a_custom_feature() {
  object repo = MockRepository();
  repo->insert("client_a_key", ({"special"}));
  assert_equal(({"special"}), repo->find("client_a_key"));
}
