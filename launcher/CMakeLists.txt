cmake_minimum_required(VERSION 3.0)
project(wallet_launcher)

file(GLOB_RECURSE sources      src/*.cpp src/*.h)
file(GLOB_RECURSE data resources/*)

add_executable(bittube-launcher ${sources} ${data})

file(COPY ${data} DESTINATION resources)

