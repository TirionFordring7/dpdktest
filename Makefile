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
	@sudo mkdir ./hpm
	@sudo mount -t hugetlbfs pagesize=2M ./hpm
	@echo "Большие страницы настроены"
	@echo "Скачивание архива DPDK"
	@wget $(DPDK_URL)
	@echo "Архив скачан"
	@echo "Проверка хэша"
	@ACTUAL_MD5="$$(md5sum $(DPDK_TAR) | awk '{print $$1}')" && \
	if [ "$$ACTUAL_MD5" != '$(DPDK_MD5)' ]; then echo "Хэш не совпадает"; \
		exit 1; \
	fi
	@echo "Хэш совпадает"
	@echo "Распаковка архива"
	@tar xf $(DPDK_TAR)
	@echo "Архив распакован"
	@echo "Сборка DPDK"
	@cd $(DPDK_DIR);\
	meson setup build && cd build && ninja && sudo meson install && sudo ldconfig
	@echo "DPDK собран"
	@echo "Сборка программы"
	@$(CC) $(CFLAGS) -o test test.c $(LDFLAGS)
	@echo "Исполняемый файл создан"

run:
	@sudo ./test

clean:
	@sudo umount ./hpm
	@rm -f $(DPDK_TAR)
	@rm -rf $(DPDK_DIR)
	@rm -rf ./hpm
	@rm -f test
