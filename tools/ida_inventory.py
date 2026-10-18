# IDA 9.x: File -> Script file... -> select this script.
# Read-only inspection. No IDA database mutations.
import ida_kernwin
import ida_nalt
import idautils
import ida_funcs
import os

KEYWORDS = ("orion", "nova", "quartz", "echo", "policy", "proof", "grant", "lease", "account", "entitle", "subscription", "native", "seal", "atlas", "storekit")
MAX_STRING_HITS = 75
MAX_FUNCTION_HITS = 90

print("=== Atlas Lab X — inventory (read-only) ===")
print("Input:", ida_nalt.get_input_file_path())
print("Processor:", ida_kernwin.get_screen_ea())
print("Function count:", sum(1 for _ in idautils.Functions()))

try:
    print("Strings of interest (bounded list):")
    count = 0
    for item in idautils.Strings():
        value = str(item)
        if any(term in value.lower() for term in KEYWORDS):
            print("  0x%X: %s" % (item.ea, value[:150]))
            for ref in list(idautils.XrefsTo(item.ea))[:3]:
                func = ida_funcs.get_func(ref.frm)
                print("    Xref from 0x%X%s" % (ref.frm, " in function 0x%X" % func.start_ea if func else ""))
            count += 1
            if count >= MAX_STRING_HITS:
                print("  ... truncated ...")
                break
except Exception as exc:
    print("String scan error:", exc)

print("Named functions of interest:")
count = 0
for address in idautils.Functions():
    name = ida_funcs.get_func_name(address) or ""
    if any(term in name.lower() for term in KEYWORDS):
        print("  0x%X: %s" % (address, name))
        count += 1
        if count >= MAX_FUNCTION_HITS:
            print("  ... truncated ...")
            break
print("=== end ===")
