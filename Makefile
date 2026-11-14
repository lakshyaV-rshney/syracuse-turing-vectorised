# ==============================================================================
# Makefile: Autonomous Multi-Trajectory Syracuse Transducer (M') Ecosystem
# Target Venue: IEEE / RC 2027
# ==============================================================================

MAIN = syracuse_cyclic_array
TEX = $(MAIN).tex
PDF = $(MAIN).pdf
PY = python
ZIP = syracuse_mprime_artifact.zip

.PHONY: all pdf test clean lint preflight archive

all: test pdf

pdf: $(PDF)

$(PDF): $(TEX)
	pdflatex -interaction=nonstopmode $(TEX)
	pdflatex -interaction=nonstopmode $(TEX)

test:
	$(PY) verify_cyclic_transducer.py

lint:
	@echo "Checking $(MAIN).log for overfull boxes and undefined references..."
	@$(PY) -c "import sys; log = open('$(MAIN).log', 'r', errors='ignore').read(); ovf = [l for l in log.splitlines() if 'Overfull' in l]; print(f'Overfull boxes found: {len(ovf)}'); [print('  ' + l) for l in ovf[:5]]; undef = [l for l in log.splitlines() if 'undefined' in l.lower()]; print(f'Undefined warnings found: {len(undef)}'); [print('  ' + l) for l in undef[:5]]"

clean:
	@$(PY) -c "import os, glob; [os.remove(f) for ext in ['*.aux', '*.log', '*.out', '*.fls', '*.fdb_latexmk', '*.toc'] for f in glob.glob(ext)]"
	@echo "Clean completed."

preflight: test pdf lint
	@echo "All preflight verification checks completed successfully."

archive: test pdf
	@$(PY) -c "import zipfile, os; files = ['$(TEX)', '$(PDF)', 'verify_cyclic_transducer.py', 'Makefile', 'challenge.txt', 'notes.txt', 'comparator.lean', 'lakefile.lean', 'lean-toolchain', 'Syracuse.lean', os.path.join('Syracuse', 'CyclicTransducer.lean')]; z = zipfile.ZipFile('$(ZIP)', 'w', zipfile.ZIP_DEFLATED); [z.write(f) for f in files]; z.close(); print(f'Submission archive generated: $(ZIP) ({os.path.getsize(\"$(ZIP)\")} bytes)')"
