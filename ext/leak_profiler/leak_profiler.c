#include "ruby.h"


// get the maximum resident set size (RSS) of the current process
// return the value in kilobytes
#if defined(_WIN32)
#include <psapi.h>

static VALUE leak_profiler_max_rss(VALUE self)
{
        PROCESS_MEMORY_COUNTERS pmc;
    if (!GetProcessMemoryInfo(GetCurrentProcess(), &pmc, sizeof(pmc))) {
        rb_sys_fail("GetProcessMemoryInfo");
    }
    return LONG2NUM(pmc.PeakWorkingSetSize / 1024);
}

#else
#include <sys/resource.h>

static VALUE leak_profiler_max_rss(VALUE self)
{
    struct rusage usage;
    long max_rss;

    if (getrusage(RUSAGE_SELF, &usage) == -1) {
        rb_sys_fail("getrusage");
    }
    max_rss = usage.ru_maxrss;

#if defined(__APPLE__)
    max_rss = max_rss / 1024;
#endif

    return LONG2NUM(max_rss);
}

#endif

void Init_leak_profiler_ext(void)
{
    VALUE cLeakProfiler = rb_define_class("LeakProfiler", rb_cObject);
    VALUE cMemoryUsage = rb_define_class_under(cLeakProfiler, "MemoryUsage", rb_cObject);


    rb_define_singleton_method(cMemoryUsage, "max_rss", leak_profiler_max_rss, 0);
}