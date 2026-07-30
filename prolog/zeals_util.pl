:- module(zeals_util, [
    throw_zeals_error/3,
    option_bool/4,
    ensure_list/2,
    normalise_status/2,
    callable_with_args/2,
    metadata_value/3
]).

:- use_module(library(error)).
:- use_module(library(option)).

%! throw_zeals_error(+Code, +Details, +Context) is det.
%
%  Throw a structured ZEALS exception.
throw_zeals_error(Code, Details, Context) :-
    throw(error(zeals_error(Code, Details), Context)).

%! option_bool(+Name, +Options, +Default, -Value) is det.
option_bool(Name, Options, Default, Value) :-
    Template =.. [Name, OptValue],
    (   option(Template, Options)
    ->  Value = OptValue
    ;   Value = Default
    ).

%! ensure_list(+Value, -List) is det.
ensure_list(Value, List) :-
    (   is_list(Value)
    ->  List = Value
    ;   List = [Value]
    ).

%! normalise_status(+Raw, -Status) is det.
normalise_status(Raw, Status) :-
    (   memberchk(Raw, [correct, incorrect, partial, unsupported, timeout, exception,
                        contradiction, unsafe, unknown, verification_failed])
    ->  Status = Raw
    ;   Status = unknown
    ).

%! callable_with_args(+Callable, +Args) is semidet.
callable_with_args(Callable, Args) :-
    (   Callable = Module:Inner
    ->  callable_goal(Inner, Args, Goal),
        catch(
            call(Module:Goal),
            error(existence_error(procedure, _), _),
            fail
        )
    ;   callable_goal(Callable, Args, Goal),
        catch(
            call(Goal),
            error(existence_error(procedure, _), _),
            fail
        )
    ).

callable_goal(Callable, Args, Goal) :-
    Callable =.. [Name|Prefix],
    append(Prefix, Args, FullArgs),
    Goal =.. [Name|FullArgs].

%! metadata_value(+Metadata, +Key, -Value) is semidet.
metadata_value(Metadata, Key, Value) :-
    member(Term, Metadata),
    Term =.. [Key, Value],
    !.
