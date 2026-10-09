import pathlib
import re
import sys

message = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8-sig")
subject = message.splitlines()[0]
if len(subject) > 60 or not re.match(r"^(feat|fix|chore|docs|ci): ", subject):
    sys.exit("Use a Conventional Commit subject with at most 60 characters.")
if re.search(r"co-authored-by:|claude-session:|generated with claude|noreply@anthropic|noreply@openai", message, re.I):
    sys.exit("Remove automated attribution from the commit message.")
