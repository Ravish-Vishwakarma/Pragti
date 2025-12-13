import psutil

def get_windows_processes():
    third_party_names = set()

    for proc in psutil.process_iter(['name', 'exe']):
        try:
            exe_path = proc.info['exe']
            if exe_path and not exe_path.lower().startswith(("c:\\windows", "c:\\windows\\system32")):
                third_party_names.add(proc.info['name'])
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue

    return third_party_names
