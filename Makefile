# ==============================================================================
# Makefile: Autonomous Multi-Trajectory Syracuse Transducer (M') Ecosystem
# Target: Verification, Simulation, and Paper Compilation
# ==============================================================================

MAIN = syracuse_cyclic_array
TEX = paper/$(MAIN).tex
PDF = paper/$(MAIN).pdf
PY = python
SIM = simulator/verify_cyclic_transducer.py

.PHONY: all pdf test clean lint preflight

all: test pdf

pdf: $(PDF)

$(PDF): $(TEX)
	cd paper && pdflatex -interaction=nonstopmode $(MAIN).tex
	cd paper && pdflatex -interaction=nonstopmode $(MAIN).tex

test:
	$(PY) $(SIM)

lint:
	@echo "Checking paper/$(MAIN).log for overfull boxes and undefined references..."
	@$(PY) -c "log = open('paper/$(MAIN).log', 'r', errors='ignore').read(); ovf = [l for l in log.splitlines() if 'Overfull' in l]; print(f'Overfull boxes: {len(ovf)}'); undef = [l for l in log.splitlines() if 'undefined' in l.lower()]; print(f'Undefined warnings: {len(undef)}')"

clean:
	@$(PY) -c "import os, glob; [os.remove(f) for ext in ['paper/*.aux', 'paper/*.log', 'paper/*.out', 'paper/*.fls', 'paper/*.fdb_latexmk', 'paper/*.toc', 'paper/*.synctex.gz'] for f in glob.glob(ext)]"
	@echo "Clean completed."

preflight: test pdf lint
	@echo "All preflight verification checks completed successfully."
