:- begin_tests(verification).

:- use_module('../prolog/zeals_verify').

test(exact_verification_pass) :-
    Case = case(c1, p1, input, training, exact(5), []),
    zeals_verify:verify_against_case(Case, 5, verified(_)).

test(exact_verification_fail) :-
    Case = case(c1, p1, input, training, exact(5), []),
    zeals_verify:verify_against_case(Case, 4, failed(_, _)).

test(candidate_resolution_unknown) :-
    zeals_verify:resolve_candidates(p, input, [], unknown(no_candidates)).

:- end_tests(verification).

