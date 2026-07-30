:- module(sorting_zeals, []).

:- use_module('../prolog/zeals').

:- zeals:register_problem(
       problem(
           sort_values,
           [unsorted_list],
           [sorted_list],
           [is_list],
           [sorting_zeals:sorted_permutation_invariant],
           [correctness],
           [feature_extractor(sorting_zeals:extract_features)]
       ),
       [replace(true)]
   ).

:- zeals:register_case(
       case(
           sort_small_list,
           sort_values,
           [3,1,2],
           training,
           exact([1,2,3]),
           [features([length_class(short), contains_duplicates(false)])]
       )
   ).

:- zeals:register_perturbation(
       perturbation(
           builtin_sort,
           sort_values,
           [finite_list],
           [],
           list,
           builtin_sort,
           [exactness],
           contract(
               sorting_zeals:recognise_list,
               sorting_zeals:execute_sort,
               sorting_zeals:verify_sorted
           )
       ),
       [replace(true)]
   ).

recognise_list(Input) :-
    is_list(Input).

execute_sort(Input, Output) :-
    msort(Input, Output).

verify_sorted(Input, Output, Verification) :-
    msort(Input, Expected),
    (   Output == Expected
    ->  Verification = verified(evidence(permutation_and_order))
    ;   Verification = failed(not_sorted, evidence(_{expected: Expected, actual: Output}))
    ).

sorted_permutation_invariant(Input, Output) :-
    msort(Input, Output).

extract_features(_ProblemId, Input, Features) :-
    length(Input, Length),
    (Length =< 5 -> LengthClass = short ; LengthClass = long),
    Features = [length_class(LengthClass)].

