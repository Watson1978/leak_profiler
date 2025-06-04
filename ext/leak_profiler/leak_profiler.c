#include "ruby.h"
#include <stdio.h>
#include <unistd.h>

// get the maximum resident set size (RSS) of the current process
// return the value in kilobytes
#if defined(_WIN32)
#include <psapi.h>

static VALUE leak_profiler_rss(VALUE self)
{
    PROCESS_MEMORY_COUNTERS pmc;
    if (!GetProcessMemoryInfo(GetCurrentProcess(), &pmc, sizeof(pmc))) {
        rb_sys_fail("GetProcessMemoryInfo");
    }
    return LONG2NUM(pmc.PeakWorkingSetSize / 1024);
}

#elif defined(__APPLE__)

#include <mach/mach.h>

static VALUE leak_profiler_rss(VALUE self)
{
    struct mach_task_basic_info info;
    mach_msg_type_number_t count = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &count);
    if (kr != KERN_SUCCESS) {
        rb_sys_fail("task_info");
    }
    return LONG2NUM(info.resident_size / 1024);
}

#else // linux

static VALUE leak_profiler_rss(VALUE self)
{
    long rss = 0;

    FILE *file = fopen("/proc/self/statm", "r");
    if (!file) {
        rb_sys_fail("/proc/self/statm");
    }
    if (fscanf(file, "%*s%ld", &rss) != 1) {
        fclose(file);
        rb_sys_fail("fscanf");
    }
    fclose(file);
    return LONG2NUM(rss * sysconf(_SC_PAGESIZE) / 1024);
}

#endif

void Init_leak_profiler_ext(void)
{
    VALUE cLeakProfiler = rb_define_class("LeakProfiler", rb_cObject);
    VALUE cMemoryUsage = rb_define_class_under(cLeakProfiler, "MemoryUsage", rb_cObject);


    rb_define_singleton_method(cMemoryUsage, "rss", leak_profiler_rss, 0);
}