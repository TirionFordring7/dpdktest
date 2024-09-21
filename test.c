#include <rte_hash.h>
#include <rte_hash_crc.h>

#define ENTRIES 1000000
#define INSERTIONS 16000000
#define INTERVAL 1000000
#define DEMANDED_ITERATION 123456
#define DEMANDED_KEY 42
#define DEMANDED_VALUE 123456

int main(int argc, char *argv[]) { //без вектора аргументов инициализация EAL не работает
    int ret;
    int lookup_start;
    int lookup_end;
    uint64_t key;
    uint64_t value;
    uint64_t lookup_cycles;
    uint64_t start_time; //в примере было больше чем 4 беззнаковых байта поэтому сразу поставил так
    uint64_t current_time; 
    uint64_t inserted;
    struct rte_hash *hash; //The hash library uses the Cuckoo Hash algorithm to resolve collisions. (c)
    struct rte_hash_parameters hash_params;
    hash_params.name = "test";
    hash_params.entries = ENTRIES;
    hash_params.key_len = sizeof(uint64_t);
    hash_params.hash_func = rte_hash_crc;
    //остальные поля пока не нужны


    //инициализация DPDK EAL
    ret = rte_eal_init(argc, argv);
    if (ret < 0) {
        rte_panic("Cannot init EAL\n");
    }

    //создание хэш таблицы
    hash = rte_hash_create(&hash_params);
    if (hash == NULL) {
        rte_panic("Failed to create hash table\n");
    }

    start_time = rte_get_tsc_cycles();
    //генерация и проверка на требуемые параметры
    inserted = 0;
    for (int i = 1; i <= INSERTIONS; i++) {
        if (i == DEMANDED_ITERATION) {
            key = DEMANDED_KEY;
            value = DEMANDED_VALUE;
        } else {
            key = rand();
            value = rand();
        }
        //вставка данных и ключа в хэш таблицу с подсчетом хэша и выкидыванием значения если все забито
        rte_hash_add_key_data(hash, &key, &value); //If the key exists already in the table, this API updates its value with 'data' passed in this API.(c)


        inserted++;

        //отчет
        if (i % INTERVAL == 0) {
            current_time = rte_get_tsc_cycles() - start_time; //количество наносекунд в цикле
            printf("записано ключей %d из %d, время %lu циклов\n",
             i, INSERTIONS, current_time*1000000000/rte_get_tsc_hz()); //поменять потом весь вывод на формат примера!
            
        }
    }

    printf("количество элементов в хэш таблице: %u\n", rte_hash_count(hash));

    //поиск смысла жизни)
    key = DEMANDED_KEY;
    lookup_start = rte_get_tsc_cycles();
    ret = rte_hash_lookup_data(hash, &key, (void **)&value);
    lookup_end = rte_get_tsc_cycles();

    if (ret >= 0) {
        printf("ключ: %d индекс: %d, значение: %lu\n", DEMANDED_KEY, ret, (uint64_t)value);
    } else {
        printf("ключ %d не найден в хэш таблице.\n", DEMANDED_KEY);
    }
    lookup_cycles = lookup_end - lookup_start;
    printf("время лукапа: %lu циклов\n", (lookup_cycles*1000000000)/rte_get_tsc_hz());

    //очистка
    rte_hash_free(hash);
    rte_eal_cleanup();

    return 0;
}
