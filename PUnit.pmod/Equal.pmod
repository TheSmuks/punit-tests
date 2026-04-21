//! Selective import: equality assertions only.
//!
//! @pre{import PUnit.Equal;@}
//!
//! Provides: @expr{assert_equal@}, @expr{assert_not_equal@},
//! @expr{assert_same@}, @expr{assert_not_same@}
//!
//! @seealso
//!   @ref{PUnit.Assertions@}

inherit .Assertions;

constant _allowed = (< "assert_equal", "assert_not_equal",
                       "assert_same", "assert_not_same" >);

protected mixed `[](string what) {
  if (!_allowed[what]) return UNDEFINED;
  return ::`[](what);
}

protected mixed `->(string what) { return `[](what); }

protected array(string) _indices() { return indices(_allowed); }
