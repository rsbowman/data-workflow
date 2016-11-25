
#include <iostream>
#include <cassert>

template <typename F, typename... Args>
class CanApply {
protected:
    template <typename F2, typename... Args2>
    struct Fargs {};

    template <typename Fgs, typename = void>
    struct CanApplyHelper {
        static constexpr bool value = false;
    };

    template <typename F2, typename... Args2>
    struct CanApplyHelper<
        Fargs<F2, Args2...>,
        decltype(std::declval<F2>().operator()(std::declval<Args2>()...), void())
    > {
        static constexpr bool value = true;
    };

public:
    static constexpr bool value = CanApplyHelper<Fargs<F, Args...>>::value;
};

template <typename F, typename... Args>
constexpr bool can_apply(F&& f, Args&&... args) {
    return CanApply<decltype(f), decltype(args)...>::value;
}

struct Foo {};

int main(void) {
    auto f = [](int x) { return x + 1; };
    auto g = [](const std::string& s, const std::string& t) { return s + t; };

    assert(can_apply(f, 3));
    assert(!can_apply(f, Foo()));

    assert(can_apply(g, "boo", "hey"));
    assert(!can_apply(g, "yo"));

    std::cout << "If you see this, the tests passed ;)" << std::endl;
    return 0;
}
