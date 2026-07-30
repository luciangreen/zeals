:- module(zeals_generate, [
    perturbation_dimension/3,
    generation_limit/2,
    compatible_setting/5,
    incompatible_setting/5,
    required_setting/5,
    generate_perturbations/2,
    generate_perturbations/3,
    estimate_perturbation_count/2
]).

:- use_module(library(option)).
:- use_module(library(lists)).
:- use_module(zeals_registry, [
    get_dimensions/2,
    set_dimensions/3,
    add_setting_rule/7,
    setting_rules/3,
    set_generation_limit/2
]).
:- use_module(zeals_perturbation).
:- use_module(zeals_problem).
:- use_module(zeals_util).

perturbation_dimension(ProblemId, Dimension, Values) :-
    zeals_problem:get_problem(ProblemId, _),
    must_be(atom, Dimension),
    is_list(Values),
    (   zeals_registry:get_dimensions(ProblemId, Existing)
    ->  exclude(has_dimension(Dimension), Existing, Kept),
        NewDimensions = [dimension(Dimension, Values)|Kept]
    ;   NewDimensions = [dimension(Dimension, Values)]
    ),
    zeals_registry:set_dimensions(ProblemId, NewDimensions, true).

generation_limit(ProblemId, MaxPerturbations) :-
    zeals_registry:set_generation_limit(ProblemId, MaxPerturbations).

compatible_setting(ProblemId, DimensionA, ValueA, DimensionB, ValueB) :-
    zeals_registry:add_setting_rule(
        ProblemId,
        compatible,
        DimensionA,
        ValueA,
        DimensionB,
        ValueB,
        false
    ).

incompatible_setting(ProblemId, DimensionA, ValueA, DimensionB, ValueB) :-
    zeals_registry:add_setting_rule(
        ProblemId,
        incompatible,
        DimensionA,
        ValueA,
        DimensionB,
        ValueB,
        false
    ).

required_setting(ProblemId, DimensionA, ValueA, DimensionB, ValueB) :-
    zeals_registry:add_setting_rule(
        ProblemId,
        required,
        DimensionA,
        ValueA,
        DimensionB,
        ValueB,
        false
    ).

generate_perturbations(ProblemId, Perturbations) :-
    generate_perturbations(ProblemId, [], Perturbations).

generate_perturbations(ProblemId, Options, Perturbations) :-
    zeals_problem:get_problem(ProblemId, _),
    gather_dimensions(ProblemId, Options, Dimensions),
    combinations(Dimensions, RawSettings),
    include(valid_setting(ProblemId), RawSettings, CompatibleSettings),
    exclude(excluded_setting(Options), CompatibleSettings, IncludedSettings),
    option(max_count(MaxCountOpt), Options, unbounded),
    enforce_limit(ProblemId, MaxCountOpt, IncludedSettings, LimitedSettings),
    make_generated_perturbations(ProblemId, LimitedSettings, Generated),
    maplist(register_generated_perturbation, Generated),
    Perturbations = Generated.

estimate_perturbation_count(ProblemId, Count) :-
    gather_dimensions(ProblemId, [], Dimensions),
    combinations(Dimensions, Settings),
    include(valid_setting(ProblemId), Settings, Compatible),
    length(Compatible, Count).

has_dimension(Dimension, dimension(Dimension, _)).

gather_dimensions(ProblemId, Options, Selected) :-
    (   zeals_registry:get_dimensions(ProblemId, Dimensions)
    ->  true
    ;   Dimensions = []
    ),
    option(include_dimensions(IncludeDimensions), Options, all),
    (   IncludeDimensions == all
    ->  Selected = Dimensions
    ;   include(keep_included(IncludeDimensions), Dimensions, Selected)
    ).

keep_included(IncludeDimensions, dimension(Dimension, _)) :-
    memberchk(Dimension, IncludeDimensions).

combinations([], [[]]).
combinations([dimension(Dimension, Values)|Rest], Combinations) :-
    combinations(Rest, RestCombinations),
    findall(
        [setting(Dimension, Value)|Tail],
        (member(Value, Values), member(Tail, RestCombinations)),
        Combinations
    ).

valid_setting(ProblemId, Settings) :-
    zeals_registry:setting_rules(ProblemId, incompatible, Incompatible),
    zeals_registry:setting_rules(ProblemId, required, Required),
    \+ violates_incompatible(Settings, Incompatible),
    satisfies_required(Settings, Required).

violates_incompatible(Settings, Rules) :-
    member(rule(DimensionA, ValueA, DimensionB, ValueB), Rules),
    memberchk(setting(DimensionA, ValueA), Settings),
    memberchk(setting(DimensionB, ValueB), Settings).

satisfies_required(_Settings, []).
satisfies_required(Settings, [rule(DimensionA, ValueA, DimensionB, ValueB)|Rest]) :-
    (   memberchk(setting(DimensionA, ValueA), Settings)
    ->  memberchk(setting(DimensionB, ValueB), Settings)
    ;   true
    ),
    satisfies_required(Settings, Rest).

excluded_setting(Options, Settings) :-
    option(exclude_settings(Excluded), Options, []),
    member(Item, Excluded),
    Item =.. [Dimension, Value],
    memberchk(setting(Dimension, Value), Settings).

enforce_limit(ProblemId, MaxCountOpt, Settings, Limited) :-
    (   MaxCountOpt == unbounded
    ->  max_for_problem(ProblemId, MaxCount)
    ;   MaxCount = MaxCountOpt
    ),
    length(Settings, Count),
    (   MaxCount == unbounded
    ->  Limited = Settings
    ;   Count =< MaxCount
    ->  Limited = Settings
    ;   throw_zeals_error(
            generation_limit_exceeded,
            _{problem: ProblemId, estimated_count: Count, max_count: MaxCount},
            generate_perturbations/3
        )
    ).

max_for_problem(ProblemId, MaxCount) :-
    (   zeals_registry:generation_limit(ProblemId, MaxCount0)
    ->  MaxCount = MaxCount0
    ;   MaxCount = unbounded
    ).

make_generated_perturbations(ProblemId, SettingsList, Perturbations) :-
    findall(
        perturbation(
            PerturbationId,
            ProblemId,
            [generated_from_dimensions],
            [],
            settings(Settings),
            MethodId,
            [clarity],
            contract(
                zeals_execute:recogniser_always,
                zeals_execute:generated_executor(Settings),
                zeals_verify:generated_verifier
            )
        ),
        (
            nth1(Index, SettingsList, Settings),
            atomic_list_concat(['generated', ProblemId, Index], '_', PerturbationId),
            method_id_from_settings(Settings, MethodId)
        ),
        Perturbations
    ).

method_id_from_settings(Settings, MethodId) :-
    (   memberchk(setting(method, MethodId), Settings)
    ->  true
    ;   MethodId = generated_method
    ).

register_generated_perturbation(Perturbation) :-
    zeals_perturbation:register_perturbation(Perturbation, [replace(true)]).
