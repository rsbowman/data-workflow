#include <iostream>
#include <thread>
#include <vector>
#include <cmath>
#include <mutex>
#include <atomic>

#include <tbb/spin_mutex.h>

#include "timer.h"

#if 1
#define USING_STM "using STM"
#define TX_BEGIN __transaction_relaxed {
#define TX_END }
#else
#define USING_STM "NOT using STM"
#define TX_BEGIN
#define TX_END
#endif

class Stats {
protected:
    int max_ids;
    std::vector<int> events_by_id;
    std::vector<int> events2_by_id;
    std::vector<int> events3_by_id;

public:
    Stats(int max_ids) : max_ids(max_ids), events_by_id(max_ids, 0),
    events2_by_id(max_ids, 0), events3_by_id(max_ids, 0) {}

    void event_occurred(int id) {
        events_by_id[id] += 1;
        events2_by_id[id] += 1;
        events3_by_id[id] += 1;
    }

    void get_total_events(void) {
        int a = 0, b = 0, c = 0;

        for (auto& e : events_by_id)
            a += e;

        for (auto& e : events2_by_id)
            b += e;

        for (auto& e : events3_by_id)
            c += e;

        std::cout << "   events a, b, c: " << a << " " << b << " " << c << std::endl;
    }
};

class StatsLock : public Stats {
    using mutex_t = std::mutex;
    using lock_guard_t = std::lock_guard<mutex_t>;

    mutex_t m;

public:
    StatsLock(int max_ids) : Stats(max_ids) {}

    void event_occurred(int id) {
        lock_guard_t lock(m);
        Stats::event_occurred(id);
    }

    void get_total_events(void) {
        lock_guard_t lock(m);
        Stats::get_total_events();
    }
};

class StatsTbbLock : public Stats {
    using mutex_t = tbb::speculative_spin_mutex;
    using lock_guard_t = mutex_t::scoped_lock;

    mutex_t m;

public:
    StatsTbbLock(int max_ids) : Stats(max_ids) {}

    void event_occurred(int id) {
        lock_guard_t lock(m);
        Stats::event_occurred(id);
    }

    void get_total_events(void) {
        lock_guard_t lock(m);
        Stats::get_total_events();
    }
};

class StatsStm : public Stats {
public:
    StatsStm(int max_ids) : Stats(max_ids) {}

    void event_occurred(int id) {
        TX_BEGIN
            Stats::event_occurred(id);
        TX_END
    }

    void get_total_events(void) {
        int a = 0, b = 0, c = 0;

        TX_BEGIN
            for (auto& e : events_by_id)
                a += e;

            for (auto& e : events2_by_id)
                b += e;

            for (auto& e : events3_by_id)
                c += e;

        TX_END

        std::cout << "   events a, b, c: " << a << " " << b << " " << c << std::endl;
    }
};

template <typename T>
static void thr_func(T& stats, int id, int n_loops) {
    for (int i = 0; i < n_loops; ++i) {
        stats.event_occurred(id);
        if (id == 0 && i %(n_loops / 10) == 0)
            stats.get_total_events();
    }
}

int main(int argc, char *argv[]) {
    constexpr int n_loops =   8000000;
    constexpr int n_threads = 8;
    std::thread thr[n_threads];

    Stats stats(n_threads);
    StatsLock stats_lock(n_threads);
    StatsTbbLock stats_tbb_lock(n_threads);
    StatsStm stats_stm(n_threads);

    int i = 0;
    TIMER("stats, no locking")
    for (auto& t : thr)
        t = std::thread(thr_func<Stats>, std::ref(stats), i++, n_loops);

    for (auto& t : thr)
        t.join();
    ENDTIMER;

    i = 0;
    TIMER("stats w/ std::mutx lock")
    for (auto& t : thr)
        t = std::thread(thr_func<StatsLock>, std::ref(stats_lock), i++, n_loops);

    for (auto& t : thr)
        t.join();
    ENDTIMER;

    i = 0;
    TIMER("stats w/ TBB lock")
    for (auto& t : thr)
        t = std::thread(thr_func<StatsTbbLock>, std::ref(stats_tbb_lock), i++, n_loops);

    for (auto& t : thr)
        t.join();
    ENDTIMER;

    i = 0;
    TIMER("stats w/ STM")
    for (auto& t : thr)
        t = std::thread(thr_func<StatsStm>, std::ref(stats_stm), i++, n_loops);

    for (auto& t : thr)
        t.join();
    ENDTIMER;

    return 0;
}
