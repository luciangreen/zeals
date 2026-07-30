:- module(zeals_verify, [
    verify_candidate/4,
    verify_against_case/3,
    resolve_candidates/4,
    generated_verifier/3
]).

:- use_module(library(lists)).
:- use_module(zeals_problem).
:- use_module(zeals_util).

%! verify_candidate(+ProblemId, +Input, +Candidate, -Verification) is det.
verify_candidate(ProblemId, Input, Candidate, Verification) :-
    zeals_problem:get_problem(
        ProblemId,
        problem(_, _, _, _, Invariants, _, _)
    ),
    (   check_invariants(Invariants, Input, Candidate)
    ->  Verification = verified(evidence(invariants_passed))
    ;   Verification = failed(invariant_failed, evidence(invariants_failed))
    ).

%! verify_against_case(+Case, +Candidate, -Verification) is det.
verify_against_case(case(_, _, Input, _, ExpectedOutput, _), Candidate, Verification) :-
    verify_expected(ExpectedOutput, Input, Candidate, Verification).

verify_expected(exact(Expected), _Input, Candidate, Verification) :-
    (   Candidate == Expected
    ->  Verification = verified(evidence(exact_match))
    ;   Verification = failed(exact_mismatch, evidence(_{expected: Expected, actual: Candidate}))
    ).
verify_expected(one_of(Values), _Input, Candidate, Verification) :-
    (   memberchk(Candidate, Values)
    ->  Verification = verified(evidence(one_of_match))
    ;   Verification = failed(not_in_expected_set, evidence(_{expected_any_of: Values, actual: Candidate}))
    ).
verify_expected(satisfies(Verifier), Input, Candidate, Verification) :-
    (   call_verifier(Verifier, Input, Candidate)
    ->  Verification = verified(evidence(verifier_satisfied(Verifier)))
    ;   Verification = failed(verifier_failed, evidence(verifier(Verifier)))
    ).
verify_expected(unknown, _Input, _Candidate, unknown(no_expected_output)).
verify_expected(unsupported, _Input, _Candidate, unsupported(case_marked_unsupported)).

call_verifier(Verifier, _Input, Candidate) :-
    callable_with_args(Verifier, [Candidate]),
    !.
call_verifier(Verifier, Input, Candidate) :-
    callable_with_args(Verifier, [Input, Candidate]).

check_invariants([], _Input, _Candidate).
check_invariants([Invariant|Rest], Input, Candidate) :-
    call_invariant(Invariant, Input, Candidate),
    check_invariants(Rest, Input, Candidate).

call_invariant(Invariant, _Input, Candidate) :-
    callable_with_args(Invariant, [Candidate]),
    !.
call_invariant(Invariant, Input, Candidate) :-
    callable_with_args(Invariant, [Input, Candidate]).

resolve_candidates(_ProblemId, _Input, Candidates, Resolution) :-
    include(is_verified_candidate, Candidates, VerifiedCandidates),
    (   VerifiedCandidates = [candidate(Candidate, Evidence)|_]
    ->  Resolution = accepted(Candidate, Evidence)
    ;   Candidates = []
    ->  Resolution = unknown(no_candidates)
    ;   Resolution = contradiction(Candidates, diagnostics(no_verified_candidate))
    ).

is_verified_candidate(candidate(_Candidate, verified(_Evidence))).

generated_verifier(_Input, _Output, verified(evidence(generated_verifier))).

