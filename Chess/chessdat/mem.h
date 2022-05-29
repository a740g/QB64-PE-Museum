#include<windows.h>
#include<stdio.h>   
#include<tchar.h>


uint64 MemInUsePercent();
uint64 TotalPhysicalMem ();
uint64 FreePhysicalMem ();
uint64 TotalPagingFile ();
uint64 FreePagingFile ();
uint64 TotalVirtualMem ();
uint64 FreeVirtualMem ();
uint64 FreeExtendedMem ();

static float CalculateCPULoad();
static unsigned long long FileTimeToInt64();
float GetCPULoad();


uint64 MemInUsePercent () {
  MEMORYSTATUSEX statex;
  statex.dwLength = sizeof (statex);
  GlobalMemoryStatusEx (&statex);
  return  statex.dwMemoryLoad;
}

uint64 TotalPhysicalMem () {
  MEMORYSTATUSEX statex;
  statex.dwLength = sizeof (statex);
  GlobalMemoryStatusEx (&statex);
  return statex.ullTotalPhys;
}

uint64 FreePhysicalMem () {
  MEMORYSTATUSEX statex;
  statex.dwLength = sizeof (statex);
  GlobalMemoryStatusEx (&statex);
  return statex.ullAvailPhys;
}

uint64 TotalPagingFile () {
  MEMORYSTATUSEX statex;
  statex.dwLength = sizeof (statex);
  GlobalMemoryStatusEx (&statex);
  return statex.ullTotalPageFile;
}

uint64 FreePagingFile () {
  MEMORYSTATUSEX statex;
  statex.dwLength = sizeof (statex);
  GlobalMemoryStatusEx (&statex);
  return statex.ullAvailPageFile;
}

uint64 TotalVirtualMem () {
  MEMORYSTATUSEX statex;
  statex.dwLength = sizeof (statex);
  GlobalMemoryStatusEx (&statex);
  return statex.ullTotalVirtual;
}

uint64 FreeVirtualMem () {
  MEMORYSTATUSEX statex;
  statex.dwLength = sizeof (statex);
  GlobalMemoryStatusEx (&statex);
  return statex.ullAvailVirtual;
}

uint64 FreeExtendedMem () {
  MEMORYSTATUSEX statex;
  statex.dwLength = sizeof (statex);
  GlobalMemoryStatusEx (&statex);
  return statex.ullAvailExtendedVirtual;
}

static float CalculateCPULoad(unsigned long long idleTicks, unsigned long long totalTicks)
{
    static unsigned long long _previousTotalTicks = 0;
    static unsigned long long _previousIdleTicks = 0;

    unsigned long long totalTicksSinceLastTime = totalTicks - _previousTotalTicks;
    unsigned long long idleTicksSinceLastTime = idleTicks - _previousIdleTicks;


    float ret = 1.0f - ((totalTicksSinceLastTime > 0) ? ((float)idleTicksSinceLastTime) / totalTicksSinceLastTime : 0);

    _previousTotalTicks = totalTicks;
    _previousIdleTicks = idleTicks;
    return ret;
}

static unsigned long long FileTimeToInt64(const FILETIME & ft)
{
    return (((unsigned long long)(ft.dwHighDateTime)) << 32) | ((unsigned long long)ft.dwLowDateTime);
}

// Returns 1.0f for "CPU fully pinned", 0.0f for "CPU idle", or somewhere in between
// You'll need to call this at regular intervals, since it measures the load between
// the previous call and the current one.  Returns -1.0 on error.
float GetCPULoad()
{
    FILETIME idleTime, kernelTime, userTime;
    return GetSystemTimes(&idleTime, &kernelTime, &userTime) ? CalculateCPULoad(FileTimeToInt64(idleTime), FileTimeToInt64(kernelTime) + FileTimeToInt64(userTime)) : -1.0f;
}
