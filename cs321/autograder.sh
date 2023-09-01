#!/bin/sh

BASE_REPO_PATH="../cs321-resources"
RUBRIC_FILE=*-rubric.txt

# exit 0 so no errors
! test -n "$PROJECT_NAME" && echo "PROJECT_NAME must be set" && exit 0

check_for() {
    if ! test -e $1; then
        echo "GETTING $1..."
        cp -r $BASE_REPO_PATH/projects/$PROJECT_NAME/$1 .
    fi
}

# alternative is maybe have these be in autograding like:
#   "setup": "bash runner.sh && javac *.java && chmod +x run-tests.sh",
#   "run": "./run-tests.sh",
run_tests() {
    echo "RUNNING TESTS..."
    javac *.java
    chmod +x run-tests.sh
    ./run-tests.sh
}

! test -d $BASE_REPO_PATH && git clone https://github.com/BoiseState/CS321-resources $BASE_REPO_PATH

check_for test-cases
check_for run-tests.sh && chmod +x run-tests.sh
check_for $RUBRIC_FILE

# might need `|| true`
run_tests 