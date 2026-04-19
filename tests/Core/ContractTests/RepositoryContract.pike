//! RepositoryContract — Abstract contract test for repository implementations.
//!
//! Defines the contract all repository implementations must satisfy.
//! This file will NOT be run directly because create_repository() throws.
//! Client test classes copy the contract methods and provide a concrete factory.
//!
//! In a project with proper module paths, you would inherit this class
//! and override create_repository().

import PUnit;
inherit PUnit.TestCase;

// Mark this as abstract — the runner skips classes with skip_all = 1.
// Client test classes inherit the contract tests and override create_repository().
constant skip_all = 1;

// Subclasses MUST override to provide their concrete repository.
object create_repository() {
  error("Abstract: subclasses must implement create_repository()\n");
}

// --- Contract tests ---

void test_insert_and_find() {
  object repo = create_repository();
  repo->insert("key", ({"value"}));
  assert_equal(({"value"}), repo->find("key"));
}

void test_find_missing_returns_zero() {
  object repo = create_repository();
  assert_true(zero_type(repo->find("nonexistent")));
}

void test_delete_removes_entry() {
  object repo = create_repository();
  repo->insert("key", ({"value"}));
  repo->delete("key");
  assert_true(zero_type(repo->find("key")));
}

// --- Mock repository for concrete subclasses to use ---
class MockRepository {
  protected mapping data = ([]);

  void insert(string key, mixed value) {
    data[key] = value;
  }

  mixed find(string key) {
    return data[key];
  }

  void delete(string key) {
    m_delete(data, key);
  }
}
