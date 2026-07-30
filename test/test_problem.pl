:- begin_tests(problem).

:- use_module('../prolog/zeals').
:- use_module(test_support).

test(valid_problem_registration) :-
    zeals:reset_zeals,
    test_support:sample_problem(Problem),
    zeals:register_problem(Problem),
    zeals:zeals_problems([sample_problem]).

test(duplicate_problem_rejected, [throws(error(zeals_error(duplicate_identifier, _), _))]) :-
    zeals:reset_zeals,
    test_support:sample_problem(Problem),
    zeals:register_problem(Problem),
    zeals:register_problem(Problem).

test(problem_replace_option) :-
    zeals:reset_zeals,
    test_support:sample_problem(Problem),
    zeals:register_problem(Problem),
    zeals:register_problem(Problem, [replace(true)]).

test(missing_invariants_rejected, [throws(error(zeals_error(invalid_problem, _), _))]) :-
    zeals:reset_zeals,
    zeals:register_problem(problem(bad_problem, [x], [y], [], [], [], [])).

:- end_tests(problem).

