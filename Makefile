.PHONY : default
PYTHON=$(or $(shell which python3),$(shell which python))
default:
	@echo "To install run \"./setup.py install\" or \"make install\""
	@echo "To test sanity of code run \"make test\""

clean:
	rm -f *.pyc */*.pyc
	rm -rf */__pycache__/
	rm -rf pylint_report.txt
	rm -rf coverage.xml
	rm -rf dist/ build/
	rm -rf htmlcov/
	$(MAKE) -C docs clean

.PHONY : install
install:
	"$(PYTHON)" setup.py install

.PHONY : docs
docs:
	$(MAKE) -C docs html

test: docs
	coverage2 run --branch --source tlsfuzzer -m unittest discover -v
	coverage3 run --append --branch --source tlsfuzzer -m unittest discover -v
	coverage3 report -m
	coverage3 xml
	coverage3 html
	"$(PYTHON)" tests/verify-scripts-json.py tests/tlslite-ng.json tests/tlslite-ng-random-subset.json
	pylint --msg-template="{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}" tlsfuzzer > pylint_report.txt || :
	diff-quality --violations=pylint --fail-under=90 pylint_report.txt
	diff-cover --fail-under=90 coverage.xml

test-scripts:
	"$(PYTHON)" tests/verify-scripts-json.py tests/tlslite-ng.json tests/tlslite-ng-random-subset.json
	"$(PYTHON)" tests/scripts_retention.py tests/tlslite-ng.json ../tlslite-ng/scripts/tls.py 1850
