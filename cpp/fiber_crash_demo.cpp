//
// Created by Andrey Syvrachev on 20.10.2021.
//
#include <module.h>
#include <pthread.h>


static int fiber_fun_test(va_list) {
    say_info("[%p:%p] fiber_fun_test", pthread_self(), fiber_self());
    return 0;
}

LUA_API "C" int luaopen_fiber_crash_demo(lua_State *L) {
    say_info("[%p:%p] fiber_new", pthread_self(), fiber_self());
    auto fiber = fiber_new("hello", fiber_fun_test);
    say_info("[%p:%p] fiber_start", pthread_self(), fiber_self());
    fiber_start(fiber);
    say_info("[%p:%p] fiber_cancel", pthread_self(), fiber_self());
    fiber_cancel(fiber); // just comment fiber_cancel to remove crash
    say_info("[%p:%p] fiber_cancel .. fin", pthread_self(), fiber_self());
    return 1;
}
