import os
import sys
import subprocess

def pytest_cmdline_main(config):
    os.environ.setdefault("AWS_DEFAULT_REGION", "eu-south-1")
    os.environ.setdefault("TABLE_CHATS", "chats_mvp")
    os.environ.setdefault("TABLE_MESSAGES", "chats_messages_mvp")

    if os.environ.get("PYTEST_SUB_SESSION"):
        return None

    is_all_tests = not config.args or any(
        arg in ["tests/unit", "tests/unit/", "tests\\unit", "tests\\unit\\"]
        for arg in config.args
    )

    if not is_all_tests:
        return None

    subfolders = ["chatbot", "diary", "materials", "safe_places", "trusted_contact"]

    original_args = sys.argv[1:]
    filtered_args = [
        arg for arg in original_args
        if arg not in ["tests/unit", "tests/unit/", "tests\\unit", "tests\\unit\\"]
    ]

    # Rimuovi tutti gli arg relativi a --cov dai sottoprocessi:
    # li gestiamo noi tramite coverage run
    clean_args = [
        arg for arg in filtered_args
        if not arg.startswith("--cov")
    ]

    # Cancella eventuali .coverage precedenti
    cov_file = ".coverage"
    if os.path.exists(cov_file):
        os.remove(cov_file)

    exit_code = 0
    for folder in subfolders:
        path = os.path.join("tests", "unit", folder)
        print(f"\n====================== RUNNING {folder.upper()} TESTS ======================")

        env = dict(os.environ)
        env["PYTEST_SUB_SESSION"] = "1"

        # Usa coverage run con --append per ogni sottoprocesso
        cmd = [
            sys.executable, "-m", "coverage", "run",
            "--append",                        # accumula sul .coverage esistente
            "--source=src",                    # adatta al tuo package
            "-m", "pytest"
        ] + clean_args + [path]

        res = subprocess.run(cmd, env=env)
        if res.returncode != 0:
            exit_code = res.returncode

    # Genera il report XML una volta sola, alla fine
    print("\n====================== GENERATING COVERAGE REPORT ======================")
    subprocess.run([sys.executable, "-m", "coverage", "xml", "-o", "coverage.xml"])
    subprocess.run([sys.executable, "-m", "coverage", "report"])  # opzionale, stampa a terminale

    sys.exit(exit_code)