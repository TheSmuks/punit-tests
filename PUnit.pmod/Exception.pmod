//! Selective import: exception assertions only.
//!
//! @pre{import PUnit.Exception;@}
//!
//! Provides: @expr{assert_throws@}, @expr{assert_throws_fn@},
//! @expr{assert_no_throw@}, @expr{assert_throws_message@}
//!
//! @seealso
//!   @ref{PUnit.Assertions@}

inherit .Assertions;

constant _allowed = (< "assert_throws", "assert_throws_fn",
                       "assert_no_throw", "assert_throws_message" >);

protected mixed `[](string what) {
  if (!_allowed[what]) return UNDEFINED;
  return ::`[](what);
}

protected mixed `->(string what) { return `[](what); }

array(string) _indices() { return indices(_allowed); }
