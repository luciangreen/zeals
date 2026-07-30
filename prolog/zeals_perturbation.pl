:- module(zeals_perturbation, [
    register_perturbation/1,
    register_perturbation/2,
    register_perturbations/1,
    get_perturbation/2,
    perturbation_registered/1,
    validate_perturbation/1,
    method_contract/7
]).

:- use_module(library(option)).
:- use_module(zeals_registry).
:- use_module(zeals_problem).
:- use_module(zeals_util).

register_perturbation(Perturbation) :-
    register_perturbation(Perturbation, []).

register_perturbation(Perturbation, Options) :-
    validate_perturbation(Perturbation),
    Perturbation = perturbation(PerturbationId, _ProblemId, _, _, _, MethodId, _, ContractTerm),
    option_bool(replace, Options, false, Replace),
    (   zeals_registry:put_perturbation(PerturbationId, Perturbation, Replace)
    ->  normalise_contract(MethodId, ContractTerm, MethodContract),
        zeals_registry:put_method_contract(MethodId, MethodContract)
    ;   throw_zeals_error(
            duplicate_identifier,
            _{operation: register_perturbation, id: PerturbationId},
            register_perturbation/2
        )
    ).

register_perturbations(Perturbations) :-
    maplist(register_perturbation, Perturbations).

get_perturbation(PerturbationId, Perturbation) :-
    (   zeals_registry:perturbation(PerturbationId, Perturbation)
    ->  true
    ;   throw_zeals_error(
            unknown_perturbation,
            _{operation: get_perturbation, id: PerturbationId},
            get_perturbation/2
        )
    ).

perturbation_registered(PerturbationId) :-
    zeals_registry:perturbation(PerturbationId, _).

validate_perturbation(
    perturbation(PerturbationId, ProblemId, Restrictions, Assumptions, Representation, Method, Objectives, Contract)
) :-
    must_be(atom, PerturbationId),
    must_be(atom, ProblemId),
    zeals_problem:problem_registered(ProblemId),
    is_list(Restrictions),
    is_list(Assumptions),
    nonvar(Representation),
    nonvar(Method),
    is_list(Objectives),
    validate_contract(Contract).
validate_perturbation(Other) :-
    throw_zeals_error(
        invalid_contract,
        _{reason: malformed_perturbation, value: Other},
        validate_perturbation/1
    ).

validate_contract(contract(Recogniser, Executor, Verifier)) :-
    callable(Recogniser),
    callable(Executor),
    callable(Verifier).
validate_contract(method_contract(_, Recogniser, Preconditions, Executor, Postconditions, FailureModes, Verifier)) :-
    callable(Recogniser),
    is_list(Preconditions),
    callable(Executor),
    is_list(Postconditions),
    is_list(FailureModes),
    callable(Verifier).
validate_contract(Other) :-
    throw_zeals_error(
        invalid_contract,
        _{reason: malformed_contract, value: Other},
        validate_contract/1
    ).

normalise_contract(MethodId, contract(Recogniser, Executor, Verifier),
    method_contract(MethodId, Recogniser, [], Executor, [], [unsupported], Verifier)).
normalise_contract(_MethodId, method_contract(MethodId, Recogniser, Preconditions, Executor, Postconditions, FailureModes, Verifier),
    method_contract(MethodId, Recogniser, Preconditions, Executor, Postconditions, FailureModes, Verifier)).

method_contract(MethodId, Recogniser, Preconditions, Executor, Postconditions, FailureModes, Verifier) :-
    zeals_registry:method_contract(
        MethodId,
        method_contract(MethodId, Recogniser, Preconditions, Executor, Postconditions, FailureModes, Verifier)
    ).

