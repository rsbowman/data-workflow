#ifndef MYTIMER_H
#define MYTIMER_H

#define TIMER(msg) do {\
  clock_t start_t = clock();\
  std::string msg_s = msg;

#define ENDTIMER clock_t end_t = clock();\
  std::cout << ((float)(end_t - start_t))/CLOCKS_PER_SEC << "s ";\
  std::cout << msg_s << std::endl;\
} while (0)

#endif
