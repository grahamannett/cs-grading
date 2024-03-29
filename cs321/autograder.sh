#!/bin/bash
# usage:
# ./autograder.sh PROJECT_NAME RESOURCES_DIR FILE_TO_FIND
# e.g. ./autograder.sh p1-webpage-cache ../../cs321-resources Cache.java

# DEFAULTS
TERM=xterm-color # for color
DEFAULT_RESOURCES_DIR="../../cs321-resources"
RUBRIC_FILE=*-rubric.txt

# ansi color escape codes
NC='\033[0m' # No Color
RED='\033[0;31m'
PURPLE='\033[0;35m'
YELLOW='\033[0;33m'

# ARGUMENTS: PROJECT_NAME, RESOURCES_DIR, FILE_TO_FIND (file most likely where there codebase is, might be Cache.java or something later)
PROJECT_NAME="${1:-$PROJECT_NAME}"
RESOURCES_DIR="${2:-$DEFAULT_RESOURCES_DIR}"
FILE_TO_FIND="${3:-$RUBRIC_FILE}"

# CHECK FOR PROJECT_NAME AND RESOURCES_DIR
! test -n "$PROJECT_NAME" && echo "PROJECT_NAME must be set" && exit 0 # exit 0 so no errors
! test -d $RESOURCES_DIR && git clone https://github.com/BoiseState/CS321-resources $RESOURCES_DIR

# base repo path is where we will look for cs321-resources or clone it to.
# get absolute path as we may need to cd into subdir for students
ABSOLUTE_RESOURCES_PATH=$(realpath $RESOURCES_DIR)

# get 2nd commit author as first is likely the instructor/gh classroom
AUTHOR=$(git log --format='%an' --reverse | sed -n '2p')
AUTHOR_EMAIL=$(git log --format='%ae' --reverse | sed -n '2p')

check_for() {
    if ! test -e $1; then
        echo "-- GETTING $1... to " $(pwd)
        cp -r $ABSOLUTE_RESOURCES_PATH/projects/$PROJECT_NAME/$1 .
    fi
}

run_tests() {
    echo "RUNNING TESTS..."
    javac -cp ../../lib/junit-platform-console-standalone-1.10.0.jar:../../lib/junit-4.13.2.jar *.java
    chmod +x run-tests.sh
    ./run-tests.sh
}

# check if we are in the right directory in case student created a subdirectory
find_project_dir() {
    local found_file=$(find . -name $FILE_TO_FIND -print -quit)
    local student_project_dir=$(dirname $found_file)
    echo $student_project_dir
}

git_time_delta() {
    # Get the date of the last commit
    LAST_COMMIT_DATE=$(git log -1 --format="%cd" --date=iso-local)

    # Convert the commit date to seconds since epoch
    # COMMIT_SEC=$(date -jf "%Y-%m-%d %H:%M:%S %z" "$LAST_COMMIT_DATE" +%s)
    if [[ "$(uname)" == "Darwin" ]]; then
        COMMIT_SEC=$(date -jf "%Y-%m-%d %H:%M:%S %z" "$LAST_COMMIT_DATE" +%s)
    else
        COMMIT_SEC=$(date -d "$LAST_COMMIT_DATE" +%s)
    fi

    # Get the current date in seconds since epoch
    NOW_SEC=$(date +%s)

    # Calculate the time delta in seconds
    DELTA_SEC=$((NOW_SEC - COMMIT_SEC))

    # Convert the delta to days, hours, minutes, and seconds
    DELTA_DAYS=$((DELTA_SEC / 86400))
    DELTA_HOURS=$((DELTA_SEC / 3600 % 24))
    DELTA_MINUTES=$((DELTA_SEC / 60 % 60))
    DELTA_SECONDS=$((DELTA_SEC % 60))

    echo "It's been $DELTA_DAYS days, $DELTA_HOURS hours, $DELTA_MINUTES minutes, and $DELTA_SECONDS seconds since the last commit."
}

# IN HERE SETUP/RUN EACH PROJECT
setup_project() {
    echo "SETUP FOR $PROJECT_NAME"
    case $PROJECT_NAME in
    p1-*)
        check_for test-cases
        check_for run-tests.sh && chmod +x run-tests.sh
        check_for $RUBRIC_FILE
        check_for fruits.txt
        run_tests
        echo -e "==>${RED}CHECK FOR USAGE${NC}"
        java CacheExperiment 10
        ;;
    p2-*)
        # ./autograder.sh p2-pq-stardew-valley ../../cs321-resources MyLifeInStardew.java
        check_for test-cases
        check_for run-tests.sh && chmod +x run-tests.sh
        check_for $RUBRIC_FILE
        check_for MyLifeInStardew.java
        check_for StardewDailyClock.java
        check_for HeapException.java
        run_tests
        echo -e "==>${RED}CHECK FOR USAGE${NC}"
        java MyLifeInStardew 1
        ;;
    p3-*)
        # ./autograder.sh p3-hashing-experiments ../../cs321-resources HashtableTest.java
        check_for test-cases
        check_for word-list.txt
        chmod +x run-tests.sh
        check_for $RUBRIC_FILE
        check_for TwinPrimeGenerator.java
        run_tests
        echo -e "==>${RED}CHECK FOR USAGE${NC}"
        java HashtableTest 1
        ;;
    *)
        echo "NO PROJECT SETUP"
        ;;
    esac
}

# FIND STUDENT PROJECT DIR IF ITS POSSIBLY IN A SUBDIR
STUDENT_PROJECT_DIR=$(find_project_dir)

# Removed--
# if ! [ $STUDENT_PROJECT_DIR == "." ]; then
#     echo -e "==>${RED}CHANGE DIR AS STUDENTS FILES LiKELY iN SUBDIR${NC}"
#     cd $STUDENT_PROJECT_DIR
# fi

# BEFORE RUNNING PUT INFO HERE
width=35
echo "=== === ==="
echo -e "GRADING FOR USER ${PURPLE} $AUTHOR < $AUTHOR_EMAIL > ${NC}"
echo '---'
printf "%-*s%s\n" "$((width - ${#3}))" CURRENT_DIR: "$(pwd)"
printf "%-*s%s\n" "$((width - ${#3}))" STUDENT_PROJECT_DIR: "$STUDENT_PROJECT_DIR"
printf "%-*s%s\n" "$((width - ${#3}))" RESOURCES_PATH: "$ABSOLUTE_RESOURCES_PATH"
echo "=== === ===\n\n"

# CHECK FOR FILES NEEDED
setup_project

# Removed--
# git_time_delta
