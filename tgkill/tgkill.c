#include <unistd.h>
#include <sys/syscall.h>

int tgkill(int tgid, int tid, int sig) {
  return syscall(__NR_tgkill, tgid, tid, sig);
}
