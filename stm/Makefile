CXX=g++
OPTS=-Wall -Werror -O3 -march=native -std=c++11

stm_counter: stm_counter.cpp timer.h
	$(CXX) $(OPTS) stm_counter.cpp -o $@ -pthread -fgnu-tm
