:- module(test_support, [
    setup_base_registry/0,
    sample_problem/1,
    sample_cases/1,
    sample_perturbations/1,
    verify_non_negative/1
]).

:- use_module('../prolog/zeals').

setup_base_registry :-
    zeals:reset_zeals,
    sample_problem(Problem),
    zeals:register_problem(Problem),
    sample_cases(Cases),
    zeals:register_cases(Cases),
    sample_perturbations(Perturbations),
    zeals:register_perturbations(Perturbations),
    zeals:perturbation_dimension(sample_problem, method, [simple_method, guard_method]),
    zeals:perturbation_dimension(sample_problem, approximation_level, [exact, approximate]),
    zeals:incompatible_setting(sample_problem, method, simple_method, approximation_level, approximate),
    zeals:generation_limit(sample_problem, 10).

sample_problem(
    problem(
        sample_problem,
        [input_value],
        [result_value],
        [test_support:is_number_input],
        [test_support:verify_non_negative],
        [correctness],
        []
    )
).

sample_cases([
    case(case_ok, sample_problem, 2, training, exact(4), [features([size(small), parity(even)])]),
    case(case_fail, sample_problem, 3, verification, exact(6), [features([size(small), parity(odd)])]),
    case(case_unsupported, sample_problem, undefined, boundary, unsupported, [features([undefined_input(true)])])
]).

sample_perturbations([
    perturbation(
        square_solver,
        sample_problem,
        [numeric_only],
        [],
        scalar,
        simple_method,
        [exactness],
        method_contract(
            simple_method,
            test_support:is_number_input,
            [test_support:is_number_input],
            test_support:square_solver_exec,
            [],
            [unsupported],
            test_support:square_solver_verify
        )
    ),
    perturbation(
        unsupported_guard,
        sample_problem,
        [guard_only],
        [],
        scalar,
        guard_method,
        [safety],
        contract(
            test_support:always_true,
            test_support:guard_executor,
            test_support:guard_verifier
        )
    )
]).

is_number_input(Input) :-
    number(Input).

always_true(_).

square_solver_exec(Input, Output) :-
    Output is Input * Input.

square_solver_verify(Input, Output, Verification) :-
    Expected is Input * Input,
    (   Output =:= Expected
    ->  Verification = verified(evidence(square_ok))
    ;   Verification = failed(square_mismatch, evidence(_{expected: Expected, actual: Output}))
    ).

guard_executor(undefined, unsupported(undefined_input)).
guard_executor(Input, passthrough(Input)).

guard_verifier(undefined, unsupported(undefined_input), verified(evidence(undefined_guarded))).
guard_verifier(_Input, passthrough(_), verified(evidence(pass_through))).

verify_non_negative(Output) :-
    (   number(Output)
    ->  Output >= 0
    ;   true
    ).

