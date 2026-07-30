# ZEALS Declaration Language

## Problem

```prolog
problem(
    ProblemId,
    Inputs,
    Outputs,
    Preconditions,
    Invariants,
    Objectives,
    Constraints
).
```

Dictionary form is also accepted.

## Case

```prolog
case(
    CaseId,
    ProblemId,
    Input,
    ExpectedClass,
    ExpectedOutput,
    Metadata
).
```

`ExpectedClass` is one of: `training`, `verification`, `boundary`, `adversarial`, `regression`.

`ExpectedOutput` forms:
- `exact(Value)`
- `one_of(Values)`
- `satisfies(Verifier)`
- `unknown`
- `unsupported`

## Perturbation

```prolog
perturbation(
    PerturbationId,
    ProblemId,
    Restrictions,
    Assumptions,
    Representation,
    Method,
    Objectives,
    Contract
).
```

Contract forms:
- `contract(Recogniser, Executor, Verifier)`
- `method_contract(MethodId, Recogniser, Preconditions, Executor, Postconditions, FailureModes, Verifier)`

## Generation dimensions

```prolog
zeals:perturbation_dimension(ProblemId, Dimension, Values).
zeals:compatible_setting(ProblemId, DimensionA, ValueA, DimensionB, ValueB).
zeals:incompatible_setting(ProblemId, DimensionA, ValueA, DimensionB, ValueB).
zeals:required_setting(ProblemId, DimensionA, ValueA, DimensionB, ValueB).
zeals:generation_limit(ProblemId, MaxCount).
```

