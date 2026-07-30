:- module(zeals_component, [
    extract_components/2,
    extract_all_components/2,
    component_dependencies/2,
    build_dependency_graph/2,
    topological_component_order/2,
    detect_component_cycles/2
]).

:- use_module(library(lists)).
:- use_module(library(ugraphs)).
:- use_module(zeals_registry).
:- use_module(zeals_perturbation).

extract_components(PerturbationId, Components) :-
    zeals_perturbation:get_perturbation(
        PerturbationId,
        perturbation(PerturbationId, _ProblemId, _Restrictions, Assumptions, _Representation, MethodId, _Objectives, _Contract)
    ),
    zeals_perturbation:method_contract(MethodId, Recogniser, Preconditions, Executor, _Postconditions, _FailureModes, Verifier),
    callable_name_arity(Recogniser, RecogniserPI),
    callable_name_arity(Executor, ExecutorPI),
    callable_name_arity(Verifier, VerifierPI),
    dependency_ids(Assumptions, Dependencies),
    conflict_ids(Assumptions, Conflicts),
    Components = [
        component(recogniser(PerturbationId), PerturbationId, recogniser, RecogniserPI, contract(recogniser), [dependencies(Dependencies), conflicts(Conflicts)]),
        component(solver(PerturbationId), PerturbationId, solver, ExecutorPI, contract(preconditions(Preconditions)), [dependencies(Dependencies), conflicts(Conflicts)]),
        component(verifier(PerturbationId), PerturbationId, verifier, VerifierPI, contract(verifier), [dependencies([solver(PerturbationId)]), conflicts([])])
    ].

extract_all_components(ProblemId, Components) :-
    zeals_registry:perturbation_ids_for_problem(ProblemId, PerturbationIds),
    findall(
        Component,
        (
            member(PerturbationId, PerturbationIds),
            extract_components(PerturbationId, PerPerturbationComponents),
            member(Component, PerPerturbationComponents)
        ),
        Components
    ),
    zeals_registry:set_components(ProblemId, Components).

component_dependencies(Components, Graph) :-
    build_dependency_graph(Components, Graph).

build_dependency_graph(Components, graph(Nodes, Edges, Conflicts)) :-
    findall(ComponentId, member(component(ComponentId, _, _, _, _, _), Components), RawNodes),
    sort(RawNodes, Nodes),
    findall(
        Dependency-ComponentId,
        (
            member(component(ComponentId, _, _, _, _, Metadata), Components),
            member(dependencies(Dependencies), Metadata),
            member(Dependency, Dependencies)
        ),
        Edges
    ),
    findall(
        conflict(ComponentId, ConflictId),
        (
            member(component(ComponentId, _, _, _, _, Metadata), Components),
            member(conflicts(ConflictIds), Metadata),
            member(ConflictId, ConflictIds)
        ),
        Conflicts
    ).

topological_component_order(graph(Nodes, Edges, _Conflicts), OrderedComponents) :-
    vertices_edges_to_ugraph(Nodes, Edges, Graph),
    top_sort(Graph, OrderedComponents).

detect_component_cycles(graph(Nodes, Edges, _Conflicts), Cycles) :-
    vertices_edges_to_ugraph(Nodes, Edges, Graph),
    (   top_sort(Graph, _)
    ->  Cycles = []
    ;   Cycles = [cycle_detected]
    ).

dependency_ids(Assumptions, Dependencies) :-
    findall(Dependency, member(depends_on(Dependency), Assumptions), Dependencies).

conflict_ids(Assumptions, Conflicts) :-
    findall(Conflict, member(conflicts_with(Conflict), Assumptions), Conflicts).

callable_name_arity(Callable, Name/Arity) :-
    Callable =.. [Name|Args],
    length(Args, Arity).
