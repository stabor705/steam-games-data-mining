set dotenv-load := true

PYTHONPATH := "steam_games_data_mining"
SRC_PATH := "steam_games_data_mining"
TEST_PATH := "tests"
ANSWERS_FILE := ".copier/.copier-answers.copier-python-project.yml"

# --- Commands for development ---

# Run all checks and tests (lints, mypy, tests...)
all: lint_full test

# Run all checks and tests, but fail on first that returns error (lints, mypy, tests...)
all_ff: lint_full_ff test

# Run black lint check (code formatting)
black:
    uv run black {{ SRC_PATH }} --diff --check --color

# Update project by rerunning copier questionnaire to modify some answers
copier_recopy answers=ANSWERS_FILE:
    copier recopy --answers-file {{ answers }}

# Update project using copier with respect to the answers file
copier_update answers=ANSWERS_FILE:
    copier update --answers-file {{ answers }} --skip-answered

# Run fawltydeps lint check (deopendency issues)
deps:
    uv run fawltydeps

# Run flake8 lint check (pep8 etc.)
flake:
    uv run flake8 {{ SRC_PATH }}

# Show this help message
@help:
    just --list

# Run isort lint check (import sorting)
isort:
    uv run isort {{ SRC_PATH }} --diff --check --color

# Run all lightweight lint checks (no mypy)
@lint:
    -just black
    -just deps
    -just flake
    -just isort

# Run all lightweight lint checks, but fail on first that returns error
lint_ff: black deps flake isort

# Automatically fix lint problems (only reported by black and isort)
lint_fix:
    uv run black {{ SRC_PATH }}
    uv run isort {{ SRC_PATH }}

# Run all lint checks and mypy
lint_full: lint mypy

alias full_lint := lint_full

# Run all lint checks and mypy, but fail on first that returns error
lint_full_ff: lint_ff mypy
alias full_lint_ff := lint_full_ff

# Run mypy check (type checking)
mypy: _set_pythonpath
    uv run mypy {{ SRC_PATH }} --show-error-codes --show-traceback --implicit-reexport

# Open python console (useful when prefixed with dc, as it opens python console inside docker)
ps: _set_pythonpath
    uv run ipython
alias ipython := ps

# Helper command, sets PYTHONPATH
_set_pythonpath path=PYTHONPATH:
    PYTHONPATH={{ path }}

# Run non-integration tests (optionally specify file=path/to/test_file.py)
test file=TEST_PATH: _set_pythonpath
    uv run pytest {{ file }} --durations=10

# --- Separate command versions for github actions ---

_ci: _ci_black _ci_deps _ci_flake8 _ci_isort _ci_mypy _ci_test

_ci_black:
    uv run black {{ SRC_PATH }} --diff --check --quiet

_ci_deps:
    uv run fawltydeps --detailed

_ci_flake8:
    uv run flake8 {{ SRC_PATH }}

_ci_isort:
    uv run isort {{ SRC_PATH }} --diff --check --quiet

_ci_mypy: _set_pythonpath
    uv run mypy {{ SRC_PATH }} --show-error-codes --show-traceback --implicit-reexport --junit-xml=mypy-results.xml

_ci_test: _set_pythonpath
    uv run pytest {{ TEST_PATH }} --durations=10 --junit-xml=test-results.xml
