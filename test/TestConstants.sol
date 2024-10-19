// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;
uint32 constant _MAX_NR_OF_TIERS = 100;

// import { ReadingNrOfFuzzRunsFromToml } from "./fuzz/fuzz_helper/ReadingNrOfFuzzRunsFromToml.sol";

/** @dev Currently (2024-06-04) Fuzz run logging is not supported by Forge:
https://github.com/foundry-rs/foundry/issues/2552
https://github.com/crytic/medusa/issues/234
https://github.com/foundry-rs/foundry/pull/7899
https://github.com/foundry-rs/foundry/issues/4300
So I built a hacky way around logging Fuzz runs. It leverages:
- setUp() is ran once before each test.
- fuzzRuns are ran multiple times per test.
- A temporary file has a "last modified" date that can be read from test.

And I use the following terminology:
- A `test run` can run multiple test.
- A test can run multiple Fuzz runs of that same test.

So in the setUp() I delete a temporary file if it exists, and in the actual test, I create the temp file if it does not
exist yet. This means that the first test of each test run, creates a new "last modified" timestamp. This
"last modified" timestamp is then used to store a file per test run per test. This file contains the data you wish to
track.

For me it was important to verify that each "branch" of the test logic is hit by the fuzz test. Because it could be
that the randomness avoids some test cases, which could mean some behaviour would not be tested even though the test
passes, giving a false sense of confidence.
*/
string constant _TEST_CASE_HIT_RATE_COUNTS_FILENAME = "test_case_hit_rate_counts";
string constant _TIMESTAMP_FILE_EXT = ".timestamp";

string constant _FUZZ_TEST_LOGGING_DIR_NAME = "test_logging";
string constant _TEST_DIR_NAME = "test";
string constant _FOUNDRY_TOML_FILENAME_WITH_EXT = "foundry.toml";
string constant _FOUNDRY_TOML_FUZZ_RUN_START_ID = "fuzz = { runs = ";
string constant _FOUNDRY_TOML_FUZZ_RUN_END_ID = "}";

// ReadingNrOfFuzzRunsFromToml constant readingNrOfFuzzRunsFromToml = new ReadingNrOfFuzzRunsFromToml();
// uint256 constant _NR_OF_FUZZ_RUNS=readingNrOfFuzzRunsFromToml.readNrOfFuzzRunsFromToml();
