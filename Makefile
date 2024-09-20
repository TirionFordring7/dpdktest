# Makefile
CFLAGS += -Wall -Wextra -Wstrict-prototypes -Wmissing-declarations -Wdeclaration-after-statement -Werror -msse4.2 
LDFLAGS += -lrte_hash -lrte_eal

HUGE_PAGES = 1024

all: setup test 
     
setup: 
	@sudo sysctl -w vm.nr_hugepages=$(HUGE_PAGES)
	@sudo mount -t hugetlbfs pagesize=2m /mnt/huge

   
test: test.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

run:
	sudo ./test

clean:
	rm -f test
