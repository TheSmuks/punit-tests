//! Selective import: comparison assertions only.
//!
//! @pre{import PUnit.Comparison;@}
//!
//! Provides: @expr{assert_gt@}, @expr{assert_lt@},
//! @expr{assert_gte@}, @expr{assert_lte@}
//!
//! @seealso
//!   @ref{PUnit.Assertions@}

inherit .Assertions;

constant _allowed = (< "assert_gt", "assert_lt",
                       "assert_gte", "assert_lte" >);

protected mixed `[](string what) {
  if (!_allowed[what]) return UNDEFINED;
  return ::`[](what);
}

protected mixed `->(string what) { return `[](what); }

array(string) _indices() { return indices(_allowed); }
