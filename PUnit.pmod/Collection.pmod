//! Selective import: collection assertions only.
//!
//! @pre{import PUnit.Collection;@}
//!
//! Provides: @expr{assert_each@}, @expr{assert_contains_only@},
//! @expr{assert_has_size@}
//!
//! @seealso
//!   @ref{PUnit.Assertions@}

inherit .Assertions;

constant _allowed = (< "assert_each", "assert_contains_only",
                       "assert_has_size" >);

protected mixed `[](string what) {
  if (!_allowed[what]) return UNDEFINED;
  return ::`[](what);
}

protected mixed `->(string what) { return `[](what); }

array(string) _indices() { return indices(_allowed); }
