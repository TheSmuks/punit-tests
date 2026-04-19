//! DatabaseFixture — Reusable fixture example for PUnit.
//!
//! This simulates a database fixture that creates a temporary
//! "database" (really just a mapping) for tests that need it.
//!
//! Usage from test files in the same tests/ tree:
//!   inherit .Fixtures.DatabaseFixture;

import PUnit;
inherit PUnit.TestCase;

//! The "database" — a simple mapping for demo purposes.
protected mapping db;

void setup() {
  db = ([]);
}

void teardown() {
  db = 0;
}

//! Helper: insert a record into the mock DB.
void db_insert(string key, mixed value) {
  db[key] = value;
}

//! Helper: find a record in the mock DB.
mixed db_find(string key) {
  return db[key];
}

//! Helper: delete a record from the mock DB.
void db_delete(string key) {
  m_delete(db, key);
}
