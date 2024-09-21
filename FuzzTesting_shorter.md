# Fuzz Testing (TL;DR)

\[A long version is over [here](FuzzTesting.md)\]

Addition to branch coverage with fuzz testing.

## Definition

Fuzz testing runs tests with random inputs.

## Problem

Specifying random inputs (e.g., prime numbers, ranges) can become complex with
multiple variables, making it hard to cover all test cases.

### Options

1. Define exact input ranges to cover all scenarios.
1. Use broad random ranges and verify coverage afterward.

Option 1 can become too complex, leading to:

- Missed scenarios and false positives.
- Overly constrained randomness, reducing test effectiveness.

## Solution (Option 2)

Allow randomness with large ranges, then assert all cases are covered.

### Challenges

- No access to past fuzz run variables.
- No `afterAll` to assert reached cases.
- No counter to track runs.

### Implementation

- Create a file with a timestamp at setup.
- Track test case hits in the file.
- Load counts at each run start, update, and save after the run.

### Example

Testing if a function returns the square of prime numbers:

- For primes: run the test and count `found_prime`.
- For non-primes: skip and count `no_prime`.
- Ensure at least one `found_prime` was tested.

Logs are stored in `test_logging/<timestamp>/DebugTest.txt`, with parameters
like a, b, c.

### Limitations

Parameter names are logged as a,b,c... due to boilerplate code issues.
