# Fuzz Testing

This section dives into an addition on branch coverage for  Fuzz testing.

## Definition

In this repo, fuzz testing is considered as running a test with random inputs.

## Tension

One can exactly specify which types of randomness one wants, for example, only
prime numbers or within some range etc. However, sometimes, with multiple
random variables it becomes a bit complicated to exactly specify the randomness
ranges to reach the desired test scenarios.

### Options

In that case one can either:

1. Specify the ranges of the random variables such that each test scenario
   is reached.
1. Let the variable ranges be somewhat random and hope each test scenario is
   reached.

On first sight, option 1 sounds better, because knowing is better than hoping
in terms of test meaningfullness, but in my case option 1 became so complex
that it led to the following issue:

- I wrote some tests of which I thought it would reach all desired test
  scenarios, but ended up not reaching some scenarios, leading to a false
  positive and false confidence.
- I constrained the random variables so much to reach the relevant test cases
  that I reduced the "randomness power" of the fuzz testing.

## Solution (Option 2)

I let the random variables be random with a large range, and afterwards assert
that each test case was reached.

### Solution Challenges

The following assumptions are made:

- In a fuzz run, the code (normally) does not have access to a stored set of variables
  from previous fuzz runs of that specific test function.
- There (normally) is no `afterAll` function for fuzz tests, that is able to
  assert which test cases were reached in the previous fuzz runs.
- (Normally), one does not have a counter that knows which fuzz run is
  currently running in a test function. (That makes it difficult to keep
  track/count which test cases are used).

So to resolve these challenges, I delete and create a file at the setup, then
I create a file with a timestamp, and this timestamp is set as a variable
within the test file, and it is preserved over time somehow. That file is then
filled with zeros for the test case reach counts.

Then the test cases reach count are loaded from the file in the folder with
that timestamp at the start of each fuzz run, then incremented based on which
test cases are reached by which fuzz runs, and at the end of the fuzz run,
exported to file again.

### Concrete Scenario

Suppose rou want to test if a function returns the square of prime numbers, but you
don't want to limit the test cases to "only the primes you can think of", so
you just get the random numbers:
\- and if it is a prime, you do the test. (and count with: `found_prime`)
\- if it is not prime, you do not do the test. (and count with `no_prime`)
Afterwards, you wanna make sure that your test had at least one case
of `found_prime`.

This way you can verify your random test indeed actually tested what you wanted
it to test.

The hit rates for fuzz testing scenarios can be logged to verify whether the
fuzz tests were able to hit the targeted tests cases. The logs of the fuzz-test
scenario hit rates are stored into:
`test_logging/<some timestamp>/DebugTest.txt`.

You specify in each test file what the log parameters a,b,c etc. represent.

### Current Limitations

I did not find a way to export random parameter names to a file without putting
a lot of duplicate boiler-plate code into the test file, so instead I wrote a
generic method that always outputs a,b,..z as log parameters, which can be
called from any fuzz test.
