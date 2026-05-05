import os
import sys
import subprocess

def pytest_cmdline_main(config):
    if os.environ.get("PYTEST_SUB_SESSION"):
        return None
        
    is_all_tests = not config.args or any(
        arg in ["tests/unit", "tests/unit/", "tests\\unit", "tests\\unit\\"]
        for arg in config.args
    )
    
    if not is_all_tests:
        return None
        
    subfolders = ["chatbot", "diary", "materials", "safe_places", "trusted_contact"]
    
    # Recupera gli argomenti originali passati a pytest
    original_args = sys.argv[1:]
    
    # Rimuove il posizionale 'tests/unit/' dagli argomenti originali
    filtered_args = []
    for arg in original_args:
        if arg in ["tests/unit", "tests/unit/", "tests\\unit", "tests\\unit\\"]:
            continue
        filtered_args.append(arg)
        
    exit_code = 0
    for folder in subfolders:
        path = os.path.join("tests", "unit", folder)
        print(f"\n====================== RUNNING {folder.upper()} TESTS ======================")
        
        cmd_args = list(filtered_args) + [path]
        
        # Aggiunge --cov-append per accumulare la copertura
        if "--cov-append" not in cmd_args and any(arg.startswith("--cov") for arg in cmd_args):
            cmd_args.append("--cov-append")
            
        env = dict(os.environ)
        env["PYTEST_SUB_SESSION"] = "1"
        
        # Eseguiamo pytest in un sottoprocesso separato
        cmd = [sys.executable, "-m", "pytest"] + cmd_args
        res = subprocess.run(cmd, env=env)
        if res.returncode != 0:
            exit_code = res.returncode
            
    sys.exit(exit_code)
