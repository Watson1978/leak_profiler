#include "ruby.h"

#if defined(_WIN32)
#include <psapi.h>

static VALUE leak_profiler_max_rss(VALUE self)
{
        PROCESS_MEMORY_COUNTERS pmc;
    if (!GetProcessMemoryInfo(GetCurrentProcess(), &pmc, sizeof(pmc))) {
        rb_sys_fail("GetProcessMemoryInfo");
    }
    return LONG2NUM(pmc.PeakWorkingSetSize);
}

#else
#include <sys/resource.h>

static VALUE leak_profiler_max_rss(VALUE self)
{
    struct rusage usage;
    if (getrusage(RUSAGE_SELF, &usage) == -1) {
        rb_sys_fail("getrusage");
    }

    return LONG2NUM(usage.ru_maxrss);
}

#endif

void Init_leak_profiler_ext(void)
{
    VALUE cLeakProfiler = rb_define_class("LeakProfiler", rb_cObject);
    VALUE cMemoryUsage = rb_define_class_under(cLeakProfiler, "MemoryUsage", rb_cObject);


    rb_define_singleton_method(cMemoryUsage, "max_rss", leak_profiler_max_rss, 0);
}