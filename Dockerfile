FROM debian:10.10 as build

RUN apt-get update && apt-get install -y -f \
    build-essential cmake coreutils libreadline-dev libncurses5-dev libunwind-dev \
    libicu-dev libssl-dev zlib1g-dev autoconf automake libtool git wget


ARG TNT_VERSION="2.8.3"

WORKDIR /
RUN git clone --branch ${TNT_VERSION} https://github.com/tarantool/tarantool.git

WORKDIR /tarantool-build
RUN cmake /tarantool -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_STATIC=ON -DOPENSSL_USE_STATIC_LIBS=ON -DOPENSSL_ROOT_DIR=/usr/local
RUN make -j
RUN make install
RUN tarantool --version

COPY ./cpp /cpp/
WORKDIR /cpp
ENV CPATH=/usr/local/include/tarantool:/tarantool/src/lib/msgpuck/
RUN cmake . -DCMAKE_BUILD_TYPE=RelWithDebugInfo
RUN make -j8
RUN ls -al


FROM busybox

RUN mkdir /app

COPY --from=build /usr/local/bin/tarantool                  /app/
COPY --from=build /cpp/fiber_crash_demo.so                  /so_libs/

COPY --from=build /usr/lib/locale                           /usr/lib/locale
COPY --from=build /lib/x86_64-linux-gnu/libdl.so.2          /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/librt.so.1          /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/libpthread.so.0     /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/libgcc_s.so.1       /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/libc.so.6           /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/libm.so.6           /lib/x86_64-linux-gnu/
COPY --from=build /lib64/ld-linux-x86-64.so.2               /lib64/

ENV LUA_CPATH=/so_libs/?/?.so;/so_libs/?.so
ENV LUA_PATH=/lua_libs/?.lua;/lua_libs/?;/app/?.lua;
ENV LD_LIBRARY_PATH=/so_libs

RUN ls -al /so_libs

COPY ./lua/* /app/
RUN ls -al /app

RUN mkdir /data
WORKDIR /data
ENTRYPOINT ["/app/tarantool","/app/app.lua"]

