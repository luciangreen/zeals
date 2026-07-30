:- module(zeals_problem, [
    register_problem/1,
    register_problem/2,
    unregister_problem/1,
    problem_registered/1,
    get_problem/2,
    validate_problem/1,
    normalise_problem/2
]).

:- use_module(library(option)).
:- use_module(zeals_registry).
:- use_module(zeals_util).

%! register_problem(+Problem) is det.
register_problem(Problem) :-
    register_problem(Problem, []).

%! register_problem(+Problem, +Options) is det.
register_problem(Problem, Options) :-
    normalise_problem(Problem, Normalised),
    validate_problem(Normalised),
    Normalised = problem(ProblemId, _, _, _, _, _, Constraints),
    option_bool(replace, Options, false, Replace),
    (   zeals_registry:put_problem(ProblemId, Normalised, Replace)
    ->  maybe_register_feature_extractor(ProblemId, Constraints)
    ;   throw_zeals_error(
            duplicate_identifier,
            _{operation: register_problem, id: ProblemId},
            register_problem/2
        )
    ).

unregister_problem(ProblemId) :-
    zeals_registry:remove_problem(ProblemId).

problem_registered(ProblemId) :-
    zeals_registry:problem(ProblemId, _).

get_problem(ProblemId, Problem) :-
    (   zeals_registry:problem(ProblemId, Problem)
    ->  true
    ;   throw_zeals_error(
            unknown_problem,
            _{operation: get_problem, id: ProblemId},
            get_problem/2
        )
    ).

validate_problem(problem(ProblemId, Inputs, Outputs, Preconditions, Invariants, Objectives, Constraints)) :-
    must_be(atom, ProblemId),
    maplist(must_be(atom), Inputs),
    maplist(must_be(atom), Outputs),
    is_list(Preconditions),
    is_list(Invariants),
    is_list(Objectives),
    is_list(Constraints),
    (   Invariants == []
    ->  throw_zeals_error(
            invalid_problem,
            _{id: ProblemId, field: invariants, reason: empty},
            validate_problem/1
        )
    ;   true
    ).
validate_problem(Other) :-
    throw_zeals_error(
        invalid_problem,
        _{reason: malformed_term, value: Other},
        validate_problem/1
    ).

normalise_problem(problem(Id, Inputs, Outputs, Preconditions, Invariants, Objectives, Constraints),
    problem(Id, InputsList, OutputsList, PreconditionsList, InvariantsList, ObjectivesList, ConstraintsList)) :-
    ensure_list(Inputs, InputsList),
    ensure_list(Outputs, OutputsList),
    ensure_list(Preconditions, PreconditionsList),
    ensure_list(Invariants, InvariantsList),
    ensure_list(Objectives, ObjectivesList),
    ensure_list(Constraints, ConstraintsList).
normalise_problem(ProblemDict, Problem) :-
    is_dict(ProblemDict),
    dict_get_or_default(ProblemDict, id, unknown_problem, Id),
    dict_get_or_default(ProblemDict, inputs, [], Inputs),
    dict_get_or_default(ProblemDict, outputs, [], Outputs),
    dict_get_or_default(ProblemDict, preconditions, [], Preconditions),
    dict_get_or_default(ProblemDict, invariants, [], Invariants),
    dict_get_or_default(ProblemDict, objectives, [], Objectives),
    dict_get_or_default(ProblemDict, constraints, [], Constraints),
    normalise_problem(
        problem(Id, Inputs, Outputs, Preconditions, Invariants, Objectives, Constraints),
        Problem
    ).

dict_get_or_default(Dict, Key, Default, Value) :-
    (   get_dict(Key, Dict, Value)
    ->  true
    ;   Value = Default
    ).

maybe_register_feature_extractor(ProblemId, Constraints) :-
    (   member(feature_extractor(FeatureExtractor), Constraints)
    ->  zeals_registry:set_feature_extractor(ProblemId, FeatureExtractor)
    ;   true
    ).

