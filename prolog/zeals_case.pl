:- module(zeals_case, [
    register_case/1,
    register_cases/1,
    get_case/2,
    cases_for_problem/2,
    validate_case/1
]).

:- use_module(zeals_problem).
:- use_module(zeals_registry).
:- use_module(zeals_util).

register_case(Case) :-
    validate_case(Case),
    Case = case(CaseId, _, _, _, _, _),
    zeals_registry:put_case(CaseId, Case).

register_cases(Cases) :-
    maplist(register_case, Cases).

get_case(CaseId, Case) :-
    (   zeals_registry:case(CaseId, Case)
    ->  true
    ;   throw_zeals_error(
            unknown_case,
            _{operation: get_case, id: CaseId},
            get_case/2
        )
    ).

cases_for_problem(ProblemId, Cases) :-
    zeals_problem:get_problem(ProblemId, _),
    zeals_registry:case_ids_for_problem(ProblemId, CaseIds),
    maplist(get_case, CaseIds, Cases).

validate_case(case(CaseId, ProblemId, _Input, ExpectedClass, ExpectedOutput, Metadata)) :-
    must_be(atom, CaseId),
    must_be(atom, ProblemId),
    zeals_problem:problem_registered(ProblemId),
    validate_expected_class(ExpectedClass),
    validate_expected_output(ExpectedOutput),
    is_list(Metadata).
validate_case(Other) :-
    throw_zeals_error(
        invalid_case,
        _{reason: malformed_term, value: Other},
        validate_case/1
    ).

validate_expected_class(ExpectedClass) :-
    memberchk(ExpectedClass, [training, verification, boundary, adversarial, regression]).

validate_expected_output(exact(_)).
validate_expected_output(one_of(Values)) :-
    is_list(Values).
validate_expected_output(satisfies(Verifier)) :-
    callable(Verifier).
validate_expected_output(unknown).
validate_expected_output(unsupported).

