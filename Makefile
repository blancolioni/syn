.PHONY: all test clean

all:
	alr -n build

test:
	cd tests && alr -n build && ./bin/syn_tests && ./check-style.sh

clean:
	alr -n clean
	cd tests && alr -n clean && rm -rf output
