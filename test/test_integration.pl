:- begin_tests(integration).

:- use_module('../prolog/zeals').

test(full_workflow_maths_example) :-
    zeals:zeals_load('examples/maths_zeals.pl'),
    zeals:zeals_generate(solve_equation),
    zeals:zeals_execute(solve_equation),
    zeals:zeals_profile(solve_equation),
    zeals:zeals_boundaries(solve_equation),
    zeals:zeals_synthesise(solve_equation),
    zeals:zeals_emit(solve_equation, 'test/generated_maths_expert.pl'),
    zeals:zeals_report(solve_equation, 'test/zeals_report.md'),
    consult('test/generated_maths_expert.pl'),
    expert_solve(
        equation(add(multiply(number(2), variable(x)), number(3)), number(7)),
        _Result,
        _Explanation
    ).

:- end_tests(integration).

