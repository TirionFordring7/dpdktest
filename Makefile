DPDK_URL = https://fast.dpdk.org/rel/dpdk-24.07.tar.xz
DPDK_TAR = dpdk-24.07.tar.xz
DPDK_DIR = dpdk-24.07
DPDK_MD5 = 48151b1bd545cd95447979fa033199bb
CFLAGS += -Wall -Wextra -Wstrict-prototypes -Wmissing-declarations -Wdeclaration-after-statement -Werror -msse4.2 
LDFLAGS += -lrte_hash -lrte_eal


HUGE_PAGES = 88
all:
	@echo "Настройка больших страниц"
	@sudo sysctl -w vm.nr_hugepages=$(HUGE_PAGES)
	@sudo mkdir ./test/hpm
	@sudo mount -t hugetlbfs pagesize=2M ./test/hpm
	@echo "Большие страницы настроены"
	@echo "Скачивание архива DPDK"
	@cd test;\
	wget $(DPDK_URL)
	@echo "Архив скачан"
	@echo "Проверка хэша"
	@cd test;\
	ACTUAL_MD5="$$(md5sum $(DPDK_TAR) | awk '{print $$1}')" && \
	if [ "$$ACTUAL_MD5" != '$(DPDK_MD5)' ]; then echo "Хэш не совпадает"; \
		exit 1; \
	fi
	@echo "Хэш совпадает"
	@echo "Распаковка архива"
	@cd test;\
	tar xf $(DPDK_TAR)
	@echo "Архив распакован"
	@echo "Сборка DPDK"
	@cd test/$(DPDK_DIR);\
	meson setup build && cd build && ninja && sudo meson install && sudo ldconfig
	@echo "DPDK собран"
	@echo "Сборка программы"
	@cd test;\
	$(CC) $(CFLAGS) -o test test.c $(LDFLAGS)
	@echo "Исполняемый файл создан"

run:
	sudo ./test/test

clean:
	@sudo umount ./test/hpm
	@rm -f ./test/$(DPDK_TAR)
	@rm -rf ./test/$(DPDK_DIR)
	@rm -rf ./test/hpm
	@rm -f ./test/test
