//! Selective import: null/undefined assertions only.
//!
//! @pre{import PUnit.Null;@}
//!
//! Provides: @expr{assert_null@}, @expr{assert_not_null@},
//! @expr{assert_undefined@}
//!
//! @seealso
//!   @ref{PUnit.Assertions@}

inherit .Assertions;

constant _allowed = (< "assert_null", "assert_not_null",
                       "assert_undefined" >);

protected mixed `[](string what) {
  if (!_allowed[what]) return UNDEFINED;
  return ::`[](what);
}

protected mixed `->(string what) { return `[](what); }

array(string) _indices() { return indices(_allowed); }
