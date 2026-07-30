:- module(classification_zeals, []).

:- use_module('../prolog/zeals').

:- zeals:register_problem(
       problem(
           classify_parity,
           [integer_value],
           [parity_class],
           [integer],
           [classification_zeals:valid_parity_output],
           [correctness],
           []
       ),
       [replace(true)]
   ).

:- zeals:register_case(
       case(
           parity_two,
           classify_parity,
           2,
           training,
           exact(even),
           [features([parity(even)])]
       )
   ).

:- zeals:register_perturbation(
       perturbation(
           modulo_classifier,
           classify_parity,
           [integer_domain],
           [],
           scalar,
           modulo_classifier,
           [exactness],
           contract(
               classification_zeals:recognise_integer,
               classification_zeals:classify_with_modulo,
               classification_zeals:verify_parity
           )
       ),
       [replace(true)]
   ).

recognise_integer(Input) :-
    integer(Input).

classify_with_modulo(Input, even) :-
    0 is Input mod 2,
    !.
classify_with_modulo(_Input, odd).

verify_parity(Input, Candidate, Verification) :-
    (   0 is Input mod 2
    ->  Expected = even
    ;   Expected = odd
    ),
    (   Candidate == Expected
    ->  Verification = verified(evidence(modulo_check))
    ;   Verification = failed(parity_mismatch, evidence(_{expected: Expected, actual: Candidate}))
    ).

valid_parity_output(_Input, Candidate) :-
    memberchk(Candidate, [even, odd]).

