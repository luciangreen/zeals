:- begin_tests(components).

:- use_module('../prolog/zeals').
:- use_module('../prolog/zeals_component').
:- use_module(test_support).

test(component_extraction) :-
    test_support:setup_base_registry,
    zeals_component:extract_components(square_solver, Components),
    length(Components, 3).

test(component_dependency_graph) :-
    test_support:setup_base_registry,
    zeals_component:extract_all_components(sample_problem, Components),
    zeals_component:build_dependency_graph(Components, Graph),
    zeals_component:detect_component_cycles(Graph, Cycles),
    Cycles == [].

:- end_tests(components).

