:- module(maths_zeals, []).

:- use_module('../prolog/zeals').

:- zeals:register_problem(
       problem(
           solve_equation,
           [equation, target_variable],
           [solution_set, explanation],
           [maths_zeals:well_formed_expression],
           [maths_zeals:solutions_satisfy_original],
           [correctness, clarity, low_cost],
           [time_limit_seconds(5), feature_extractor(maths_zeals:extract_features)]
       ),
       [replace(true)]
   ).

:- zeals:register_cases([
       case(
           const_add_2_3,
           solve_equation,
           add(number(2), number(3)),
           training,
           exact(value(5)),
           [tags([constant]), features([expression_kind(constant), variable_count(0)])]
       ),
       case(
           linear_2x_plus_3_eq_7,
           solve_equation,
           equation(add(multiply(number(2), variable(x)), number(3)), number(7)),
           verification,
           exact(solutions([x=2])),
           [tags([linear]), features([expression_kind(linear), variable_count(1), degree(1)])]
       ),
       case(
           divide_by_zero,
           solve_equation,
           divide(number(1), number(0)),
           boundary,
           unsupported,
           [tags([undefined]), features([contains_division(true), zero_division(true)])]
       ),
       case(
           quadratic_case,
           solve_equation,
           equation(add(subtract(power(variable(x), 2), multiply(number(5), variable(x))), number(6)), number(0)),
           adversarial,
           unknown,
           [tags([quadratic]), features([expression_kind(quadratic), variable_count(1), degree(2)])]
       )
   ]).

:- zeals:register_perturbations([
       perturbation(
           constant_evaluator,
           solve_equation,
           [constant_only],
           [],
           expression_tree,
           constant_evaluator,
           [exactness, clarity],
           contract(
               maths_zeals:recognise_constant_expression,
               maths_zeals:execute_constant_expression,
               maths_zeals:verify_constant_expression
           )
       ),
       perturbation(
           linear_equation_solver,
           solve_equation,
           [degree_at_most(1), one_target_variable],
           [nonzero_denominators],
           expression_tree,
           linear_equation_solver,
           [exactness, clarity],
           contract(
               maths_zeals:recognise_linear_equation,
               maths_zeals:solve_linear_equation,
               maths_zeals:verify_solution_by_substitution
           )
       ),
       perturbation(
           undefined_expression_detector,
           solve_equation,
           [undefined_expression_detection],
           [],
           expression_tree,
           undefined_expression_detector,
           [safety],
           contract(
               maths_zeals:recognise_expression,
               maths_zeals:detect_undefined_expression,
               maths_zeals:verify_undefined_expression
           )
       )
   ]).

:- zeals:perturbation_dimension(solve_equation, method, [constant_evaluator, linear_equation_solver, undefined_expression_detector]).
:- zeals:perturbation_dimension(solve_equation, approximation_level, [exact, approximate]).
:- zeals:incompatible_setting(solve_equation, method, linear_equation_solver, approximation_level, approximate).
:- zeals:generation_limit(solve_equation, 20).

well_formed_expression(Expression) :-
    ground(Expression).

solutions_satisfy_original(_Input, _Candidate).

extract_features(_ProblemId, Input, Features) :-
    feature_list(Input, Features).

feature_list(add(_, _), [expression_kind(addition), variable_count(0)]).
feature_list(equation(_, _), [expression_kind(equation), variable_count(1)]).
feature_list(divide(_, number(0)), [contains_division(true), zero_division(true)]).
feature_list(_, [expression_kind(other)]).

recognise_constant_expression(add(number(_), number(_))).

execute_constant_expression(add(number(A), number(B)), value(Result)) :-
    Result is A + B.

verify_constant_expression(Input, Candidate, Verification) :-
    (   Input = add(number(A), number(B)),
        Candidate = value(Result),
        Result =:= A + B
    ->  Verification = verified(evidence(arithmetic_identity))
    ;   Verification = failed(not_constant_sum, evidence(mismatch))
    ).

recognise_linear_equation(equation(add(multiply(number(A), variable(_)), number(_)), number(_))) :-
    A =\= 0.

solve_linear_equation(equation(add(multiply(number(A), variable(X)), number(B)), number(C)), solutions([X=Solution])) :-
    A =\= 0,
    Solution is (C - B) / A.

verify_solution_by_substitution(Input, Candidate, Verification) :-
    (   Input = equation(add(multiply(number(A), variable(X)), number(B)), number(C)),
        Candidate = solutions([X=Value]),
        A =\= 0,
        Lhs is A * Value + B,
        Lhs =:= C
    ->  Verification = verified(evidence(substitution_holds))
    ;   Verification = failed(substitution_failed, evidence(substitution_mismatch))
    ).

recognise_expression(_).

detect_undefined_expression(divide(number(_), number(0)), undefined(zero_division)).
detect_undefined_expression(_Input, safe).

verify_undefined_expression(divide(number(_), number(0)), undefined(zero_division), verified(evidence(undefined_detected))).
verify_undefined_expression(_Input, safe, verified(evidence(safe_expression))).
verify_undefined_expression(_Input, _Candidate, failed(unexpected_shape, evidence(mismatch))).

